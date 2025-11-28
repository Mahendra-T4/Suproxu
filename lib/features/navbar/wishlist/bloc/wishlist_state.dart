part of 'wishlist_bloc.dart';

sealed class WishlistState {}

final class WishlistInitial extends WishlistState {}

final class WishlistLoadingState extends WishlistState {}

final class FatchNFOWishlistSuccessState extends WishlistState {
  final NFOWishlistEntity nfoWishlistEntity;

  FatchNFOWishlistSuccessState({required this.nfoWishlistEntity});
}

final class NFOWishlistErrorState extends WishlistState {
  final String message;

  NFOWishlistErrorState({required this.message});
}

final class FatchNSEWishlistSuccessState extends WishlistState {
  final NSEWishlistEntity nseWishlistEntity;

  FatchNSEWishlistSuccessState({required this.nseWishlistEntity});
}

final class NSEWishlistErrorState extends WishlistState {
  final String message;

  NSEWishlistErrorState({required this.message});
}

final class FatchMCXWishlistSuccessState extends WishlistState {
  final MCXWishlistEntity mcxWishlistEntity;

  FatchMCXWishlistSuccessState({required this.mcxWishlistEntity});
}

final class MCXWishlistErrorState extends WishlistState {
  final String message;

  MCXWishlistErrorState({required this.message});
}
