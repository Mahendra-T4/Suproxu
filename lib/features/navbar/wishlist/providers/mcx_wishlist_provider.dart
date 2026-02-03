// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
// import 'package:suproxu/features/navbar/wishlist/model/sorting_param.dart';
// import 'package:suproxu/features/navbar/wishlist/repositories/wishlist_repo.dart';
// import 'package:suproxu/features/navbar/wishlist/websocket/mcx_wishlist_websocket.dart';

// /// State class for MCX Wishlist
// class MCXWishlistState {
//   final List<MCXWatchlist> watchlist;
//   final String? errorMessage;
//   final bool isLoading;
//   final Set<String> removingItems;
//   final MCXWishlistEntity entity;

//   MCXWishlistState({
//     this.watchlist = const [],
//     this.errorMessage,
//     this.isLoading = false,
//     this.removingItems = const {},
//     MCXWishlistEntity? entity,
//   }) : entity = entity ?? MCXWishlistEntity();

//   MCXWishlistState copyWith({
//     List<MCXWatchlist>? watchlist,
//     String? errorMessage,
//     bool? isLoading,
//     Set<String>? removingItems,
//     MCXWishlistEntity? entity,
//   }) {
//     return MCXWishlistState(
//       watchlist: watchlist ?? this.watchlist,
//       errorMessage: errorMessage,
//       isLoading: isLoading ?? this.isLoading,
//       removingItems: removingItems ?? this.removingItems,
//       entity: entity ?? this.entity,
//     );
//   }
// }

// /// StateNotifier for MCX Wishlist
// class MCXWishlistNotifier extends StateNotifier<MCXWishlistState> {
//   late final MCXWishlistWebSocketService _socket;
//   final Ref ref;

//   MCXWishlistNotifier(this.ref) : super(MCXWishlistState()) {
//     _initializeWebSocket();
//   }

//   void _initializeWebSocket() {
//     _socket = MCXWishlistWebSocketService(
//       onDataReceived: (data) {
//         _handleDataReceived(data);
//       },
//       keyword: '',
//       onError: (error) {
//         debugLog('Error: $error');
//         state = state.copyWith(errorMessage: error);
//       },
//       onConnected: () {
//         debugLog('MCX Wishlist WebSocket Connected');
//         _refreshData();
//       },
//       onDisconnected: () {
//         debugLog(
//           'MCX Wishlist WebSocket Disconnected - NOT reconnecting automatically',
//         );
//         // DO NOT reconnect automatically - let the socket service handle it
//         // The socket service has built-in auto-reconnect with exponential backoff
//       },
//     );
//     _socket.connect();
//   }

//   void _handleDataReceived(MCXWishlistEntity data) {
//     debugLog('MCX Wishlist Data Received: ${data.mcxWatchlist?.length} items');
//     state = state.copyWith(
//       watchlist: data.mcxWatchlist ?? [],
//       entity: data,
//       errorMessage: null,
//     );
//   }

//   Future<void> _refreshData() async {
//     await _socket.refresh();
//   }

//   /// Refresh wishlist data
//   Future<void> refreshWishlist() async {
//     state = state.copyWith(isLoading: true);
//     try {
//       await _refreshData();
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   /// Reorder wishlist items
//   void reorderItems(int oldIndex, int newIndex) {
//     final newList = List<MCXWatchlist>.from(state.watchlist);
//     if (newIndex > oldIndex) newIndex--;
//     final item = newList.removeAt(oldIndex);
//     newList.insert(newIndex, item);

//     state = state.copyWith(watchlist: newList);

//     // Update server
//     _updateSortOrder(newList);
//   }

//   /// Update sort order on server
//   Future<void> _updateSortOrder(List<MCXWatchlist> items) async {
//     try {
//       final symbolKeys = items.map((e) => e.symbolKey.toString()).join(',');
//       final orderNumbers = List.generate(
//         items.length,
//         (i) => (i + 1).toString(),
//       ).join(',');

//       await WishlistRepository.symbolSorting(
//         param: SortListParam(symbolKey: symbolKeys, symbolOrder: orderNumbers),
//       );
//     } catch (e) {
//       debugLog('Error updating sort order: $e');
//     }
//   }

//   /// Remove item from wishlist
//   Future<void> removeItem(int index) async {
//     final item = state.watchlist[index];
//     final symbolKey = item.symbolKey.toString();

//     state = state.copyWith(removingItems: {...state.removingItems, symbolKey});

//     try {
//       final success = await WishlistRepository.removeWatchListSymbols(
//         category: 'MCX',
//         symbolKey: symbolKey,
//       );

//       if (success) {
//         final newList = List<MCXWatchlist>.from(state.watchlist);
//         newList.removeAt(index);
//         state = state.copyWith(watchlist: newList);
//       } else {
//         state = state.copyWith(errorMessage: 'Failed to remove item');
//       }
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     } finally {
//       state = state.copyWith(
//         removingItems: {...state.removingItems}..remove(symbolKey),
//       );
//     }
//   }

//   /// Clear error message
//   void clearError() {
//     state = state.copyWith(errorMessage: null);
//   }

//   // Socket is permanently kept alive - no disconnect or dispose functionality
//   void debugLog(String message) {
//     print('🔵 MCX Wishlist: $message');
//   }
// }

// /// Riverpod Providers

// /// Socket service provider - Keep alive even when no listeners
// /// This ensures websocket stays connected when navigating to other pages
// final mcxWishlistSocketProvider =
//     StateNotifierProvider<MCXWishlistNotifier, MCXWishlistState>((ref) {
//       // Keep this provider alive even when not actively being watched
//       ref.keepAlive();

//       final notifier = MCXWishlistNotifier(ref);
//       return notifier;
//     }, name: 'mcxWishlistSocket');

// /// Watchlist items provider
// final mcxWatchlistItemsProvider = Provider<List<MCXWatchlist>>((ref) {
//   final state = ref.watch(mcxWishlistSocketProvider);
//   return state.watchlist;
// });

// /// Error message provider
// final mcxWishlistErrorProvider = Provider<String?>((ref) {
//   final state = ref.watch(mcxWishlistSocketProvider);
//   return state.errorMessage;
// });

// /// Loading state provider
// final mcxWishlistLoadingProvider = Provider<bool>((ref) {
//   final state = ref.watch(mcxWishlistSocketProvider);
//   return state.isLoading;
// });

// /// Removing items provider
// final mcxWishlistRemovingProvider = Provider<Set<String>>((ref) {
//   final state = ref.watch(mcxWishlistSocketProvider);
//   return state.removingItems;
// });

// /// Full state provider
// final mcxWishlistStateProvider = Provider<MCXWishlistState>((ref) {
//   return ref.watch(mcxWishlistSocketProvider);
// });
