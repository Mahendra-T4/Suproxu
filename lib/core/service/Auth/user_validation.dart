import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/constants/widget/custom_toast.dart';
import 'package:suproxu/core/logout/logout.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Broadcast stream to notify listeners that a logout is about to occur.
  final StreamController<void> _logoutController =
      StreamController<void>.broadcast();

  /// Stream that emits an event when logout is initiated.
  Stream<void> get onLogout => _logoutController.stream;

  final _apiUrl = Uri.parse(superTradeBaseApiEndPointUrl);

  bool _isValidUser = true; // Initialize to false by default

  /// Returns whether the user is currently validated
  /// This is updated after each validation check
  bool get isValidUser => _isValidUser;

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<bool> checkUserValidation() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final authToken = pref.getBool(loginToken) ?? false;

      // On app start, if there's no token, mark as invalid and return false
      if (!authToken) {
        log('No auth token found');
        _isValidUser = false;
        return false;
      }

      // Add a small delay on startup to ensure all services are initialized
      await Future.delayed(const Duration(milliseconds: 500));

      DatabaseService dbService = DatabaseService();
      final userKey = await dbService.getUserData(key: userIDKey);

      // Immediate check for user key
      if (userKey == null) {
        log('User key not found, triggering immediate logout');
        _isValidUser = false;
        await pref.setBool(loginToken, true);
        await _performLogout();
        return false;
      }

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final response = await http.post(
        _apiUrl,
        body: {
          "activity": "device-check",
          "deviceID": androidInfo.id.toString(),
          "userKey": userKey.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        log('Device check response: ${response.body}');

        if (jsonData['status'] == 1) {
          // User is valid, update the token and validation state
          final pref = await SharedPreferences.getInstance();
          // CustomToast.showWarning('User validation successful');
          await pref.setBool(loginToken, true);
          _isValidUser = true;
          log('User validation successful');
          return true;
        } else {
          // Immediate logout on invalid session
          log('Invalid session detected, triggering immediate logout');
          await pref.setBool(loginToken, false);
          await _performLogout();
          return false;
        }
      } else {
        log('Server error: ${response.statusCode}');
        // Only logout on specific error codes (401, 403)
        if (response.statusCode == 401 || response.statusCode == 403) {
          await _performLogout();
          _isValidUser = false;
          return false;
        }
        // For other server errors, keep the session active
        return true;
      }
    } catch (e) {
      log('User validation error: $e');
      // Only logout for specific security-related errors
      if (e.toString().contains('token expired') ||
          e.toString().contains('invalid auth') ||
          e.toString().contains('unauthorized')) {
        log('Security-sensitive error detected, triggering logout');
        _isValidUser = false;
        await _performLogout();
        return false;
      }
      // For other errors (like network issues), keep the previous validation state
      log('Non-critical error, keeping session active: $e');
      // Don't update _isValidUser here to maintain the last known state
      return _isValidUser;
    }
  }

  Future<void> _performLogout() async {
    _isValidUser = false;
    log('User validation state set to invalid, initiating logout');

    // Broadcast logout event first so pages can clean up sockets/timers.
    try {
      _logoutController.add(null);
    } catch (e) {
      log('Error broadcasting logout event: $e');
    }

    // Use NavigatorKey for instant logout (works even without context)
    if (_context != null && _context!.mounted) {
      log('Context available, performing logout with context');
      await logoutUser(_context);
    } else {
      log('No context available, performing instant logout via NavigatorKey');
      // Perform instant logout without context using NavigatorKey
      await logoutUser(null);
    }
  }

  /// Invalidates the current user session
  /// This should be called when you need to force a logout
  void invalidateUser() {
    _isValidUser = false;
    log('User validation state invalidated');
  }

  /// Convenience helper that sets context (if provided) and runs validation.
  /// Returns `true` if user is valid, `false` otherwise. If invalid,
  /// `_performLogout()` will be invoked which performs instant logout.
  Future<bool> validateAndLogout([BuildContext? context]) async {
    if (context != null) setContext(context);
    return await checkUserValidation();
  }
}
