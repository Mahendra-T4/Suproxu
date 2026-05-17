import 'dart:async';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';

class MCXWishlistWebSocketService {
  late IO.Socket socket;

  Function(MCXWishlistEntity)? onDataReceived;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  String? keyword;

  MCXWishlistWebSocketService({
    this.onDataReceived,
    this.onError,
    this.onConnected,
    this.onDisconnected,
    this.keyword,
  });

  void connect() async {
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
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
      });

      socket.onConnect((_) {
        log('Connected: ${socket.id}');
        onConnected?.call();

        void emitDataRequest() {
          socket.emit('activity', {
            'activity': 'get-wishlist-stocks',
            'userKey': uKey.toString(),
            "deviceID": deviceID.toString(),
            'dataRelatedTo': 'MCX',
          });
        }

        emitDataRequest();

        _emitTimer?.cancel();

        _emitTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
          emitDataRequest();
        });
      });

      socket.onDisconnect((_) {
        log('Disconnected: ${socket.id}');
        onDisconnected?.call();
      });

      socket.on('response', (data) {
        try {
          if (data is Map<String, dynamic>) {
            // Only process if this response is for wishlist
            if (data['activity'] == 'get-wishlist-stocks') {
              final mcxData = MCXWishlistEntity.fromJson(data);
              onDataReceived?.call(mcxData);
              log('MCX Wishlist Data Received: ${data.toString()}');
            }
          } else {
            log('MCX Wishlist Data Error: Invalid data format');
            onError?.call('Invalid data format received');
          }
        } catch (e) {
          log('MCX Wishlist Data Error: $e');
          onError?.call(e.toString());
        }
      });
    } catch (e) {
      log('MCX Wishlist Socket Connection Error: $e');
      onError?.call(e.toString());
    }
  }

  Timer? _emitTimer;

  void disconnect() {
    _emitTimer?.cancel();
    socket.disconnect();
  }
}
