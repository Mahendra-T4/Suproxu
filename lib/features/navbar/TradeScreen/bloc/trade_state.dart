part of 'trade_bloc.dart';

sealed class TradeState {}

final class TradeInitial extends TradeState {}

final class TradeLoadingState extends TradeState {}

//! Active Trade States

final class ActiveTradeLoadedSuccessState extends TradeState {
  final ActiveTradeEntity activeTrade;

  ActiveTradeLoadedSuccessState({required this.activeTrade});
}

final class ActiveTradeFailedErrorState extends TradeState {
  final String error;

  ActiveTradeFailedErrorState({required this.error});
}

//! Closed Trade States

final class ClosedTradeLoadedSuccessState extends TradeState {
  final ClosedTradeEntity closedTradeEntity;

  ClosedTradeLoadedSuccessState({required this.closedTradeEntity});
}

final class ClosedTradeFailedErrorState extends TradeState {
  final String error;

  ClosedTradeFailedErrorState({required this.error});
}

final class PendingTradeLoadedSuccessState extends TradeState {
  final PendingTradeEntity pendingTradeEntity;

  PendingTradeLoadedSuccessState({required this.pendingTradeEntity});
}

final class PendingTradeFailedErrorState extends TradeState {
  final String error;

  PendingTradeFailedErrorState({required this.error});
}



final class CancelPendingTradeLoadedSuccessState extends TradeState {
  final CancelOrderEntity cancelOrderEntity;

  CancelPendingTradeLoadedSuccessState({required this.cancelOrderEntity});
}

final class CancelPendingTradeFailedErrorState extends TradeState {
  final String error;

  CancelPendingTradeFailedErrorState({required this.error});
}
