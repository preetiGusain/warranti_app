import 'package:flutter/material.dart';
import 'package:warranti_app/util/logger.dart';

// allow usage of navigator without context if the need arise
abstract class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final log = getLogger('NavigatorService');
  

  static Future<dynamic>? pushNamed(String routeName) {
    log.i('route by navigatorKey: $routeName');
    return NavigatorService.navigatorKey.currentState?.pushNamed(routeName);
  }

  static void pop() {
    log.i('route by navigatorKey pop');
    return NavigatorService.navigatorKey.currentState?.pop();
  }
}