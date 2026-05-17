import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Singleton service for live internet connection detection
class InternetConnectionService extends WidgetsBindingObserver {
  static final InternetConnectionService _instance =
      InternetConnectionService._internal();
  factory InternetConnectionService() => _instance;
  InternetConnectionService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  StreamSubscription? _subscription;
  Timer? _periodicTimer;
  bool _isMonitoring = false;

  /// Returns a [Stream] for live updates
  Stream<bool> get connectionStream => _connectionController.stream;

  // Start monitoring (call once in main or app init)
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    // Register app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      final connectivityType = result.isNotEmpty
          ? result.first
          : ConnectivityResult.none;
      final hasInternet = await _hasActualInternet(connectivityType);
      _connectionController.add(hasInternet);
    });
    _checkAndSet();
    // Periodic check every 5 seconds for reliability
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkAndSet(),
    );
  }

  /// Stop monitoring (call on app exit)
  void stopMonitoring() {
    _isMonitoring = false;
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _subscription = null;
    _periodicTimer?.cancel();
    // _connectionController.close(); // Only close if app is exiting
  }

  /// Called when app comes to foreground - re-check connection
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 🔄 App is back in focus - immediately re-check connection
      forceConnectionCheck();
    }
  }

  /// Force an immediate connection check (useful when app resumes)
  Future<void> forceConnectionCheck() async {
    await _checkAndSet();
  }

  Future<void> _checkAndSet() async {
    final hasInternet = await _hasActualInternet();
    _connectionController.add(hasInternet);
  }

  /// Checks both network and actual internet (by pinging Google DNS)
  Future<bool> _hasActualInternet([
    ConnectivityResult? connectivityResult,
  ]) async {
    if (connectivityResult == null) {
      final result = await _connectivity.checkConnectivity();
      connectivityResult = result.isNotEmpty
          ? result.first
          : ConnectivityResult.none;
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
