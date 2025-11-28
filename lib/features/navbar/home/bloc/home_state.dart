part of 'home_bloc.dart';

sealed class HomeState {}

final class HomeInitialState extends HomeState {}

final class HomeLoadingState extends HomeState {}

final class HomeLoadingState2 extends HomeState{}

//! MCX Trade States

final class HomeSuccessStateForMCXTrading extends HomeState {
  final MCXDataEntity mcxDataEntity;

  HomeSuccessStateForMCXTrading({required this.mcxDataEntity});
}

final class HomeFailedErrorStateForMCXTrading extends HomeState {
  final String error;

  HomeFailedErrorStateForMCXTrading({required this.error});
}

//! NSE Trade States

final class HomeSuccessStateForNSETrading extends HomeState {
  final NSEDataEntity nseDataEntity;

  HomeSuccessStateForNSETrading({required this.nseDataEntity});
}

final class HomeFailedErrorStateForNSETrading extends HomeState {
  final String error;

  HomeFailedErrorStateForNSETrading({required this.error});
}

//! stock category list

final class StockCategorySuccessfulLoadedSuccessState extends HomeState {
  final StocksCategoryEntity stocksCategoryEntity;

  StockCategorySuccessfulLoadedSuccessState(
      {required this.stocksCategoryEntity});
}

final class StockCategoryFailedErrorState extends HomeState {
  final String error;

  StockCategoryFailedErrorState({required this.error});
}

final class BuyStockLoadedSuccessState extends HomeState {
  final BuySaleEntity buySaleEntity;

  BuyStockLoadedSuccessState({required this.buySaleEntity});
}

final class BuyStockLFailedErrorState extends HomeState {
  final String error;

  BuyStockLFailedErrorState({required this.error});
}

final class SaleStockLoadedSuccessState extends HomeState {
  final BuySaleEntity buySaleEntity;

  SaleStockLoadedSuccessState({required this.buySaleEntity});
}

final class SaleStockLFailedErrorState extends HomeState {
  final String error;

  SaleStockLFailedErrorState({required this.error});
}

final class GetMCXSymbolDataSuccessState extends HomeState {
  final GetStockRecordEntity getStockRecordEntity;

  GetMCXSymbolDataSuccessState({required this.getStockRecordEntity});
}

final class GetMCXSymbolDataFailedErrorState extends HomeState {
  final String error;

  GetMCXSymbolDataFailedErrorState({required this.error});
}

final class SearchStockByNameSuccessState extends HomeState {
  final SearchStockEntity searchStockEntity;

  SearchStockByNameSuccessState({required this.searchStockEntity});
}

final class SearchStockByNameFailedErrorState extends HomeState {
  final String error;

  SearchStockByNameFailedErrorState({required this.error});
}


// final class SellRecordListStocksSuccessState extends HomeState{
//   final BuySaleEntity b
// }