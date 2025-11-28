// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/features/navbar/home/model/mcx_entity.dart';
// import 'package:trading_app/features/navbar/home/websocket/mcx_websocket_service.dart';

// // State class to hold WebSocket data and status
// class MCXStockSearchState {
//   final bool isLoading;
//   final String? errorMessage;
//   final MCXDataEntity? data;
//   final bool isConnected;

//   const MCXStockSearchState({
//     this.isLoading = true,
//     this.errorMessage,
//     this.data,
//     this.isConnected = false,
//   });

//   MCXStockSearchState copyWith({
//     bool? isLoading,
//     String? errorMessage,
//     MCXDataEntity? data,
//     bool? isConnected,
//   }) {
//     return MCXStockSearchState(
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage ?? this.errorMessage,
//       data: data ?? this.data,
//       isConnected: isConnected ?? this.isConnected,
//     );
//   }
// }

// class MCXStockSearchNotifier extends StateNotifier<MCXStockSearchState> {
//   late SocketService socketService;
//   final String? keyword;
//   bool _disposed = false;
//   int _reconnectAttempts = 0;
//   static const int maxReconnectAttempts = 5;
//   Duration reconnectDelay = const Duration(seconds: 2);

//   MCXStockSearchNotifier({this.keyword}) : super(const MCXStockSearchState()) {
//     _initializeWebSocket();
//   }

//   void _initializeWebSocket() {
//     if (_disposed) return;

//     socketService = SocketService(
//       keyword: keyword,
//       socketType: 'stock-search', // Add an identifier for this connection
//       onDataReceived: (data) {
//         if (_disposed) return;
//         state = state.copyWith(
//           isLoading: false,
//           data: data,
//           errorMessage: null,
//           isConnected: true,
//         );
//         _reconnectAttempts = 0;
//       },
//       onError: (error) {
//         if (_disposed) return;
//         state = state.copyWith(
//           isLoading: false,
//           errorMessage: error,
//           isConnected: false,
//         );

//         if (_reconnectAttempts < maxReconnectAttempts) {
//           _reconnectAttempts++;
//           Future.delayed(reconnectDelay * _reconnectAttempts, () {
//             if (!_disposed) {
//               _initializeWebSocket();
//             }
//           });
//           reconnectDelay *= 2;
//         }
//       },
//       onConnected: () {
//         if (_disposed) return;
//         state = state.copyWith(
//           isConnected: true,
//           errorMessage: null,
//         );
//         _reconnectAttempts = 0;
//         reconnectDelay = const Duration(seconds: 2);
//       },
//       onDisconnected: () {
//         if (_disposed) return;
//         state = state.copyWith(
//           isConnected: false,
//           errorMessage: 'Connection lost. Trying to reconnect...',
//         );

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

//   void reconnect() {
//     state = state.copyWith(isLoading: true);
//     socketService.disconnect();
//     socketService.socket.dispose();
//     // _initializeWebSocket();
//   }
// }

// final mcxStockSearchProvider = StateNotifierProvider.family<
//     MCXStockSearchNotifier, MCXStockSearchState, String?>((ref, keyword) {
//   return MCXStockSearchNotifier(keyword: keyword);
// });
