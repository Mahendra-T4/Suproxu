// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/features/navbar/home/model/nfo_entity.dart';
// import 'package:trading_app/features/navbar/home/providers/state/nfo_state.dart';
// import 'package:trading_app/features/navbar/home/websocket/nfo_websocket.dart';

// final nfoWSProvider =
//     StateNotifierProvider.family<NFOWSNotifier, NFOState, String?>(
//   (ref, keyword) => NFOWSNotifier(keyword: keyword),
// );

// class NFOWSNotifier extends StateNotifier<NFOState> {
//   late final NFOWebSocket socket;
//   final String? keyword;

//   NFOWSNotifier({this.keyword}) : super(NFOState(nfoData: NFODataEntity())) {
//     initializeNFOWebSocket();
//   }

//   void initializeNFOWebSocket() {
//     socket = NFOWebSocket(
//       keyword: keyword,
//       onConnected: () {
//         state = state.copyWith(isConnected: true, isLoading: false);
//       },
//       onNFODataReceived: (data) {
//         state = state.copyWith(nfoData: data, isLoading: false);
//       },
//       onError: (error) {
//         state = state.copyWith(errorMessage: error, isLoading: false);
//       },
//       onDisconnected: () {
//         state = state.copyWith(isConnected: false);
//       },
//     );

//     socket.connect();
//   }

//   @override
//   void dispose() {
//     socket.disconnect();
//     super.dispose();
//   }

//   void reconnect() {
//     state = state.copyWith(
//       isLoading: true,
//     );
//     socket.disconnect();
//     socket.socket.dispose();
//     // initializeNFOWebSocket();
//   }
// }
