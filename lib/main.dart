import 'package:flutter/material.dart';
import 'package:warranti_app/screens/home_screen.dart';
import 'package:warranti_app/screens/signin_screen.dart';
import 'package:warranti_app/screens/splash_screen.dart';
import 'package:warranti_app/screens/warranty_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warranti',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/signin': (context) => const SigninScreen(),
        '/warranty': (context) => const WarrantyScreen(),
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Warranti"),
      ),
    );
  }
}
