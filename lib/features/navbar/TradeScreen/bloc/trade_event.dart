part of 'trade_bloc.dart';

sealed class TradeEvent {}

final class ActiveStockTradeEvent extends TradeEvent {
  final String activity;

  ActiveStockTradeEvent({required this.activity});
}

final class ClosedStockTradeEvent extends TradeEvent {}

final class PendingStockTradeEvent extends TradeEvent {}

final class CancelPendingTradeEvent extends TradeEvent{
  final String tradeKey;
  final BuildContext context;

  CancelPendingTradeEvent({required this.tradeKey, required this.context});
}
