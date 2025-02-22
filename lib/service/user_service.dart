import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final storage = const FlutterSecureStorage();

  Future<String?> getUserId() async {
    Map<String, dynamic>? storedUser = await getStoredUser();
    if (storedUser == null) return null;
    if (storedUser.isEmpty) return null;
    if (storedUser['_id'] == null) return null;
    return storedUser['_id'];
  }

  Future<Map<String, dynamic>?> getStoredUser() async {
    try {
      final userJson = await storage.read(key: 'user');
      if (userJson != null) {
        return jsonDecode(userJson);
      }
    } catch (e) {
      debugPrint('Error retrieving user: $e');
    }
    return null;
  }

  Future<void> fetchUser() async {
    try {
      String? token = await TokenService.getToken();

      if (token == null) {
        debugPrint('No token found');
        return;
      }

      final response = await http.get(
        Uri.parse('$backendUri/user/profile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );
      debugPrint('Response from user service: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = response.body.trim();
        debugPrint("Trimmed body from user service: $body");

        try {
          final json = jsonDecode(response.body);
          debugPrint("Decoded JSON: $json");

          if (json is Map<String, dynamic>) {
            await storeUser(json);
            debugPrint('User fetched and stored successfully');
          } else {
            debugPrint('Decoded JSON is not a Map<String, dynamic>');
          }
        } catch (e) {
          debugPrint('Error decoding JSON: $e');
        }
      } else {
        debugPrint('Failed to load user profile, Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
  }

  Future<void> storeUser(Object user) async {
    try {
      final userJson = jsonEncode(user);
      await storage.write(key: 'user', value: userJson);
      debugPrint('User stored successfully');
    } catch (e) {
      debugPrint('Error storing user: $e');
    }
  }

  Future<void> deleteUserData() async {
    try {
      await storage.delete(key: 'user');
      debugPrint('User data deleted from storage');

      await TokenService.deleteToken();
      debugPrint('Token deleted from storage');
    } catch (e) {
      debugPrint('Error deleting user data: $e');
    }
  }
}
