import 'dart:async';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';

/// Singleton MCX WebSocket service shared by all MCX pages
class SharedMCXWebSocketService {
  static final SharedMCXWebSocketService _instance =
      SharedMCXWebSocketService._internal();

  factory SharedMCXWebSocketService() {
    return _instance;
  }

  SharedMCXWebSocketService._internal();

  IO.Socket? _socket;
  Timer? _emitTimer;
  bool _isConnecting = false;
  String? _userKey;
  String? _deviceID;

  // Track subscribers
  final Set<String> _subscribers = {};

  static const Duration _emitInterval = Duration(milliseconds: 200);
  static const String _activity = 'get-wishlist-stocks';
  static const String _dataRelatedTo = 'MCX';

  /// Register a page/service as a subscriber
  void addSubscriber(String subscriberId) {
    _subscribers.add(subscriberId);
    developer.log(
      'MCX Subscriber added: $subscriberId. Total: ${_subscribers.length}',
    );
  }

  /// Unregister a page/service
  void removeSubscriber(String subscriberId) {
    _subscribers.remove(subscriberId);
    developer.log(
      'MCX Subscriber removed: $subscriberId. Total: ${_subscribers.length}',
    );
  }

  /// Connect to WebSocket (only connects if not already connected)
  Future<void> connect() async {
    if (_socket?.connected == true || _isConnecting) {
      developer.log(
        'MCX Shared WS: Already connected or connecting. Skipping.',
      );
      return;
    }

    _isConnecting = true;

    try {
      final userKey = await _getUserKey();
      final deviceID = await _getDeviceID();
      if (userKey == null || deviceID == null) {
        developer.log('MCX Shared WS: Missing userKey or deviceID');
        _isConnecting = false;
        return;
      }

      _userKey = userKey;
      _deviceID = deviceID;

      final wsUrl = WebSocketConfig.socketUrl.replaceFirst(
        'https://',
        'wss://',
      );

      final socket = IO.io(
        wsUrl,
        IO.OptionBuilder()
            .setPath(WebSocketConfig.socketPath)
            .setTransports(['websocket'])
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setTimeout(10000)
            .setAuth({'token': WebSocketConfig.authToken})
            .build(),
      );

      _socket = socket;

      socket.onConnect((_) {
        _isConnecting = false;
        developer.log('MCX Shared WebSocket Connected: ${socket.id}');
        // Start periodic emission when connected
        _startPeriodicEmit();
      });

      socket.onDisconnect((_) {
        developer.log('MCX Shared WebSocket Disconnected');
        _stopPeriodicEmit();
      });

      socket.onConnectError((err) {
        developer.log('MCX Shared Connect Error: $err');
        _isConnecting = false;
      });

      socket.onError((err) {
        developer.log('MCX Shared Socket Error: $err');
        _isConnecting = false;
      });

      socket.onReconnect((attempt) {
        developer.log(
          'MCX Shared WebSocket Reconnected after $attempt attempts',
        );
        _startPeriodicEmit();
      });
    } catch (e) {
      developer.log('Error connecting MCX Shared WebSocket: $e');
      _isConnecting = false;
    }
  }

  /// Start periodic emission of wishlist request
  void _startPeriodicEmit() {
    _stopPeriodicEmit();

    if (_userKey != null && _deviceID != null) {
      // Emit immediately
      _emitWishlistRequest(_userKey!, _deviceID!);

      _emitTimer = Timer.periodic(_emitInterval, (_) {
        _emitWishlistRequest(_userKey!, _deviceID!);
      });
    }
  }

  /// Stop periodic emission
  void _stopPeriodicEmit() {
    _emitTimer?.cancel();
    _emitTimer = null;
  }

  /// Emit MCX wishlist request
  void _emitWishlistRequest(String userKey, String deviceID) {
    if (_socket?.connected != true) return;

    try {
      final payload = {
        'activity': _activity,
        'userKey': userKey,
        'deviceID': deviceID,
        'dataRelatedTo': _dataRelatedTo,
      };

      _socket!.emit('activity', payload);
      developer.log('Emitted MCX Wishlist Request: $payload');
    } catch (e) {
      developer.log('Error emitting MCX request: $e');
    }
  }

  /// Register listener for specific event
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// Remove listener
  void off(String event) {
    _socket?.off(event);
  }

  /// Check connection status
  bool get isConnected => _socket?.connected == true;

  /// Get subscriber count (useful for debugging)
  int get subscriberCount => _subscribers.length;

  /// Safely get user key
  Future<String?> _getUserKey() async {
    try {
      final databaseService = DatabaseService();
      final key = await databaseService.getUserData(key: userIDKey);
      return key?.toString();
    } catch (e) {
      developer.log('Failed to get userKey: $e');
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
      developer.log('Failed to get deviceID: $e');
      return null;
    }
  }

  /// Dispose the singleton (only call on app close)
  void dispose() {
    developer.log('Disposing MCX Shared WebSocket');
    _subscribers.clear();
    _stopPeriodicEmit();
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnecting = false;
    _userKey = null;
    _deviceID = null;
  }
}
