import 'dart:async';
import 'package:flutter/material.dart';
import 'package:warranti_app/screens/home_screen.dart';
import 'package:warranti_app/screens/welcome_screen.dart';
import 'package:warranti_app/service/auth_service.dart';
import 'package:warranti_app/widgets/connection_checker.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    try {
      debugPrint('Checking if the user is signed in...');
      bool isSignedIn = await _authService.isUserSignedIn();
      debugPrint('User is signed in: $isSignedIn');

      await Future.delayed(const Duration(seconds: 2));

     
          // Ensure the widget is still mounted before using context
          if (mounted) {
            debugPrint('Navigating to the next screen...');
            if (isSignedIn) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ConnectionChecker(
                    child: const HomeScreen(),
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            }
          }
    } catch (e) {
      debugPrint('Error during user authentication: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFDAB8FC),
              Color(0xFFAFC2FF),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFC33764),
                  Color(0xFF1D2671),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: const Text(
                'Warranti',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
