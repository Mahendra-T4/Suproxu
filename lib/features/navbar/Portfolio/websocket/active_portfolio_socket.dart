import 'dart:async';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';
import 'package:suproxu/features/navbar/Portfolio/model/active_portfolio_socket_model.dart';

class ActivePortfolioSocket {
  late IO.Socket socket;

  Function(ActivePortfolioSocketModel)? onDataReceived;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  String socketType;

  String? _uKey;
  String? _deviceID;

  ActivePortfolioSocket({
    this.onDataReceived,
    this.onError,
    this.onConnected,
    this.onDisconnected,
    this.socketType = 'active-portfolio-stock',
  });

  void _emitDataRequest() async {
    socket.emit('activity', {
      'activity': socketType == 'stock-search'
          ? 'get-stock-search'
          : 'active-portfolio-stock',

      'userKey': _uKey,
      'deviceID': _deviceID,
    });
  }

  void connect() async {
    DatabaseService databaseService = DatabaseService();
    _uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    _deviceID = androidInfo.id.toString();

    try {
      log('=== WebSocket Connection Start ===');
      log('User Key: $_uKey');
      log('Device ID: $_deviceID');

      final wsUrl = WebSocketConfig.socketUrl.replaceFirst(
        'https://',
        'wss://',
      );
      log('Connecting to WebSocket URL: $wsUrl');

      socket = IO.io(WebSocketConfig.socketUrl, {
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

      socket.onConnect((_) {
        print('Connected: ${socket.id}');
        onConnected?.call();

        // Initial emission
        _emitDataRequest();

        // Set up periodic emission every 1 second
        _emitTimer?.cancel();
        _emitTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
          if (socket.connected) {
            _emitDataRequest();
          }
        });
      });

      socket.onDisconnect((_) {
        print('Disconnected');

        onDisconnected?.call();
      });

      socket.on('response', (data) {
        try {
          log('========== WebSocket Response ==========');
          log('Response Type: ${data.runtimeType}');
          log('Active Portfolio Response Type: $data');
          if (data is Map<String, dynamic>) {
            final respActivity =
                data['activity'] as String? ??
                (data['response'] is Map<String, dynamic>
                    ? (data['response'] as Map<String, dynamic>)['activity']
                    : null);

            final currentExpectedActivity = socketType == 'stock-search'
                ? 'get-stock-search'
                : 'active-portfolio-stock';

            log('Response activity: $respActivity, ');

            if (respActivity != null &&
                respActivity != currentExpectedActivity) {
              log('Ignoring response for activity: $respActivity');
              return;
            }

            // Attempt to guard: only process responses that match the expected
            // activity and the stock category (dataRelatedTo) to avoid
            // cross-feed from other socket consumers (e.g. wishlist).
            if (data['response'] != null) {
              log('Response Keys: ${data.keys.toList()}');
              final activePortfolioData = ActivePortfolioSocketModel.fromJson(
                data,
              );
              onDataReceived?.call(activePortfolioData);
              log('Active Portfolio Data Received: $data');
              log('======================================');
            }

            // Now parse only if 'response' exists and appears to be the expected shape
            if (data['response'] != null) {
              log('Response Keys: ${data.keys.toList()}');
              final activePortfolioData = ActivePortfolioSocketModel.fromJson(
                data,
              );
              onDataReceived?.call(activePortfolioData);
              // log('MCX Record List Data Received: $data');
              log('======================================');
            }
          } else {
            onError?.call('Invalid response format');
            log(
              'Error: Invalid response format - Expected Map<String, dynamic>',
            );
            log('======================================');
          }
        } catch (e) {
          print('Error parsing response: $e');
          onError?.call('Error parsing response: $e');
        }
      });

      socket.onConnectError((err) {
        print('Connect error: $err');

        onError?.call('Connection error: $err');
      });

      socket.onError((err) {
        print('Socket error: $err');
        onError?.call('Socket error: $err');
      });

      socket.connect();
    } catch (e) {
      print('Error initializing socket: $e');
      onError?.call('Error initializing socket: $e');
    }
  }

  Timer? _emitTimer;

  void disconnect() {
    _emitTimer?.cancel();
    try {
      if (socket.connected) {
        socket.disconnect();
      }
    } catch (e) {
      print('Error while disconnecting socket: $e');
    }
    try {
      socket.dispose();
    } catch (e) {
      print('Error while disposing socket: $e');
    }
  }

  void dispose() {
    disconnect();
  }
}
