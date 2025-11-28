part of 'home_bloc.dart';

sealed class HomeEvent {}

final class MCXDataSuccessfulFetchingEvent extends HomeEvent {
  final String query;

  MCXDataSuccessfulFetchingEvent({required this.query});
}

final class NSEDataSuccessfulFetchingEvent extends HomeEvent {}

final class FetchStocksCategoryListEvent extends HomeEvent {}

final class BuyStocksEvent extends HomeEvent {
  final String symbolKey;
  final String categoryName;
  final String stockPrice;
  final String stockQty;
  final BuildContext context;

  BuyStocksEvent(
      {required this.symbolKey,
      required this.categoryName,
      required this.stockPrice,
      required this.stockQty,
      required this.context});
}

final class SaleStocksEvent extends HomeEvent {
  final String symbolKey;
  final String categoryName;
  final String stockPrice;
  final String stockQty;
  final BuildContext context;

  SaleStocksEvent(
      {required this.symbolKey,
      required this.categoryName,
      required this.stockPrice,
      required this.stockQty,
      required this.context});
}

final class GetMCXSymbolDataSuccessEvent extends HomeEvent {
  final String symbolKey;
  final String categoryName;

  GetMCXSymbolDataSuccessEvent(
      {required this.symbolKey, required this.categoryName});
}

final class SearchStockBySymbolEvent extends HomeEvent {
  final String query;
  final String stockName;

  SearchStockBySymbolEvent({required this.query, required this.stockName});
}


// ignore: camel_case_types
final class BuyRecordListStocks extends HomeEvent{
  final String symbolKey; // Fixed typo: 'symbolKey:' to 'symbolKey'
  final String categoryName;
  final String stockPrice;
  final String stockQty;

  BuyRecordListStocks({required this.symbolKey, required this.categoryName, required this.stockPrice, required this.stockQty});
}


final class SellRecordListStocks extends HomeEvent{
  final String symbolKey; // Fixed typo: 'symbolKey:' to 'symbolKey'
  final String categoryName;
  final String stockPrice;
  final String stockQty;

  SellRecordListStocks({required this.symbolKey, required this.categoryName, required this.stockPrice, required this.stockQty});
}

