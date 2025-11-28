import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Singleton service for live internet connection detection
class InternetConnectionService {
  static final InternetConnectionService _instance =
      InternetConnectionService._internal();
  factory InternetConnectionService() => _instance;
  InternetConnectionService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  StreamSubscription? _subscription;
  Timer? _periodicTimer;

  /// Returns a [Stream] for live updates
  Stream<bool> get connectionStream => _connectionController.stream;

  // Start monitoring (call once in main or app init)
  void startMonitoring() {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      final connectivityType =
          result.isNotEmpty ? result.first : ConnectivityResult.none;
      final hasInternet = await _hasActualInternet(connectivityType);
      _connectionController.add(hasInternet);
    });
    _checkAndSet();
    // Periodic check every 5 seconds for reliability
    _periodicTimer?.cancel();
    _periodicTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _checkAndSet());
  }

  /// Stop monitoring (call on app exit)
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
    _periodicTimer?.cancel();
    // _connectionController.close(); // Only close if app is exiting
  }

  Future<void> _checkAndSet() async {
    final hasInternet = await _hasActualInternet();
    _connectionController.add(hasInternet);
  }

  /// Checks both network and actual internet (by pinging Google DNS)
  Future<bool> _hasActualInternet(
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
