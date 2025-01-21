import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  // Create an instance of FlutterSecureStorage
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Store the token
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
    print('Token stored successfully');
  }

  // Retrieve the token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Delete the token
  static Future<void> deleteToken() async {
    print('Deleting token');
    return await _storage.delete(key: 'jwt_token');
  }
}