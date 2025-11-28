part of 'wishlist_bloc.dart';

sealed class WishlistEvent {}

final class FatchNFOWishListStocksEvent extends WishlistEvent {}

final class FatchMCXWishListStocksEvent extends WishlistEvent {}

final class FatchNSEWishListStocksEvent extends WishlistEvent {}
