import 'package:flutter/material.dart';

// allow usage of navigator without context if the need arise
abstract class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<dynamic>? pushNamed(String routeName) {
    debugPrint('route by navigatorKey: $routeName');
    return NavigatorService.navigatorKey.currentState?.pushNamed(routeName);
  }

  static void pop() {
    debugPrint('route by navigatorKey pop');
    return NavigatorService.navigatorKey.currentState?.pop();
  }
}