part of 'portfolio_bloc.dart';


sealed class PortfolioEvent {}


final class ActivePortfolioDataFetchingEvent extends PortfolioEvent{}


final class ClosePortfolioDataFetchingEvent extends PortfolioEvent{}


class StartActivePortfolioDataStream extends PortfolioEvent {}

class StopTradeDataStream extends PortfolioEvent {}

class LiveActivePortfolioDataReceived extends PortfolioEvent {
  final ActivePorfolioEntity activePorfolioEntity;
  LiveActivePortfolioDataReceived(this.activePorfolioEntity);
}