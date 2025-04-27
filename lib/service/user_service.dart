import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:warranti_app/util/logger.dart';

class UserService {
  static final log = getLogger('UserService');
  static final FlutterSecureStorage _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  static Future<String?> getUserId() async {
    Map<String, dynamic>? storedUser = await getStoredUser();
    if (storedUser == null) return null;
    if (storedUser.isEmpty) return null;
    if (storedUser['_id'] == null) return null;
    return storedUser['_id'];
  }

  static Future<Map<String, dynamic>?> getStoredUser() async {
    try {
      final userJson = await _storage.read(key: 'user');
      if (userJson != null) {
        return jsonDecode(userJson);
      }
    } catch (e) {
      log.e('Error retrieving user: $e');
    }
    return null;
  }

  static Future<void> fetchUser() async {
    try {
      String? token = await TokenService.getToken();

      if (token == null) {
        log.i('No token found');
        return;
      }

      final response = await http.get(
        Uri.parse('$backendUri/user/profile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );
      log.i('Response from user service: ${response.statusCode}');
      log.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = response.body.trim();
        log.d("Trimmed body from user service: $body");

        try {
          final json = jsonDecode(response.body);
          log.d("Decoded JSON: $json");

          if (json is Map<String, dynamic>) {
            await storeUser(json);
            log.i('User fetched and stored successfully');
          } else {
            log.i('Decoded JSON is not a Map<String, dynamic>');
          }
        } catch (e) {
          log.e('Error decoding JSON: $e');
        }
      } else {
        log.i('Failed to load user profile, Status code: ${response.statusCode}');
        log.d('Response body: ${response.body}');
      }
    } catch (e) {
      log.e('Error fetching user: $e');
    }
  }

  static Future<void> storeUser(Object user) async {
    try {
      final userJson = jsonEncode(user);
      await _storage.write(key: 'user', value: userJson);
      log.i('User stored successfully');
    } catch (e) {
      log.e('Error storing user: $e');
    }
  }

  static Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: 'user');
      log.i('User data deleted from storage');

      await TokenService.deleteToken();
      log.i('Token deleted from storage');
    } catch (e) {
      log.e('Error deleting user data: $e');
    }
  }
}
