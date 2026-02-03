import 'dart:async';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/config/web_socket_config.dart';
import 'package:suproxu/core/service/repositorie/global_respo.dart';
import 'package:suproxu/features/navbar/home/model/nfo_entity.dart';
import 'package:suproxu/features/navbar/home/model/stock_list_entity.dart';

class NFOWebSocket {
  late IO.Socket socket;

  Function(NFODataEntity)? onDataReceived;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  String? keyword;
  String socketType;

  NFOWebSocket({
    this.onDataReceived,
    this.onError,
    this.onConnected,
    this.onDisconnected,
    this.keyword,
    this.socketType = 'get-stock-list',
  });

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
      log('Found stock category: $stockName');
    } catch (e) {
      log('Error getting stock category: $e');
      stockName = 'NFO';
    }
    final expectedActivity = socketType == 'stock-search'
        ? 'get-stock-search'
        : 'get-stock-list';

    try {
      log('User Key: $uKey');
      log('Device ID: $deviceID');
      log('Stock Name: $stockName');
      log('Socket Type: $socketType');
      log('Keyword: $keyword');

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

        // Function to emit data request
        void emitDataRequest() {
          socket.emit('activity', {
            'activity': socketType == 'stock-search'
                ? 'get-stock-search'
                : 'get-stock-list',
            'userKey': uKey,
            'deviceID': deviceID,
            'dataRelatedTo': stockName,
            'keyword': keyword,
          });
        }

        // Initial emission
        emitDataRequest();

        // Set up periodic emission every 200ms
        _emitTimer?.cancel();
        _emitTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
          if (socket.connected) {
            emitDataRequest();
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
          if (data is Map<String, dynamic>) {
            // Attempt to guard: only process responses that match the expected
            // activity and the stock category (dataRelatedTo) to avoid
            // cross-feed from other socket consumers (e.g. wishlist).
            final respActivity =
                data['activity'] as String? ??
                (data['response'] is Map<String, dynamic>
                    ? (data['response'] as Map<String, dynamic>)['activity']
                    : null);
            final respDataRelatedTo =
                data['dataRelatedTo'] as String? ??
                (data['response'] is Map<String, dynamic>
                    ? (data['response']
                          as Map<String, dynamic>)['dataRelatedTo']
                    : null);

            log(
              'Response activity: $respActivity, dataRelatedTo: $respDataRelatedTo',
            );

            if (respActivity != null && respActivity != expectedActivity) {
              log('Ignoring response for activity: $respActivity');
              return;
            }

            if (respDataRelatedTo != null && respDataRelatedTo != stockName) {
              log('Ignoring response for dataRelatedTo: $respDataRelatedTo');
              return;
            }

            // Now parse only if 'response' exists and appears to be the expected shape
            if (data['response'] != null) {
              log('Response Keys: ${data.keys.toList()}');
              final nfoData = NFODataEntity.fromJson(data);
              onDataReceived?.call(nfoData);
              log('NFO Record List Data Received: $data');
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
