import 'package:suproxu/features/navbar/home/model/nfo_entity.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';
import 'package:suproxu/core/service/repositorie/global_respo.dart';
import 'package:suproxu/features/navbar/home/model/stock_list_entity.dart';

class NFOWebSocket {
  late IO.Socket socket;

  Function(NFODataEntity) onNFODataReceived;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  String? keyword;
  bool socketType = false;

  NFOWebSocket({
    required this.onNFODataReceived,
    this.onError,
    this.onConnected,
    this.onDisconnected,
    this.keyword,
  }) {
    connect();
  }

  void connect() async {
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    String stockName;
    try {
      final stockList = await GlobalRepository.stocksMapper();
      final nfoStock = stockList.stocks?.firstWhere(
        (stock) => stock.categoryName == 'NFO',
        orElse: () =>
            Stocks(categoryID: 0, categoryName: 'NFO', categoryCode: 'NFO'),
      );
      stockName = nfoStock?.categoryCode ?? 'NFO';

      developer.log('Found stock category: $stockName');
    } catch (e) {
      developer.log('Error getting stock category: $e');
      stockName = 'NFO';
    }

    try {
      developer.log('=== WebSocket Connection Start ===');
      developer.log('User Key: $uKey');
      developer.log('Device ID: $deviceID');
      developer.log('Stock Name: $stockName');

      final wsUrl = WebSocketConfig.socketUrl.replaceFirst(
        'https://',
        'wss://',
      );
      developer.log('Connecting to WebSocket URL: $wsUrl');

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
        developer.log('Connected: ${socket.id}');
        onConnected?.call();

        void emitNFODataRequest() {
          socket.emit('activity', {
            'activity': socketType ? '' : 'get-stock-list',
            'userKey': uKey.toString(),
            'deviceID': deviceID.toString(),
            'dataRelatedTo': 'NFO',
            'keyword': keyword,
          });
        }

        emitNFODataRequest();

        _emitTimer?.cancel();
        _emitTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
          emitNFODataRequest();
        });
      });

      socket.onDisconnect((_) {
        developer.log('Disconnected: ${socket.id}');
        onDisconnected?.call();
      });

      socket.onError((data) {
        developer.log('WebSocket Error: $data');
        onError?.call(data.toString());
      });

      socket.on('response', (data) {
        try {
          if (data is Map<String, dynamic>) {
            final nfoDataEntity = NFODataEntity.fromJson(data);
            developer.log('NFO Data Received: ${nfoDataEntity}');
            onNFODataReceived(nfoDataEntity);
          } else {
            developer.log('Unexpected data format: $data');
            onError?.call('Unexpected data format received.');
          }
        } catch (e) {
          developer.log('NFO Data parsing error: $e');
          onError?.call('NFO Data parsing error: $e');
        }
      });
    } catch (error) {
      developer.log('WebSocket Connection Error: $error');
      onError?.call(error.toString());
    }
  }

  Timer? _emitTimer;

  void disconnect() {
    _emitTimer?.cancel();
    socket.disconnect();
  }

  void dispose() {
    disconnect();
    socket.dispose();
  }
}
