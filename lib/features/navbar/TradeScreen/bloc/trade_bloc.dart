import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/active_trade_entity.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/cancel_order_entity.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/closed_trade_entity.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/pending_trade_entity.dart';
import 'package:suproxu/features/navbar/TradeScreen/repositories/trade_repo.dart';

part 'trade_event.dart';
part 'trade_state.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  TradeBloc() : super(TradeInitial()) {
    on<ActiveStockTradeEvent>(activeStockTradeEvent);
    on<ClosedStockTradeEvent>(closedStockTradeEvent);
    on<PendingStockTradeEvent>(pendingStockTradeEvent);
    // on<CancelPendingTradeEvent>(cancelPendingTradeEvent);
  }

  FutureOr<void> activeStockTradeEvent(
      ActiveStockTradeEvent event, Emitter<TradeState> emit) async {
    emit(TradeLoadingState());
    try {
      final activeTrade = await TradeStockRepository.activeTrade();
      emit(ActiveTradeLoadedSuccessState(
        activeTrade: activeTrade,
      ));
    } catch (e) {
      log('Error in ActiveStockTradeEvent: $e');
      emit(ActiveTradeFailedErrorState(
        error: e.toString(),
      ));
    }
  }

  FutureOr<void> closedStockTradeEvent(
      ClosedStockTradeEvent event, Emitter<TradeState> emit) async {
    emit(TradeLoadingState());
    try {
      final closedTrade = await TradeStockRepository.closedTrade();
      emit(ClosedTradeLoadedSuccessState(
        closedTradeEntity: closedTrade,
      ));
    } catch (e) {
      log('Error in ClosedStockTradeEvent:=> $e');
      emit(ClosedTradeFailedErrorState(
        error: e.toString(),
      ));
    }
  }

  FutureOr<void> pendingStockTradeEvent(
      PendingStockTradeEvent event, Emitter<TradeState> emit) async {
    emit(TradeLoadingState());
    try {
      final pendingTradeEntity = await TradeStockRepository.pendingTrade();
      emit(PendingTradeLoadedSuccessState(
          pendingTradeEntity: pendingTradeEntity));
    } catch (e) {
      emit(PendingTradeFailedErrorState(error: e.toString()));
      print(e);
    }
  }

  // FutureOr<void> cancelPendingTradeEvent(
  //     CancelPendingTradeEvent event, Emitter<TradeState> emit) async {
  //   emit(TradeLoadingState());
  //   try {
  //     final cancelOrder = await TradeStockRepository.cancelPendingTrade(
  //         tradeKey: event.tradeKey, context: event.context);
  //     emit(
  //         CancelPendingTradeLoadedSuccessState(cancelOrderEntity: cancelOrder));
  //   } catch (e) {
  //     emit(CancelPendingTradeFailedErrorState(error: e.toString()));
  //     print(e);
  //   }
  // }
}
