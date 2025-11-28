import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Advanced, live internet connection detection service
class InternetConnection {
  static final Connectivity _connectivity = Connectivity();
  static final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);
  static StreamSubscription? _subscription;

  /// Call this once (e.g., in main or app init) to start live monitoring
  static void startMonitoring() {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      final connectivityType =
          result.isNotEmpty ? result.first : ConnectivityResult.none;
      final hasInternet = await _hasActualInternet(connectivityType);
      isConnected.value = hasInternet;
    });
    // Initial check
    _checkAndSet();
  }

  /// Call this to stop monitoring (e.g., on app dispose)
  static void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Returns a [ValueListenable] for live UI updates
  static ValueListenable<bool> get connectionStatus => isConnected;

  /// One-time check for actual internet access (not just network)
  static Future<bool> checkInternetConnection() async {
    return await _hasActualInternet();
  }

  static Future<void> _checkAndSet() async {
    final hasInternet = await _hasActualInternet();
    isConnected.value = hasInternet;
  }

  /// Checks both network and actual internet (by pinging Google DNS)
  static Future<bool> _hasActualInternet(
      [ConnectivityResult? connectivityResult]) async {
    if (connectivityResult == null) {
      final result = await _connectivity.checkConnectivity();
      connectivityResult =
          result.isNotEmpty ? result.first : ConnectivityResult.none;
    }
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('8.8.8.8');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
