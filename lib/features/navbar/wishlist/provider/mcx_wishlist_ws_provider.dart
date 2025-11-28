// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/features/navbar/wishlist/provider/state/mcx_wishlist_states.dart';
// import 'package:trading_app/features/navbar/wishlist/websocket/mcx_wishlist_websocket.dart';

// final mcxWishlistWSProvider =
//     StateNotifierProvider<McxWishlistWSNotifier, MCXWishlistWebSocketState>(
//         (ref) {
//   return McxWishlistWSNotifier();
// });

// class McxWishlistWSNotifier extends StateNotifier<MCXWishlistWebSocketState> {
//   late MCXWishlistWebSocketService socketService;
//   McxWishlistWSNotifier() : super(const MCXWishlistWebSocketState()) {
//     initWebsocketStates();
//   }

//   void initWebsocketStates() {
//     socketService = MCXWishlistWebSocketService(
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
//         );
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

//     socketService.connect();
//   }

//   @override
//   void dispose() {
//     socketService.socket.dispose();
//     super.dispose();
//   }

//   void reconnect() {
//     state = state.copyWith(
//       isLoading: true,
//     );
//     // socketService.socket.disconnect();
//     // initWebsocketStates();
//   }
// }
