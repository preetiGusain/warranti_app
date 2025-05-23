import 'package:flutter/material.dart';
import 'package:warranti_app/screens/create/create_screen.dart';
import 'package:warranti_app/screens/home_screen.dart';
import 'package:warranti_app/screens/signin_screen.dart';
import 'package:warranti_app/screens/splash_screen.dart';
import 'package:warranti_app/screens/warranty_screen.dart';
import 'package:warranti_app/screens/welcome_screen.dart';
import 'package:warranti_app/service/navigator_service.dart';
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
      navigatorKey: NavigatorService.navigatorKey,
      routes: {
        '/home': (context) => const ConnectionChecker(child: HomeScreen()),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const SigninScreen(),
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
