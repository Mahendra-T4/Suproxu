import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() {
    return _instance;
  }

  NavigationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get the current navigator state
  NavigatorState? get navigator => navigatorKey.currentState;

  /// Check if navigator is available
  bool get isNavigatorReady => navigatorKey.currentState != null;

  /// Navigate to a named route without context
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    if (!isNavigatorReady) {
      throw Exception('Navigator is not ready');
    }
    return navigator!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop the current screen
  void pop<T extends Object?>([T? result]) {
    if (isNavigatorReady) {
      navigator!.pop(result);
    }
  }

  /// Pop until a specific route
  void popUntil(RoutePredicate predicate) {
    if (isNavigatorReady) {
      navigator!.popUntil(predicate);
    }
  }

  /// Check if we can pop
  bool canPop() {
    return isNavigatorReady && navigator!.canPop();
  }
}
