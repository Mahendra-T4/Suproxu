// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/features/navbar/home/model/mcx_entity.dart';
// import 'package:trading_app/features/navbar/home/websocket/mcx_websocket_service.dart';
// import 'package:trading_app/features/navbar/home/websocket/mcx_websocket_service_main.dart';

// // final mcxDataProvider = StreamProvider<MCXDataEntity>((ref) {
// //   final controller = StreamController<MCXDataEntity>();
// //   final socketService = SocketService(
// //     onDataReceived: (receivedData) {
// //       if (!controller.isClosed) {
// //         controller.add(receivedData);
// //       }
// //     },
// //     onError: (error) {
// //       if (!controller.isClosed) {
// //         controller.addError(error);
// //       }
// //     },
// //     onConnected: () {
// //       // Optional: You can emit an initial state here if needed
// //     },
// //     onDisconnected: () {
// //       // Optional: You can emit a disconnected state here if needed
// //     },
// //   );

// //   socketService.connect();

// //   // Clean up when the provider is disposed
// //   ref.onDispose(() {
// //     socketService.disconnect();
// //     controller.close();
// //   });

// //   return controller.stream;
// // });

// final mcxAllStocksProvider = StateNotifierProvider.family<MCXAllStocksNotifier,
//     MCXWebSocketState, String?>((ref, keyword) {
//   return MCXAllStocksNotifier(keyword: keyword);
// });

// // State class to hold WebSocket data and status
// class MCXWebSocketState {
//   final bool isLoading;
//   final String? errorMessage;
//   final MCXDataEntity? data;
//   final bool isConnected;

//   const MCXWebSocketState({
//     this.isLoading = true,
//     this.errorMessage,
//     this.data,
//     this.isConnected = false,
//   });

//   MCXWebSocketState copyWith({
//     bool? isLoading,
//     String? errorMessage,
//     MCXDataEntity? data,
//     bool? isConnected,
//   }) {
//     return MCXWebSocketState(
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage ?? this.errorMessage,
//       data: data ?? this.data,
//       isConnected: isConnected ?? this.isConnected,
//     );
//   }
// }

// // WebSocket notifier to manage state for all MCX stocks
// class MCXAllStocksNotifier extends StateNotifier<MCXWebSocketState> {
//   late SocketService socketService;
//   final String? keyword;
//   bool _disposed = false;
//   int _reconnectAttempts = 0;
//   static const int maxReconnectAttempts = 5;
//   Duration reconnectDelay = const Duration(seconds: 2);

//   MCXAllStocksNotifier({this.keyword}) : super(const MCXWebSocketState()) {
//     _initializeWebSocket();
//   }

//   void _initializeWebSocket() {
//     if (_disposed) return;

//     socketService = SocketService(
//       keyword: keyword,
//       socketType: 'get-stock-list', // Explicitly set the socket type
//       onDataReceived: (data) {
//         if (_disposed) return;
//         if (data.response != null) {
//           state = state.copyWith(
//             isLoading: false,
//             data: data,
//             errorMessage: null,
//             isConnected: true,
//           );
//           _reconnectAttempts = 0; // Reset on successful data
//           print('Received MCX data with ${data.response?.length ?? 0} items');
//         } else {
//           state = state.copyWith(
//             isLoading: false,
//             errorMessage: 'No data available',
//             isConnected: true,
//           );
//         }
//       },
//       onError: (error) {
//         if (_disposed) return;
//         state = state.copyWith(
//           isLoading: false,
//           errorMessage: error,
//           isConnected: false,
//         );

//         // Attempt reconnection with exponential backoff
//         if (_reconnectAttempts < maxReconnectAttempts) {
//           _reconnectAttempts++;
//           Future.delayed(reconnectDelay * _reconnectAttempts, () {
//             if (!_disposed) {
//               _initializeWebSocket();
//             }
//           });
//           reconnectDelay *= 2; // Exponential backoff
//         }
//       },
//       onConnected: () {
//         if (_disposed) return;
//         state = state.copyWith(
//           isConnected: true,
//           errorMessage: null,
//         );
//         _reconnectAttempts = 0; // Reset on successful connection
//         reconnectDelay = const Duration(seconds: 2); // Reset delay
//       },
//       onDisconnected: () {
//         if (_disposed) return;
//         state = state.copyWith(
//           isConnected: false,
//           errorMessage: 'Connection lost. Trying to reconnect...',
//         );

//         // Attempt reconnection with exponential backoff
//         if (_reconnectAttempts < maxReconnectAttempts) {
//           _reconnectAttempts++;
//           Future.delayed(reconnectDelay * _reconnectAttempts, () {
//             if (!_disposed) {
//               _initializeWebSocket();
//             }
//           });
//         }
//       },
//     );
//     socketService.connect();
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     socketService.disconnect();
//     super.dispose();
//   }

//   // Method to manually reconnect if needed
//   void reconnect() {
//     state = state.copyWith(isLoading: true);
//     socketService.disconnect();
//      socketService.socket.dispose();
//     // _initializeWebSocket();
//   }
// }
