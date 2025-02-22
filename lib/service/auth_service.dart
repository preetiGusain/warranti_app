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
    debugPrint('Token from TokenService: $token');

    // If there's no token or the token is empty, the user is not signed in
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('$backendUri/auth/check'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );
      
      debugPrint("Response headers: ${response.headers}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("User is logged in!  Status code : ${response.statusCode}");
        return true;
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        debugPrint("Refresh token required. Status code : ${response.statusCode}");
        try {
          await _refreshTokenFromBackend();
          return true;
        } catch (e) {
          debugPrint(e as String?);
          return false;
        }
      } else if (response.statusCode == 503) {
        // Handle server being unavailable
        debugPrint("Backend service unavailable. Status code: ${response.statusCode}");
        return false;
      } else {
        // Handle other status codes
        debugPrint("User token is not valid! Status code : ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint('Error during request: $e');
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
        Uri.parse('$backendUri/oauth/google/app'),
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
      debugPrint("Response: ${response.body}");

      if (response.statusCode == 200) {
        final body = response.body;
        debugPrint("Response body: $body");

        final json = jsonDecode(body);
        debugPrint("Decoded JSON: $json");

        if (json.containsKey('refreshToken') && json['refreshToken'] != null) {
          await TokenService.storeRefreshToken(json['refreshToken']);
        } else {
          debugPrint('Refresh Token not found in response body');
        }

        if (json.containsKey('token') && json['token'] != null) {
          await TokenService.storeToken(json['token']);
          return true;
        } else {
          debugPrint('Token not found in response body');
        }
      } else {
        debugPrint('Failed to fetch token, Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error during request: $e');
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
      Uri.parse('$backendUri/auth/refresh'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body:
          jsonEncode(<String, String>{"id": _id, "refreshToken": refreshToken}),
    );
    if (response.statusCode == 200) {
      final body = response.body;
      debugPrint("Response body: $body");

      final json = jsonDecode(body);
      debugPrint("Decoded JSON: $json");

      if (json.containsKey('refreshToken') && json['refreshToken'] != null) {
        await TokenService.storeRefreshToken(json['refreshToken']);
      } else {
        debugPrint('Refresh Token not found in response body');
      }

      if (json.containsKey('token') && json['token'] != null) {
        await TokenService.storeToken(json['token']);
      } else {
        debugPrint('Token not found in response body');
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
        Uri.parse('$backendUri/auth/login'),
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
          debugPrint('Token not found in response body');
        }
      } else {
        debugPrint('Failed to sign up, Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error during signup: $e');
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
        Uri.parse('$backendUri/auth/signup'),
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
          debugPrint('Token not found in response body');
        }
      } else {
        debugPrint('Failed to sign up, Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error during signup: $e');
    }
    return false;
  }
}
