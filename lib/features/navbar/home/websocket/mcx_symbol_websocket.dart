import 'dart:async';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';
import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';

class MCXSymbolWebSocketService {
  IO.Socket? _socket;
  Timer? _emitTimer;
  bool _isConnecting = false;
  bool _isDisposed = false;

  final Function(GetStockRecordEntity) onDataReceived;
  final Function(String)? onError;
  final Function()? onConnected;
  final Function()? onDisconnected;

  final String symbolKey;
  // final String categoryName;
  static const String _activity = 'get-stock-record';
  static const Duration _emitInterval = Duration(milliseconds: 200);

  MCXSymbolWebSocketService({
    required this.symbolKey,
    // required this.categoryName,
    required this.onDataReceived,
    this.onError,
    this.onConnected,
    this.onDisconnected,
  });

  /// Connect to WebSocket with full lifecycle management
  Future<void> connect() async {
    if (_isDisposed) return;
    if (_socket?.connected == true || _isConnecting) {
      developer.log(
        'Already connected or connecting. Skipping.',
        name: 'MCX WebSocket',
      );
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

      final socket = IO.io(
        wsUrl,
        IO.OptionBuilder()
            .setPath(WebSocketConfig.socketPath)
            .setTransports(['websocket'])
            .disableAutoConnect()
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
        developer.log(
          'MCX WebSocket Connected: ${socket.id}',
          name: 'MCX WebSocket',
        );
        onConnected?.call();

        _startPeriodicEmit(userKey, deviceID);
      });

      socket.onDisconnect((_) {
        if (_isDisposed) return;

        developer.log(
          'MCX WebSocket Disconnected: ${socket.id}',
          name: 'MCX WebSocket',
        );
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
        developer.log(
          'MCX WebSocket Reconnected after $attempt attempts',
          name: 'MCX WebSocket',
        );
        // Re-emit immediately on reconnect
        _emitMCXRequest(userKey, deviceID);
        _startPeriodicEmit(userKey, deviceID);
      });

      socket.onReconnectAttempt((attempt) {
        developer.log(
          'MCX WebSocket Reconnect Attempt: $attempt',
          name: 'MCX WebSocket',
        );
      });

      // Manually connect
      socket.connect();
    } catch (e, stack) {
      _handleError('Connection Setup Failed: $e', stack);
    } finally {
      if (_socket != null && !_socket!.connected) {
        _isConnecting = false;
      }
    }
  }

  /// Emit request for MCX symbol data
  void _emitMCXRequest(String userKey, String deviceID) {
    if (_socket?.connected != true || _isDisposed) return;

    final payload = {
      'activity': _activity,
      'userKey': userKey,
      'symbolKey': symbolKey,
      'deviceID': deviceID,
      'dataRelatedTo': 'MCX',
    };

    _socket!.emit('activity', payload);
    developer.log(
      'Emitted MCX Symbol Request: $payload',
      name: 'MCX WebSocket Emit',
    );
  }

  /// Start periodic emission
  void _startPeriodicEmit(String userKey, String deviceID) {
    _stopPeriodicEmit(); // Ensure no duplicate timers

    _emitTimer = Timer.periodic(_emitInterval, (_) {
      _emitMCXRequest(userKey, deviceID);
    });

    // Emit immediately on start
    _emitMCXRequest(userKey, deviceID);
  }

  /// Stop periodic emission
  void _stopPeriodicEmit() {
    _emitTimer?.cancel();
    _emitTimer = null;
  }

  /// Handle incoming response data
  void _handleResponseData(dynamic data) {
    try {
      if (data is! Map<String, dynamic>) {
        developer.log('Ignored non-map response: $data', name: 'MCX WebSocket');
        return;
      }

      // Guard 1: Ensure response is for MCX market
      final dr =
          (data['dataRelatedTo'] ?? data['category'])
              ?.toString()
              .toUpperCase() ??
          '';
      if (dr.isNotEmpty && dr != 'MCX') {
        developer.log(
          'Ignored response for different market: $dr',
          name: 'MCX WebSocket',
        );
        return;
      }

      developer.log('✓ MCX Wishlist Data Response: $data');

      // Guard 2: Check if response is for symbol-level activity (not wishlist)
      final activity = data['activity']?.toString().toLowerCase() ?? '';
      if (activity.isNotEmpty && activity.contains('wishlist')) {
        developer.log(
          'Ignored wishlist response on symbol page: $activity',
          name: 'MCX WebSocket',
        );
        return;
      }

      final mcxData = GetStockRecordEntity.fromJson(data);

      // Guard 3: Only forward if response contains THIS specific symbol
      final hasMatchingSymbol =
          mcxData.response.isNotEmpty &&
          mcxData.response.any((r) => r.symbolKey.trim() == symbolKey.trim());

      if (!hasMatchingSymbol) {
        developer.log(
          'Ignored MCX response (symbol=$symbolKey not in response): ${mcxData.response.map((r) => r.symbolKey).join(",")}',
          name: 'MCX WebSocket',
        );
        return;
      }

      onDataReceived(mcxData);
      developer.log(
        '✓ MCX Symbol Data Parsed & Sent: symbolKey=$symbolKey',
        name: 'MCX WebSocket',
      );
    } catch (e, stack) {
      developer.log(
        'Failed to parse MCX response: $e',
        name: 'MCX WebSocket',
        stackTrace: stack,
      );
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

  /// Disconnect and clean up all resources
  void disconnect() {
    if (_isDisposed) return;

    developer.log('Disconnecting MCX WebSocket...', name: 'MCX WebSocket');
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
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_isDisposed) {
      await connect();
    }
  }

  /// Check connection status
  bool get isConnected => _socket?.connected == true;

  /// Dispose (call from parent widget/state)
  void dispose() => disconnect();
}
