import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:warranti_app/api/google_signin_api.dart';
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';

class AuthService {
  Future<bool> isUserSignedIn() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }

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
        Uri.parse('$backend_uri/oauth/google/app'),
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
        print("Response body: $body");

        final json = jsonDecode(body);
        print("Decoded JSON: $json");

        if (json.containsKey('token') && json['token'] != null) {
          await storeToken(json['token']);
          return true;
        } else {
          print('Token not found in response body');
        }
      } else {
        print('Failed to fetch token, Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error during request: $e');
    }
    return false;
  }
}
