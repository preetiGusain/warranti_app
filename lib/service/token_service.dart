import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/navigator_service.dart';
import 'package:warranti_app/service/user_service.dart';

class TokenService {
  // Create an instance of FlutterSecureStorage
  static final FlutterSecureStorage _storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  // Stores the token
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
    debugPrint('Token stored successfully');
  }

  // Retrievesthe token
  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) return token;
    // Token is null, hence checking for refresh token
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      NavigatorService.pushNamed('/welcome');
      return null;
    }

    try {
      await refreshTokenFromBackend();
      return await _storage.read(key: 'jwt_token');
    } catch (e) {
      NavigatorService.pushNamed('/welcome');
      return null;
    }
  }

  // Deletes the token
  static Future<void> deleteToken() async {
    debugPrint('Deleting token');
    return await _storage.delete(key: 'jwt_token');
  }

  // Stores the refresh token
  static Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
    debugPrint('Token stored successfully');
  }

  // Retrieves the refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // Deletes the refresh token
  static Future<void> deleteRefreshToken() async {
    debugPrint('Deleting token');
    return await _storage.delete(key: 'refresh_token');
  }

  /// Fetches refresh token and access token from the backend.
  static Future<bool> refreshTokenFromBackend() async {
    debugPrint('Refresh Token being called');
    String? id = await UserService.getUserId();
    String? refreshToken = await TokenService.getRefreshToken();
    if (id == null || refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$backendUri/auth/refresh'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode( <String, String>{"id": id, "refreshToken": refreshToken}),
      );
      await setBothTokensFromResponse(response);
      return true;
    } catch (e) {
      debugPrint('Refresh failed: $e');
      return false;
    }
  }

  /// Checks response body of Auth APIs and sets tokens correctly
  static Future<void> setBothTokensFromResponse(http.Response response) async {
    final statusCode = response.statusCode;
    final body = response.body;
    debugPrint("Response body: $body");
    switch (statusCode) {
      case 200:
        final json = jsonDecode(body);
        if (json.containsKey('refreshToken') &&
            json['refreshToken'] != null &&
            json.containsKey('token') &&
            json['token'] != null) {
          await TokenService.storeRefreshToken(json['refreshToken']);
          await TokenService.storeToken(json['token']);
          return;
        } else {
          throw Exception('Token not found in response body');
        }
      default:
        throw Exception('Status code: $statusCode');
    }
  }
}
