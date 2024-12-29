import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> getStoredUser() async {
    try {
      final userJson = await storage.read(key: 'user');
      if (userJson != null) {
        return jsonDecode(userJson);
      }
    } catch (e) {
      print('Error retrieving user: $e');
    }
    return null;
  }

  Future<void> fetchUser() async {
    try {
      String? token = await getToken();

      if (token == null) {
        print('No token found');
        return;
      }

      final response = await http.get(
        Uri.parse('$backend_uri/user/profile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );
      print('Response from user service: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = response.body.trim();
        print("Trimmed body from user service: $body");

        try {
          final json = jsonDecode(response.body);
          print("Decoded JSON: $json");

          if (json is Map<String, dynamic>) {
            await storeUser(json);
            print('User fetched and stored successfully');
          } else {
            print('Decoded JSON is not a Map<String, dynamic>');
          }
        } catch (e) {
          print('Error decoding JSON: $e');
        }
      } else {
        print(
            'Failed to load user profile, Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  Future<void> storeUser(Object user) async {
    try {
      final userJson = jsonEncode(user);
      await storage.write(key: 'user', value: userJson);
      print('User stored successfully');
    } catch (e) {
      print('Error storing user: $e');
    }
  }
}
