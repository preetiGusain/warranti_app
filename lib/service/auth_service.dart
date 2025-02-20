import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:warranti_app/api/google_signin_api.dart';
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';

class AuthService {
  // Checks if the user is signed in by verifying the stored token
  Future<bool> isUserSignedIn() async {
    String? token = await TokenService.getToken();
    return token != null && token.isNotEmpty;
  }

  // Sign up with Google
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

  // Fetch token from the backend after Google login
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
          "photoUrl": user.photoUrl ?? ''
        }),
      );
      print("Response: $response");

      if (response.statusCode == 200) {
        final body = response.body;
        print("Response body: $body");

        final json = jsonDecode(body);
        print("Decoded JSON: $json");

        if (json.containsKey('token') && json['token'] != null) {
          await TokenService.storeToken(json['token']);
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

  // Sign up with Email/Password
  Future<bool> loginWithEmailPassword(
      String email, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$backend_uri/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body);

        if (json.containsKey('token') && json['token'] != null) {
          await TokenService.storeToken(json['token']);
          Navigator.of(context).pushNamed('/home');
          return true;
        } else {
          print('Token not found in response body');
        }
      } else {
        print('Failed to sign up, Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error during signup: $e');
    }
    return false;
  }

  // Sign up with Email/Password
  Future<bool> signUpWithEmailPassword(String username, String email,
      String password, BuildContext context) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields!'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    try {
      final response = await http.post(
        Uri.parse('$backend_uri/auth/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body);

        if (json.containsKey('token') && json['token'] != null) {
          await TokenService.storeToken(json['token']);
          Navigator.of(context).pushNamed('/home');
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Signup failed'),
            backgroundColor: Colors.red,
          ));
          print('Token not found in response body');
        }
      } else {
        print('Failed to sign up, Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error during signup: $e');
    }
    return false;
  }
}
