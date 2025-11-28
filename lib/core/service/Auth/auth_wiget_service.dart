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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _checkAuth();
    });

    // Then check periodically (every 30 seconds)
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
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

      final pref = await SharedPreferences.getInstance();
      final authToken = pref.getBool(loginToken) ?? false;

      // Skip validation on startup if not logged in
      if (!authToken) return;

      // Add delay to ensure app is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        final isValid = await AuthService().checkUserValidation();
        if (!isValid && mounted) {
          await logoutUser(context);
        }
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      // Don't logout on startup errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
