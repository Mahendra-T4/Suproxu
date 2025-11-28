// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/features/navbar/home/model/get_stock_record_entity.dart';
// import 'package:trading_app/features/navbar/home/websocket/mcx_symbol_websocket.dart';

// class Param {
//   final String symbolKey;
//   final String categoryName;

//   Param({required this.symbolKey, required this.categoryName});
// }

// final mcxRecordProvider =
//     StateNotifierProvider.family<McxSymbolNotifier, MCXWebSocketState, Param?>(
//         (ref, data) {
//   return McxSymbolNotifier(
//     symbolKey: data!.symbolKey,
//     categoryName: data.categoryName,
//   );
// });

// class MCXWebSocketState {
//   final bool isLoading;
//   final String? errorMessage;
//   final GetStockRecordEntity? data;
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
//     GetStockRecordEntity? data,
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

// class McxSymbolNotifier extends StateNotifier<MCXWebSocketState> {
//   late MCXSymbolWebSocketService _webSocket;
//   final String symbolKey;
//   final String categoryName;
//   McxSymbolNotifier({required this.symbolKey, required this.categoryName})
//       : super(const MCXWebSocketState());

//   void initMCXSymbolWebSocket() {
//     _webSocket = MCXSymbolWebSocketService(
//       symbolKey: symbolKey,
//       categoryName: categoryName,
//       onDataReceived: (data) {
//         state =
//             state.copyWith(isLoading: false, data: data, errorMessage: null);
//       },
//       onError: (error) {
//         state = state.copyWith(
//             isLoading: false, errorMessage: error, isConnected: false);
//       },
//       onConnected: () {
//         state = state.copyWith(isConnected: true, errorMessage: null);
//       },
//       onDisconnected: () {
//         state = state.copyWith(
//           isConnected: false,
//           errorMessage: 'Connection lost. Trying to reconnect...',
//         );
//       },
//     );

//     _webSocket.connect();
//   }

//   @override
//   void dispose() {
//     _webSocket.disconnect();
//     super.dispose();
//   }

//   void reconnect() {
//     state = state.copyWith(isLoading: true);
//     _webSocket.disconnect();
//     initMCXSymbolWebSocket();
//   }
// }
