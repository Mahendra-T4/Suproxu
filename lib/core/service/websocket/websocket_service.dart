// import 'dart:async';
// import 'dart:developer' as developer;
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';
// import 'package:trading_app/core/config/web_socket_config.dart';
// import 'package:trading_app/core/service/repositorie/global_respo.dart';

// class WebSocketService {
//   late IO.Socket socket;

//   Function(dynamic)? onDataReceived;
//   Function(String)? onError;
//   Function()? onConnected;
//   Function()? onDisconnected;
//   String socketType;
//   String? relatedTo;
//   dynamic model;

//   WebSocketService({
//     required this.onDataReceived,
//     this.onError,
//     this.onConnected,
//     this.onDisconnected,
//     this.relatedTo,
//     this.model,
//     this.socketType = 'default-socket-type',
//   });

//   void connect() async {
//     DatabaseService databaseService = DatabaseService();
//     final uKey = await databaseService.getUserData(key: userIDKey);
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//     final deviceID = androidInfo.id.toString();
//     final stockList = await GlobalRepository.stocksMapper();
//     final stockName = stockList.stocks!
//         .firstWhere((stock) => stock.categoryName == relatedTo)
//         .categoryCode;
//     // Implementation for connecting to WebSocket
//     try {
//       developer.log('=== WebSocket Connection Start ===');
//       developer.log('User Key: $uKey');
//       developer.log('Device ID: $deviceID');
//       developer.log('Stock Name: $stockName');
//       developer.log('Socket Type: $socketType');
//       // developer.log('Keyword: $keyword');

//       final wsUrl =
//           WebSocketConfig.socketUrl.replaceFirst('https://', 'wss://');
//       developer.log('Connecting to WebSocket URL: $wsUrl');

//       socket = IO.io(wsUrl, {
//         'path': WebSocketConfig.socketPath,
//         'transports': ['websocket'],
//         'autoConnect': true,
//         'reconnection': true,
//         'reconnectionDelay': 1000,
//         'reconnectionDelayMax': 5000,
//         'reconnectionAttempts': 5,
//         'timeout': 10000,
//         'auth': {'token': WebSocketConfig.authToken},
//         'extraHeaders': {
//           'Authorization': 'Bearer ${WebSocketConfig.authToken}'
//         },
//       });

//       socket.onConnect((_) {
//         developer.log('WebSocket connected', name: 'WebSocketService');
//         onConnected?.call();

//         void emitDataRequest() {
//           socket.emit('activity', {
//             'activity': socketType == 'stock-search-data'
//                 ? 'get-stock-search-data'
//                 : 'get-wishlist-stocks',
//             'userKey': uKey.toString(),
//             'deviceID': deviceID.toString(),
//             'dataRelatedTo': stockName.toString(),
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
//         developer.log('WebSocket disconnected', name: 'WebSocketService');
//         onDisconnected?.call();
//       });

//       socket.onError((data) {
//         developer.log('WebSocket Error: $data', name: 'WebSocketService');
//         onError?.call(data.toString());
//       });

//       socket.on(
//         'activity',
//         (data) {
//           developer.log('WebSocket Activity: $data', name: 'WebSocketService');

//           if (data is Map<String, dynamic>) {
//             if (data['activity'] == 'get-wishlist-stocks') {
//               final stockData = model.fromJson(data);
//               onDataReceived?.call(stockData);
//             } else {
//               developer.log('Unhandled activity type: ${data['activity']}',
//                   name: 'WebSocketService');
//               onError?.call('Unhandled activity type: ${data['activity']}');
//             }
//           } else {
//             developer.log('Invalid data format received',
//                 name: 'WebSocketService');
//             onError?.call('Invalid data format received');
//           }
//         },
//       );
//     } catch (e) {
//       developer.log('WebSocket connection error: $e', name: 'WebSocketService');
//       onError?.call(e.toString());
//     }
//   }

//   Timer? _emitTimer;

//   void disconnect() {
//     _emitTimer?.cancel();
//     socket.disconnect();
//     socket.dispose();
//   }
// }
