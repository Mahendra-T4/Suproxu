// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/features/navbar/home/providers/state/nfo_symbol_state.dart';
// import 'package:trading_app/features/navbar/home/websocket/nfo_symbol_ws.dart';

// final nfoSymbolWSProvider =
//     StateNotifierProvider.family<NfoSymbolWsNotifier, NfoSymbolStatus, String>(
//         (ref, symbolKey) => NfoSymbolWsNotifier(symbolKey: symbolKey));

// class NfoSymbolWsNotifier extends StateNotifier<NfoSymbolStatus> {
//   final String symbolKey;
//   late final NFOSymbolWebSocket webSocket;
//   NfoSymbolWsNotifier({required this.symbolKey}) : super(NfoSymbolStatus()) {
//     _initializeWebSocket();
//   }

//   void _initializeWebSocket() {
//     webSocket = NFOSymbolWebSocket(
//       symbolKey: symbolKey,
//       onConnected: () {
//         state = state.copyWith(isConnected: true, errorMessage: null);
//       },
//       onDisconnected: () {
//         state = state.copyWith(isConnected: false);
//       },
//       onError: (error) {
//         state = state.copyWith(errorMessage: error);
//       },
//       symbolDataReceived: (data) {
//         state =
//             state.copyWith(record: data, isLoading: false, errorMessage: null);
//       },
//     );

//     webSocket.connect();
//   }

//   void reconnect() {
//     state = state.copyWith(isLoading: true, errorMessage: null);
//     webSocket.disconnect();
//     //  webSocket.socket.dispose();
//     // _initializeWebSocket();
//   }
// }
