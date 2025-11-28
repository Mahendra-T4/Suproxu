import 'package:suproxu/features/navbar/wishlist/model/wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/wishlist-tabs/NFO-Tab/nfo_wishlist.dart';

class NFOWatchlistState {
  final bool isLoading;
  final String? message;
  final NFOWishlistEntity? nfoWishlistEntity;
  final bool isConnected;

  NFOWatchlistState(
      {this.isLoading = true,
      this.message,
      this.nfoWishlistEntity,
      this.isConnected = false});

  NFOWatchlistState copyWith({
    bool? isLoading,
    String? message,
    NFOWishlistEntity? nfoWishlistEntity,
    bool? isConnected,
  }) =>
      NFOWatchlistState(
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
        nfoWishlistEntity: nfoWishlistEntity ?? this.nfoWishlistEntity,
        isConnected: isConnected ?? this.isConnected,
      );
}
