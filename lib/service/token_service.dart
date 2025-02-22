import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  // Create an instance of FlutterSecureStorage
  static final FlutterSecureStorage _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  // Stores the token
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
    debugPrint('Token stored successfully');
  }

  // Retrievesthe token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
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
}
