import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/logout/logout.dart';
import 'package:suproxu/core/service/Auth/user_validation.dart';

class AuthCheckWidget extends StatefulWidget {
  final Widget child;
  const AuthCheckWidget({required this.child, super.key});

  @override
  AuthCheckWidgetState createState() => AuthCheckWidgetState();
}

class AuthCheckWidgetState extends State<AuthCheckWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provide a context to AuthService so it can perform logout if needed
      AuthService().setContext(context);
      _startPeriodicCheck();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    // Delayed first check to allow app to properly initialize
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _checkAuth();
    });

    // Then check periodically (every 30 seconds)
    // AuthService.checkUserValidation() handles logout automatically
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    try {
      if (!mounted) return;
      debugPrint('AuthCheck: running periodic validation check');

      final pref = await SharedPreferences.getInstance();
      final authToken = pref.getBool(loginToken) ?? false;

      // Skip validation if not logged in
      if (!authToken) {
        debugPrint('AuthCheck: No login token found, skipping validation');
        return;
      }

      // Call AuthService which handles everything:
      // - Validates token & device
      // - Makes API call
      // - Automatically triggers logout if invalid
      final isValid = await AuthService().checkUserValidation();
      debugPrint('AuthCheck: validation result=$isValid');
    } catch (e) {
      debugPrint('AuthCheck: Validation error: $e');
      // Errors are handled by AuthService, don't logout here
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
