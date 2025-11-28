// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/features/navbar/wishlist/model/wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/provider/state/nfo_watchlist_state.dart';
// import 'package:trading_app/features/navbar/wishlist/websocket/nfo_watchlist_ws.dart';

// final nfoWatchlistWSProvider =
//     StateNotifierProvider<NFOWatchlistWSNotifier, NFOWatchlistState>(
//         (ref) => NFOWatchlistWSNotifier());

// class NFOWatchlistWSNotifier extends StateNotifier<NFOWatchlistState> {
//   NFOWatchListWebSocketService? _socket;
//   bool _isInitializing = false;

//   NFOWatchlistWSNotifier() : super(NFOWatchlistState()) {
//     initializeWebSocket();
//   }

//   Future<void> initializeWebSocket() async {
//     if (_isInitializing || _socket != null) return;

//     _isInitializing = true;
//     state = state.copyWith(isLoading: true);
//     try {
//       _socket = NFOWatchListWebSocketService(
//         onNFODataReceived: (NFOWishlistEntity data) {
//           state = state.copyWith(
//             nfoWishlistEntity: data,
//             isLoading: false,
//             message: null,
//           );
//         },
//         onError: (String error) {
//           state = state.copyWith(
//             message: error,
//             isLoading: false,
//             isConnected: false,
//           );
//         },
//         onConnected: () {
//           state = state.copyWith(
//             isConnected: true,
//             isLoading: false,
//             message: null,
//           );
//         },
//         onDisconnected: () {
//           state = state.copyWith(
//             isConnected: false,
//             isLoading: false,
//             message: "Disconnected from server",
//           );
//         },
//       );

//       _socket?.connect();
//     } catch (e) {
//       state = state.copyWith(
//         message: "Failed to initialize WebSocket: ${e.toString()}",
//         isLoading: false,
//         isConnected: false,
//       );
//     } finally {
//       _isInitializing = false;
//     }
//   }

//   @override
//   void dispose() {
//     _socket?.disconnect();
//     _socket = null;
//     super.dispose();
//   }

//   Future<void> reconnect() async {
//     if (_isInitializing) return;

//     state = state.copyWith(isLoading: true);
//     _socket?.disconnect();
//     _socket = null;
//     await initializeWebSocket();
//   }
// }
