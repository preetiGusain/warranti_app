import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:warranti_app/api/google_signin_api.dart';
import 'package:warranti_app/service/token_service.dart';

class AuthService {
  Future<bool> signInWithGoogle(BuildContext context) async {
    final user = await GoogleSigninApi.login();
    if (user != null) {
      final status = await _fetchTokenFromBackend(user);
      if (status) {
        Navigator.of(context).pushNamed('/home');
        return true;
      }
    }
    return false;
  }

  Future<bool> _fetchTokenFromBackend(user) async {
    try {
      final response = await http.post(
        Uri.parse('https://warranti-backend.onrender.com/oauth/google/app'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "id": user.id,
          "displayName": user.displayName,
          "email": user.email,
          "photoUrl": user.photoUrl
        }),
      );
      print("Response: $response");

      if (response.statusCode == 200) {
        final body = response.body;
        print("body $body");

        final json = jsonDecode(body);
        print("json $json");

        if (json.containsKey('token') && json['token'] != null) {
          await storeToken(json['token']);
          return true;
        }
      } else {
        print('Failed to fetch token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during request: $e');
    }
    return false;
  }
}
