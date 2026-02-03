import 'dart:async';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';
import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';

class NFOSymbolWebSocket {
  IO.Socket? _socket;
  Timer? _emitTimer;
  bool _isConnecting = false;
  bool _isDisposed = false;

  final Function(GetStockRecordEntity) onDataReceived;
  final Function(String)? onError;
  final Function()? onConnected;
  final Function()? onDisconnected;

  final String symbolKey;
  final String categoryName = 'NFO';
  static const String _activity = 'get-stock-record';
  static const Duration _emitInterval = Duration(milliseconds: 200);

  NFOSymbolWebSocket({
    required this.symbolKey,
    required this.onDataReceived,
    this.onError,
    this.onConnected,
    this.onDisconnected,
  });

  /// Connect to WebSocket with full lifecycle management
  Future<void> connect() async {
    // Allow reconnection if socket was disposed
    if (_isDisposed && _socket == null) {
      _isDisposed = false;
      _isConnecting = false;
    }

    if (_isDisposed) return;
    if (_socket?.connected == true || _isConnecting) {
      developer.log(
        'Already connected or connecting. Skipping.',
        name: 'NFO WebSocket',
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
          'NFO WebSocket Connected: ${socket.id}',
          name: 'NFO WebSocket',
        );
        onConnected?.call();

        _startPeriodicEmit(userKey, deviceID);
      });

      socket.onDisconnect((_) {
        if (_isDisposed) return;

        developer.log(
          'NFO WebSocket Disconnected: ${socket.id}',
          name: 'NFO WebSocket',
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
          'NFO WebSocket Reconnected after $attempt attempts',
          name: 'NFO WebSocket',
        );
        // Re-emit immediately on reconnect
        _emitNFORequest(userKey, deviceID);
        _startPeriodicEmit(userKey, deviceID);
      });

      socket.onReconnectAttempt((attempt) {
        developer.log(
          'NFO WebSocket Reconnect Attempt: $attempt',
          name: 'NFO WebSocket',
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

  /// Emit request for NFO symbol data
  void _emitNFORequest(String userKey, String deviceID) {
    if (_socket?.connected != true || _isDisposed) return;

    final payload = {
      'activity': _activity,
      'userKey': userKey,
      'symbolKey': symbolKey,
      'deviceID': deviceID,
      'dataRelatedTo': 'NFO',
    };

    _socket!.emit('activity', payload);
    developer.log(
      'Emitted NFO Symbol Request: $payload',
      name: 'NFO WebSocket Emit',
    );
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
      if (data is! Map<String, dynamic>) {
        developer.log('Ignored non-map response: $data', name: 'NFO WebSocket');
        return;
      }

      // Guard 1: Ensure response is for NFO market
      final dr =
          (data['dataRelatedTo'] ?? data['category'])
              ?.toString()
              .toUpperCase() ??
          '';
      if (dr.isNotEmpty && dr != 'NFO') {
        developer.log(
          'Ignored response for different market: $dr',
          name: 'NFO WebSocket',
        );
        return;
      }

      // Guard 2: Check if response is for symbol-level activity (not wishlist)
      final activity = data['activity']?.toString().toLowerCase() ?? '';
      if (activity.isNotEmpty && activity.contains('wishlist')) {
        developer.log(
          'Ignored wishlist response on symbol page: $activity',
          name: 'NFO WebSocket',
        );
        return;
      }

      final NFOData = GetStockRecordEntity.fromJson(data);

      // Guard 3: Flexible matching — check several identifier fields to avoid false negatives
      bool matchesRecord(dynamic r) {
        try {
          final rk = (r.symbolKey ?? '').toString().trim();
          final rs = (r.symbol ?? '').toString().trim();
          final rr = (r.receivedSymbol ?? '').toString().trim();
          final rn = (r.symbolName ?? '').toString().trim();
          final target = symbolKey.trim();

          if (rk.isNotEmpty && rk == target) return true;
          if (rs.isNotEmpty && rs == target) return true;
          if (rr.isNotEmpty && rr == target) return true;
          if (rn.isNotEmpty && rn == target) return true;

          // Substring or prefix matches (tolerate minor formatting differences)
          if (rk.isNotEmpty && rk.contains(target)) return true;
          if (rs.isNotEmpty && rs.contains(target)) return true;
          if (rr.isNotEmpty && rr.contains(target)) return true;
          if (rn.isNotEmpty && rn.contains(target)) return true;
        } catch (_) {}
        return false;
      }

      final hasMatchingSymbol =
          NFOData.response.isNotEmpty &&
          NFOData.response.any((r) => matchesRecord(r));

      if (!hasMatchingSymbol) {
        developer.log(
          'Ignored NFO response (symbol=$symbolKey not in response): ${NFOData.response.map((r) => r.symbolKey).join(",")}',
          name: 'NFO WebSocket',
        );
        return;
      }

      onDataReceived(NFOData);
      developer.log(
        '✓ NFO Symbol Data Parsed & Sent: symbolKey=$symbolKey',
        name: 'NFO WebSocket',
      );
    } catch (e, stack) {
      developer.log(
        'Failed to parse NFO response: $e',
        name: 'NFO WebSocket',
        stackTrace: stack,
      );
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

  /// Disconnect and clean up all resources
  void disconnect() {
    if (_isDisposed) return;

    developer.log('Disconnecting NFO WebSocket...', name: 'NFO WebSocket');
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

  /// Reset disposed state (for navigation scenarios)
  void reset() {
    if (_isDisposed && _socket == null) {
      developer.log(
        'NFO WebSocket: Resetting disposed state for reconnection',
        name: 'NFO WebSocket',
      );
      _isDisposed = false;
    }
  }

  /// Check connection status
  bool get isConnected => _socket?.connected == true;

  /// Dispose (call from parent widget/state)
  void dispose() => disconnect();
}
