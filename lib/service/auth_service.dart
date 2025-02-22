import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:warranti_app/api/google_signin_api.dart';
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:warranti_app/service/user_service.dart';

class AuthService {
  // Checks if the user is signed in by verifying the stored token
  Future<bool> isUserSignedIn() async {
    String? token = await TokenService.getToken();
    if (token == null) return false;
    if (token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('$backend_uri/auth/check'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );
      print("Response: $response");

      if (response.statusCode == 200) {
        print("User is logged in!  Status code : ${response.statusCode}");
        return true;
      } else if (response.statusCode == 401) {
        print(
            "We should call with refresh token to check validity. : ${response.statusCode}");
        try {
          await _refreshTokenFromBackend();
          return true;
        } catch (e) {
          print(e);
          return false;
        }
      } else {
        print("User token is not valid! Status code : ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('Error during request: $e');
      return false;
    }
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

        if (json.containsKey('refreshToken') && json['refreshToken'] != null) {
          await TokenService.storeRefreshToken(json['refreshToken']);
        } else {
          print('Refresh Token not found in response body');
        }

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

  // Fetch token from the backend after Google login
  Future<void> _refreshTokenFromBackend() async {
    String? _id = await UserService().getUserId();
    String? refreshToken = await TokenService.getRefreshToken();
    if (_id == null) throw Exception("Couldn't find id");
    if (refreshToken == null) throw Exception("Don't have refresh token");
    final response = await http.post(
      Uri.parse('$backend_uri/auth/refresh'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body:
          jsonEncode(<String, String>{"id": _id, "refreshToken": refreshToken}),
    );
    if (response.statusCode == 200) {
      final body = response.body;
      print("Response body: $body");

      final json = jsonDecode(body);
      print("Decoded JSON: $json");

      if (json.containsKey('refreshToken') && json['refreshToken'] != null) {
        await TokenService.storeRefreshToken(json['refreshToken']);
      } else {
        print('Refresh Token not found in response body');
      }

      if (json.containsKey('token') && json['token'] != null) {
        await TokenService.storeToken(json['token']);
      } else {
        print('Token not found in response body');
      }
    } else if (response.statusCode == 401) {
      throw Exception("We have to login again!");
    }
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
