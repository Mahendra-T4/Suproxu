// import 'dart:async';
// import 'dart:developer' as developer;
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';
// import 'package:trading_app/core/config/web_socket_config.dart';
// import 'package:trading_app/core/service/repositorie/global_respo.dart';
// import 'package:trading_app/features/navbar/home/model/mcx_entity.dart';

// class MCXSocketServiceMain {
//   late IO.Socket socket;

//   Function(MCXDataEntity)? onDataReceived;
//   Function(String)? onError;
//   Function()? onConnected;
//   Function()? onDisconnected;
//   String? keyword;

//   MCXSocketServiceMain(
//       {this.onDataReceived,
//       this.onError,
//       this.onConnected,
//       this.onDisconnected,
//       this.keyword});

//   void connect() async {
//     DatabaseService databaseService = DatabaseService();
//     final uKey = await databaseService.getUserData(key: userIDKey);
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//     final deviceID = androidInfo.id.toString();
//     final stockList = await GlobalRepository.stocksMapper();
//     final stockName = stockList.stocks!
//         .firstWhere((stock) => stock.categoryName == 'MCX')
//         .categoryCode;

//     try {
//       socket = IO.io(WebSocketConfig.socketUrl, {
//         'path': WebSocketConfig.socketPath,
//         'transports': ['websocket'],
//         'autoConnect': true,
//         'reconnection': true,
//         'reconnectionDelay': 1000,
//         'reconnectionDelayMax': 5000,
//         'reconnectionAttempts': 5,
//         'timeout': 10000,
//         'auth': {'token': WebSocketConfig.authToken},
//       });

//       socket.onConnect((_) {
//         developer.log('Connected: ${socket.id}');
//         onConnected?.call();

//         void emitDataRequest() {
//           socket.emit('mcx-activity', {
//             'activity': 'get-stock-list',
//             'userKey': uKey,
//             'deviceID': deviceID,
//             'dataRelatedTo': stockName,
//             'keyword': keyword
//           });
//         }

//         emitDataRequest();

//         _emitTimer?.cancel();
//         _emitTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
//           if (socket.connected) {
//             emitDataRequest();
//           }
//         });
//       });

//       socket.onDisconnect((_) {
//         developer.log('Disconnected: ${socket.id}');
//         onDisconnected?.call();
//       });

//       socket.on('response', (data) {
//         try {
//           final jsonData = data as Map<String, dynamic>;
//           final mcxData = MCXDataEntity.fromJson(jsonData);
//           onDataReceived?.call(mcxData);
//           developer.log(
//               name: 'MCX Record List Data Received:', data.toString());
//         } catch (e) {
//           developer.log('Data parsing error: $e');
//           onError?.call('Data parsing error: $e');
//         }
//       });
//     } catch (e) {
//       developer.log('MCX Error: $e');
//       onError?.call('MCX Parsing Error: $e');
//     }
//   }

//   Timer? _emitTimer;

//   void disconnect() {
//     _emitTimer?.cancel();
//     socket.disconnect();
//   }
// }
