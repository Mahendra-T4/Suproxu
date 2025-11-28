// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/features/navbar/home/model/mcx_entity.dart';
// import 'package:trading_app/features/navbar/home/websocket/mcx_websocket_service.dart';
// import 'package:trading_app/features/navbar/home/websocket/mcx_websocket_service_main.dart';

// final mcxStockListProvider = StateNotifierProvider.family<MCXWebSocketNotifier,
//     MCXWebSocketState, String?>((ref, keyword) {
//   return MCXWebSocketNotifier(keyword: keyword);
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

// // WebSocket notifier to manage state
// class MCXWebSocketNotifier extends StateNotifier<MCXWebSocketState> {
//   late SocketService socketService;
//   final String? keyword;

//   MCXWebSocketNotifier({this.keyword}) : super(const MCXWebSocketState()) {
//     _initializeWebSocket();
//   }

//   void _initializeWebSocket() {
//     socketService = SocketService(
//       keyword: keyword,
//       onDataReceived: (data) {
//         state = state.copyWith(
//           isLoading: false,
//           data: data,
//           errorMessage: null,
//         );
//       },
//       onError: (error) {
//         state = state.copyWith(
//           isLoading: false,
//           errorMessage: error,
//           isConnected: false,
//         );
//       },
//       onConnected: () {
//         state = state.copyWith(
//           isConnected: true,
//           errorMessage: null,
//         );
//       },
//       onDisconnected: () {
//         state = state.copyWith(
//           isConnected: false,
//           errorMessage: 'Connection lost. Trying to reconnect...',
//         );
//       },
//     );
//     socketService.connect();
//   }

//   @override
//   void dispose() {
//     socketService.disconnect();
//     super.dispose();
//   }

//   // Method to manually reconnect if needed
//   void reconnect() {
//     state = state.copyWith(isLoading: true);
//     socketService.disconnect();
//     //  socketService.socket.dispose();
//     // _initializeWebSocket();
//   }
// }

// // Provider for the WebSocket service
