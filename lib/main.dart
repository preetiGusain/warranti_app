import 'package:flutter/material.dart';
import 'package:warranti_app/screens/create_screen.dart';
import 'package:warranti_app/screens/home_screen.dart';
import 'package:warranti_app/screens/signin_screen.dart';
import 'package:warranti_app/screens/splash_screen.dart';
import 'package:warranti_app/screens/warranty_screen.dart';
import 'package:warranti_app/widgets/connection_checker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warranti',
      theme: ThemeData(
        fontFamilyFallback: ['Roboto', 'Arial'],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  const SplashScreen(),
      routes: {
        '/home': (context) => const ConnectionChecker(child: HomeScreen()),
        '/signin': (context) => const SigninScreen(),
        '/create': (context) => const CreateScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/warranty') {
          final value = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => WarrantyScreen(id: value));
        }
        return null;
      },
    );
  }
}
