import 'dart:async';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';

/// Singleton WebSocket Manager for MCX category
/// Prevents multiple socket connections and manages lifecycle properly
class MCXWebSocketManager {
  static final MCXWebSocketManager _instance = MCXWebSocketManager._internal();

  IO.Socket? _socket;
  Timer? _emitTimer;
  bool _isConnecting = false;
  bool _isDisposed = false;
  int _referenceCount = 0;

  final Map<String, List<Function(dynamic)>> _listeners = {};

  factory MCXWebSocketManager() {
    return _instance;
  }

  MCXWebSocketManager._internal();

  bool get isConnected => _socket?.connected == true;

  /// Register a listener for a specific activity
  /// Returns an unsubscribe function
  Function unsubscribe(String activity, Function(dynamic) callback) {
    if (!_listeners.containsKey(activity)) {
      _listeners[activity] = [];
    }
    _listeners[activity]!.add(callback);

    return () {
      _listeners[activity]?.remove(callback);
    };
  }

  /// Connect to WebSocket
  Future<void> connect() async {
    // If already connected, just increment reference count
    if (_socket?.connected == true) {
      _referenceCount++;
      developer.log(
        'MCX WebSocket already connected. Reference count: $_referenceCount',
        name: 'MCX WebSocket Manager',
      );
      return;
    }

    if (_isConnecting) {
      developer.log(
        'MCX WebSocket is already connecting...',
        name: 'MCX WebSocket Manager',
      );
      return;
    }

    if (_isDisposed) {
      developer.log(
        'ERROR: Cannot connect - WebSocket has been disposed.',
        name: 'MCX WebSocket Manager',
      );
      return;
    }

    _isConnecting = true;
    _referenceCount++;

    try {
      final userKey = await _getUserKey();
      final deviceID = await _getDeviceID();

      if (userKey == null || deviceID == null) {
        developer.log(
          'Missing userKey or deviceID',
          name: 'MCX WebSocket Manager',
        );
        _isConnecting = false;
        _referenceCount--;
        return;
      }

      final wsUrl = WebSocketConfig.socketUrl.replaceFirst(
        'https://',
        'wss://',
      );

      _socket = IO.io(wsUrl, {
        'path': WebSocketConfig.socketPath,
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'reconnectionAttempts': 10,
        'timeout': 1000,
        'auth': {'token': WebSocketConfig.authToken},
        'extraHeaders': {
          'Authorization': 'Bearer ${WebSocketConfig.authToken}',
        },
      });

      _socket!.onConnect((_) {
        _isConnecting = false;
        developer.log(
          'MCX WebSocket Connected: ${_socket!.id}',
          name: 'MCX WebSocket Manager',
        );
        _startPeriodicEmit();
      });

      _socket!.onDisconnect((_) {
        developer.log(
          'MCX WebSocket Disconnected',
          name: 'MCX WebSocket Manager',
        );
        _stopPeriodicEmit();
      });

      _socket!.onConnectError((err) {
        developer.log('Connection Error: $err', name: 'MCX WebSocket Manager');
      });

      _socket!.onError((err) {
        developer.log('Socket Error: $err', name: 'MCX WebSocket Manager');
      });

      // Listen for all responses and route to registered listeners
      _socket!.on('response', (data) {
        _handleResponseData(data);
      });

      _socket!.connect();
    } catch (e, stack) {
      developer.log(
        'Connection Setup Failed: $e',
        name: 'MCX WebSocket Manager',
        error: e,
        stackTrace: stack,
      );
      _isConnecting = false;
      _referenceCount--;
    }
  }

  /// Disconnect the socket (only disconnects if reference count reaches 0)
  void disconnect() {
    _referenceCount = (_referenceCount - 1).clamp(0, double.infinity).toInt();

    developer.log(
      'Disconnect called. Reference count: $_referenceCount',
      name: 'MCX WebSocket Manager',
    );

    if (_referenceCount > 0) {
      // Still other pages using this socket
      return;
    }

    // All pages disconnected, clean up
    _cleanup();
  }

  /// Force cleanup (for logout scenarios)
  void forceCleanup() {
    _referenceCount = 0;
    _cleanup();
  }

  void _cleanup() {
    if (_isDisposed) return;

    developer.log('Cleaning up MCX WebSocket', name: 'MCX WebSocket Manager');

    _isDisposed = true;
    _stopPeriodicEmit();
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnecting = false;
    _listeners.clear();
  }

  void _handleResponseData(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Call ALL registered listeners with the response data
      // Each listener handles its own filtering based on response content
      for (final callbacks in _listeners.values) {
        for (final callback in callbacks) {
          try {
            callback(data);
          } catch (e) {
            developer.log(
              'Error in listener callback: $e',
              name: 'MCX WebSocket Manager',
            );
          }
        }
      }
    }
  }

  void _startPeriodicEmit() {
    _stopPeriodicEmit();
    // Emit will be triggered by individual services
  }

  void _stopPeriodicEmit() {
    _emitTimer?.cancel();
    _emitTimer = null;
  }

  /// Emit a request to the server
  void emit(String activity, Map<String, dynamic> data) {
    if (_socket?.connected == true) {
      _socket!.emit('activity', data);
    } else {
      developer.log(
        'Cannot emit - socket not connected',
        name: 'MCX WebSocket Manager',
      );
    }
  }

  Future<String?> _getUserKey() async {
    try {
      final databaseService = DatabaseService();
      return await databaseService.getUserData(key: userIDKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getDeviceID() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } catch (_) {
      return null;
    }
  }
}
