import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:warranti_app/api/google_signin_api.dart';
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/navigator_service.dart';
import 'package:warranti_app/service/token_service.dart';

class AuthService {
  // Checks if the user is signed in by verifying the stored token
  static Future<void> checkUserSignedInOnSplash() async {
    try {
      final String? token = await TokenService.getToken();
      debugPrint('Token from TokenService: $token');
      if (token == null) return;

      //Checking if the token we have is valid or not
      final response = await http.get(
        Uri.parse('$backendUri/auth/check'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      final statusCode = response.statusCode;
      final body = response.body;
      debugPrint("Response body: $body");
      switch (statusCode) {
        case 200:
          debugPrint("User is logged in!  Status code : $statusCode");
          NavigatorService.pushNamed('/home');
          return;
        case 401:
          // Got unauthorized error, let's use the refresh token
          debugPrint("Refresh token required. Status code : $statusCode");
          await TokenService.refreshTokenFromBackend();
          return;
        default:
          // Handle other status codes
          throw Exception(
              "Got an unexpected response with statusCode : $statusCode");
      }
    } catch (e) {
      debugPrint('Error during request: $e');
      NavigatorService.pushNamed('/welcome');
      return;
    }
  }

  // Sign up with Google
  static Future<bool> signInWithGoogle(BuildContext context) async {
    debugPrint("Signin with google called");
    final user = await GoogleSigninApi.login();
    debugPrint("Got user $user");
    if (user != null) {
      await fetchTokenFromBackendForGoogleLogIn(context, user);
      return true;
    }
    return false;
  }

  // Fetch token from the backend after Google login
  static Future<void> fetchTokenFromBackendForGoogleLogIn(
      BuildContext context, user) async {
    try {
      debugPrint("Fetching token from backend");
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
      await TokenService.setBothTokensFromResponse(response);
      NavigatorService.pushNamed('/home');
    } catch (e) {
      debugPrint('Error during request: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Google Sign-In failed'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Login with Email/Password
  static Future<(bool, String)> loginWithEmailPassword(
      String email, String password, BuildContext context) async {
    if (email.isEmpty) return (false, 'Please fill in email');
    if (password.isEmpty) return (false, 'Please fill in password');
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

      final statusCode = response.statusCode;
      if (statusCode == 400) {
        final body = response.body;
        final json = jsonDecode(body);
        if (json.containsKey('message') && json['message'] != null) {
          return (false, json['message'] as String);
        }
      }

      await TokenService.setBothTokensFromResponse(response);
      NavigatorService.pushNamed('/home');
      return (true, 'Signed in successfully!');
    } catch (e) {
      debugPrint('Error during login: $e');
      return (false, 'Sign-in failed!');
    }
  }

  // Sign up with Email/Password
  static Future<(bool, String)> signUpWithEmailPassword(String username,
      String email, String password, BuildContext context) async {
    if (username.isEmpty) {
      return (false, 'Please fill in username!');
    }
    if (email.isEmpty) {
      return (false, 'Please fill in email!');
    }
    if (password.isEmpty) {
      return (false, 'Please fill in password!');
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

      final statusCode = response.statusCode;
      if (statusCode == 400) {
        final body = response.body;
        final json = jsonDecode(body);
        if (json.containsKey('message') && json['message'] != null) {
          return (false, json['message'] as String);
        }
      }

      await TokenService.setBothTokensFromResponse(response);
      NavigatorService.pushNamed('/home');
      return (true, 'Signup successful!');
    } catch (e) {
      debugPrint('Error during signup: $e');
      return (false, 'Signup failed');
    }
  }
}
