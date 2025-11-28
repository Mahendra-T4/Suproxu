import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  ConnectivityService() {
    _init();
  }

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityResult get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus != ConnectivityResult.none;

  void _init() async {
    final results = await Connectivity().checkConnectivity();
    _connectionStatus = results.first; // Take the first result
    _subscription = Connectivity().onConnectivityChanged.listen(
          _updateConnectionStatus,
        );
    notifyListeners();
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isNotEmpty) {
      _connectionStatus = results.first;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
