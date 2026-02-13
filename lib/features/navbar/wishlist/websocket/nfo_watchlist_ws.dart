import 'dart:async';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';
import 'package:suproxu/features/navbar/wishlist/model/wishlist_entity.dart';

class NFOWatchListWebSocketService {
  IO.Socket? _socket;
  Timer? _emitTimer;
  bool _isConnecting = false;
  bool _isDisposed = false;

  final Function(NFOWishlistEntity) onNFODataReceived;
  final Function(String)? onError;
  final Function()? onConnected;
  final Function()? onDisconnected;

  // Use correct activity name as per backend
  static const String _activity = 'get-wishlist-stocks';
  static const Duration _emitInterval = Duration(milliseconds: 200);

  NFOWatchListWebSocketService({
    required this.onNFODataReceived,
    this.onError,
    this.onConnected,
    this.onDisconnected,
  });

  /// Connect to WebSocket with full lifecycle management
  Future<void> connect() async {
    if (_isDisposed) return;
    if (_socket?.connected == true || _isConnecting) {
      developer.log('Already connected or connecting. Skipping.');
      return;
    }

    _isConnecting = true;

    try {
      // Fetch user and device data
      final userKey = await _getUserKey();
      final deviceID = await _getDeviceID();
      if (userKey == null || deviceID == null) {
        _handleError('Missing userKey or deviceID');
        return;
      }

      final wsUrl = WebSocketConfig.socketUrl.replaceFirst(
        'https://',
        'wss://',
      );

      // Build socket with proper options
      final socket = IO.io(WebSocketConfig.socketUrl, {
        'path': WebSocketConfig.socketPath,
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'reconnectionAttempts': 5,
        'timeout': 10000,
        'auth': {'token': WebSocketConfig.authToken},
        'extraHeaders': {
          'Authorization': 'Bearer ${WebSocketConfig.authToken}',
        },
      });

      _socket = socket;

      // === Connection Events ===
      socket.onConnect((_) {
        if (_isDisposed) return;

        _isConnecting = false;
        developer.log('NFO WebSocket Connected: ${socket.id}');
        onConnected?.call();

        _startPeriodicEmit(userKey, deviceID);
      });

      socket.onDisconnect((_) {
        if (_isDisposed) return;

        developer.log('NFO WebSocket Disconnected: ${socket.id}');
        onDisconnected?.call();
        _stopPeriodicEmit();
      });

      socket.onConnectError((err) {
        _handleError('Connection Error: $err');
      });

      socket.onError((err) {
        _handleError('Socket Error: $err');
      });

      // === Data Listener ===
      socket.on('response', (data) {
        if (_isDisposed) return;

        _handleResponseData(data);
      });

      socket.onReconnect((attempt) {
        developer.log('NFO WebSocket Reconnected after $attempt attempts');
        // Re-emit immediately on reconnect
        _emitNFORequest(userKey, deviceID);
        _startPeriodicEmit(userKey, deviceID);
      });

      socket.onReconnectAttempt((attempt) {
        developer.log('NFO WebSocket Reconnect Attempt: $attempt');
      });

      // Manually connect
      socket.connect();
    } catch (e, stack) {
      _handleError('Connection Setup Failed: $e', stack);
    } finally {
      if (!_socket!.connected) {
        _isConnecting = false;
      }
    }
  }

  /// Emit request for NFO wishlist data
  void _emitNFORequest(String userKey, String deviceID) {
    if (_socket?.connected != true || _isDisposed) return;

    final payload = {
      'activity': _activity,
      'userKey': userKey,
      'deviceID': deviceID,
      'dataRelatedTo': 'NFO',
    };

    _socket!.emit('activity', payload);
    developer.log('Emitted NFO Request: $payload');
  }

  /// Start periodic emission
  void _startPeriodicEmit(String userKey, String deviceID) {
    _stopPeriodicEmit(); // Ensure no duplicate timers

    _emitTimer = Timer.periodic(_emitInterval, (_) {
      _emitNFORequest(userKey, deviceID);
    });

    // Emit immediately on start
    _emitNFORequest(userKey, deviceID);
  }

  /// Stop periodic emission
  void _stopPeriodicEmit() {
    _emitTimer?.cancel();
    _emitTimer = null;
  }

  /// Handle incoming response data
  void _handleResponseData(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final nfoData = NFOWishlistEntity.fromJson(data);
        onNFODataReceived(nfoData);
        developer.log('NFO Data Parsed & Sent: ${data.toString()}');
      } else {
        developer.log('Ignored non-map response: $data');
      }
    } catch (e, stack) {
      developer.log('Failed to parse NFO response: $e', stackTrace: stack);
      onError?.call('Parse error: $e');
    }
  }

  /// Centralized error handler
  void _handleError(String message, [StackTrace? stack]) {
    if (_isDisposed) return;

    _isConnecting = false;
    developer.log(message, name: 'NFO WebSocket Error', stackTrace: stack);
    onError?.call(message);
  }

  /// Safely get user key
  Future<String?> _getUserKey() async {
    try {
      final databaseService = DatabaseService();
      final key = await databaseService.getUserData(key: userIDKey);
      return key?.toString();
    } catch (e) {
      _handleError('Failed to get userKey: $e');
      return null;
    }
  }

  /// Safely get device ID
  Future<String?> _getDeviceID() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } catch (e) {
      _handleError('Failed to get deviceID: $e');
      return null;
    }
  }

  /// Reset disposed state for reconnection after navigation
  void reset() {
    if (_isDisposed && _socket == null) {
      developer.log('WebSocket: Resetting disposed state for reconnection');
      _isDisposed = false;
    }
  }

  /// Disconnect and clean up all resources
  void disconnect() {
    if (_isDisposed) return;

    developer.log('Disconnecting NFO WebSocket...');
    _isDisposed = true;

    _stopPeriodicEmit();
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnecting = false;
  }

  /// Reconnect manually if needed
  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_isDisposed) {
      await connect();
    }
  }

  /// Check connection status
  bool get isConnected => _socket?.connected == true;

  /// Dispose (call from parent widget/state)
  void dispose() => disconnect();
}
