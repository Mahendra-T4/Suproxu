import 'dart:async';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';

class MCXWishlistWebSocketService {
  IO.Socket? _socket;
  Timer? _emitTimer;
  bool _isConnecting = false;
  bool _isDisposed = false;

  final Function(MCXWishlistEntity) onDataReceived;
  final Function(String)? onError;
  final Function()? onConnected;
  final Function()? onDisconnected;
  final String? keyword;

  // Activity and config
  static const String _activity = 'get-wishlist-stocks';
  static const Duration _emitInterval = Duration(milliseconds: 400);
  static const String _dataRelatedTo = 'MCX';

  MCXWishlistWebSocketService({
    required this.onDataReceived,
    this.onError,
    this.onConnected,
    this.onDisconnected,
    this.keyword,
  });

  /// Connect to WebSocket
  Future<void> connect() async {
    if (_isDisposed) return;
    if (_socket?.connected == true || _isConnecting) {
      developer.log('MCX WS: Already connected or connecting. Skipping.');
      return;
    }

    _isConnecting = true;

    try {
      final userKey = await _getUserKey();
      final deviceID = await _getDeviceID();
      if (userKey == null || deviceID == null) {
        _handleError('Missing userKey or deviceID');
        return;
      }

      final wsUrl =
          WebSocketConfig.socketUrl.replaceFirst('https://', 'wss://');

      final socket = IO.io(
        wsUrl,
        IO.OptionBuilder()
            .setPath(WebSocketConfig.socketPath)
            .setTransports(['websocket'])
            // .disableAutoConnect()
            // .setReconnection(true)
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setTimeout(10000)
            .setAuth({'token': WebSocketConfig.authToken})
            .build(),
      );

      _socket = socket;

      // === Connection Events ===
      socket.onConnect((_) {
        if (_isDisposed) return;

        _isConnecting = false;
        developer.log('MCX WebSocket Connected: ${socket.id}');
        onConnected?.call();

        _startPeriodicEmit(userKey, deviceID);
      });

      socket.onDisconnect((_) {
        if (_isDisposed) return;

        developer.log('MCX WebSocket Disconnected');
        onDisconnected?.call();
        _stopPeriodicEmit();
      });

      socket.onConnectError((err) => _handleError('Connect Error: $err'));
      socket.onError((err) => _handleError('Socket Error: $err'));

      // === Data Listener ===
      socket.on('response', (data) {
        if (_isDisposed) return;
        _handleResponseData(data);
      });

      socket.onReconnect((attempt) {
        developer.log('MCX WebSocket Reconnected (attempt: $attempt)');
        _emitMCXRequest(userKey, deviceID);
        _startPeriodicEmit(userKey, deviceID);
      });

      socket.onReconnectAttempt((attempt) {
        developer.log('MCX WebSocket Reconnect Attempt: $attempt');
      });

      // Manual connect
      socket.connect();
    } catch (e, stack) {
      _handleError('Setup Failed: $e', stack);
    } finally {
      if (!(_socket?.connected ?? false)) {
        _isConnecting = false;
      }
    }
  }

  /// Emit MCX wishlist request
  void _emitMCXRequest(String userKey, String deviceID) {
    if (!(_socket?.connected == true) || _isDisposed) return;

    final payload = {
      'activity': _activity,
      'userKey': userKey,
      'deviceID': deviceID,
      'dataRelatedTo': _dataRelatedTo,
      if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
    };

    _socket!.emit('activity', payload);
    developer.log('Emitted MCX Request: $payload');
  }

  /// Start periodic emission
  void _startPeriodicEmit(String userKey, String deviceID) {
    _stopPeriodicEmit();

    // Emit immediately
    _emitMCXRequest(userKey, deviceID);

    _emitTimer = Timer.periodic(_emitInterval, (_) {
      _emitMCXRequest(userKey, deviceID);
    });
  }

  /// Stop periodic emission
  void _stopPeriodicEmit() {
    _emitTimer?.cancel();
    _emitTimer = null;
  }

  /// Handle incoming data
  void _handleResponseData(dynamic data) {
    try {
      if (data is! Map<String, dynamic>) {
        developer.log('Ignored non-map MCX response: $data');
        return;
      }

      // Guard 1: Ensure this response is for MCX market
      final dr = (data['dataRelatedTo'] ?? data['category'])
              ?.toString()
              .toUpperCase() ??
          '';
      if (dr.isNotEmpty && dr != _dataRelatedTo.toUpperCase()) {
        developer.log('Ignored response for different market: $dr');
        return;
      }

      // Guard 2: Reject symbol-level (individual stock) responses
      final activity = data['activity']?.toString().toLowerCase() ?? '';
      if (activity.contains('stock-record') ||
          activity.contains('get-stock') ||
          (data['symbolKey'] != null &&
              data['symbolKey'].toString().isNotEmpty)) {
        developer.log(
            'Ignored symbol-level response (not a wishlist): activity=$activity');
        return;
      }

      final mcxData = MCXWishlistEntity.fromJson(data);

      // Guard 3: Only forward non-empty watchlist responses
      if (mcxData.mcxWatchlist != null && mcxData.mcxWatchlist!.isNotEmpty) {
        onDataReceived(mcxData);
        developer.log(
            '✓ MCX Wishlist Data Parsed: ${mcxData.mcxWatchlist!.length} items');
      } else {
        developer.log('Ignored empty MCX watchlist response');
      }
    } catch (e, stack) {
      developer.log('Parse MCX Response Failed: $e', stackTrace: stack);
      onError?.call('Parse error: $e');
    }
  }

  /// Centralized error handler
  void _handleError(String message, [StackTrace? stack]) {
    if (_isDisposed) return;

    _isConnecting = false;
    developer.log(message, name: 'MCX WebSocket Error', stackTrace: stack);
    onError?.call(message);
  }

  /// Get user key safely
  Future<String?> _getUserKey() async {
    try {
      final db = DatabaseService();
      final key = await db.getUserData(key: userIDKey);
      return key?.toString();
    } catch (e) {
      _handleError('Failed to get userKey: $e');
      return null;
    }
  }

  /// Get device ID safely
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

  /// Disconnect and clean up
  void disconnect() {
    if (_isDisposed) return;

    developer.log('Disconnecting MCX WebSocket...');
    _isDisposed = true;

    _stopPeriodicEmit();
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnecting = false;
  }

  /// Manual reconnect
  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_isDisposed) await connect();
  }

  /// Connection status
  bool get isConnected => _socket?.connected == true;

  /// Full dispose (call from parent)
  void dispose() => disconnect();
}
