import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';

class MCXWishlistWebSocketState {
  final bool isLoading;
  final String? errorMessage;
  final MCXWishlistEntity? data;
  final bool isConnected;

  const MCXWishlistWebSocketState({
    this.isLoading = true,
    this.errorMessage,
    this.data,
    this.isConnected = false,
  });

  MCXWishlistWebSocketState copyWith({
    bool? isLoading,
    String? errorMessage,
    MCXWishlistEntity? data,
    bool? isConnected,
  }) {
    return MCXWishlistWebSocketState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
