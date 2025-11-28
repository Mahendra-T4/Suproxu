import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/model/nse_wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/model/wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/model/nse_wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/model/wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/repositories/wishlist_repo.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc() : super(WishlistInitial()) {
    on<FatchNFOWishListStocksEvent>(fatchNFOWishListStocksEvent);
    on<FatchNSEWishListStocksEvent>(fatchNSEWishListStocksEvent);
    on<FatchMCXWishListStocksEvent>(fatchMCXWishListStocksEvent);
  }

  FutureOr<void> fatchNFOWishListStocksEvent(
      FatchNFOWishListStocksEvent event, Emitter<WishlistState> emit) async {
    emit(WishlistLoadingState());
    try {
      final nfoWishlist = await WishlistRepository.fatchWishlistForNFO();
      emit(FatchNFOWishlistSuccessState(nfoWishlistEntity: nfoWishlist));
    } catch (error) {
      log('Fatch Wishlist Bloc Error =>> $error');
      emit(NFOWishlistErrorState(message: error.toString()));
    }
  }

  FutureOr<void> fatchNSEWishListStocksEvent(
      FatchNSEWishListStocksEvent event, Emitter<WishlistState> emit) async {
    emit(WishlistLoadingState());
    try {
      final nseWishlist = await WishlistRepository.fatchWishlistForNSE();
      emit(FatchNSEWishlistSuccessState(nseWishlistEntity: nseWishlist));
    } catch (error) {
      log('Fatch Wishlist Bloc Error =>> $error');
      emit(NSEWishlistErrorState(message: error.toString()));
    }
  }

  FutureOr<void> fatchMCXWishListStocksEvent(
      FatchMCXWishListStocksEvent event, Emitter<WishlistState> emit) async {
    emit(WishlistLoadingState());
    try {
      final nseWishlist = await WishlistRepository.fatchWishlistForMCX();
      emit(FatchMCXWishlistSuccessState(mcxWishlistEntity: nseWishlist));
    } catch (error) {
      log('Fatch Wishlist Bloc Error =>> $error');
      emit(MCXWishlistErrorState(message: error.toString()));
    }
  }
}
