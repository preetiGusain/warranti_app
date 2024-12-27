import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<void> storeToken(String token) async {
  await storage.write(key: 'jwt_token', value: token);
  print('Token stored successfully');
}

Future<String?> getToken() async {
  return await storage.read(key: 'jwt_token');
}