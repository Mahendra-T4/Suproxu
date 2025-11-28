part of 'portfolio_bloc.dart';

sealed class PortfolioState {}

final class PortfolioInitial extends PortfolioState {}

final class PortfolioLoadingState extends PortfolioState {}

final class ActivePortfolioLoadedSuccessState extends PortfolioState {
  final ActivePortfolioStockEntity activePortfolioStockEntity;

  ActivePortfolioLoadedSuccessState({required this.activePortfolioStockEntity});
}

final class ActivePortfolioFailedErrorState extends PortfolioState {
  final String error;

  ActivePortfolioFailedErrorState({required this.error});
}


final class ClosedPortfolioLoadedSuccessState extends PortfolioState {
  final ClosePortfolioStockEntity closePortfolioStockEntity;

  ClosedPortfolioLoadedSuccessState({required this.closePortfolioStockEntity});
}

final class ClosedPortfolioFailedErrorState extends PortfolioState {
  final String error;

  ClosedPortfolioFailedErrorState({required this.error});
}

