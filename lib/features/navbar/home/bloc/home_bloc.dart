import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:suproxu/features/navbar/home/model/buy_sale_entity.dart';
import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';
import 'package:suproxu/features/navbar/home/model/mcx_entity.dart';
import 'package:suproxu/features/navbar/home/model/nse_enity.dart';
import 'package:suproxu/features/navbar/home/model/search_stock_entity.dart';
import 'package:suproxu/features/navbar/home/model/stock_cat_list.dart';
import 'package:suproxu/features/navbar/home/repository/buy_sale_repo.dart';
import 'package:suproxu/features/navbar/home/repository/home_repo.dart';
import 'package:suproxu/features/navbar/home/repository/trade_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitialState()) {
    on<FetchStocksCategoryListEvent>(fetchStocksCategoryListEvent);
    on<NSEDataSuccessfulFetchingEvent>(nseDataSuccessfulFetchingEvent);
    on<SaleStocksEvent>(saleStocksEvent);
    // on<MCXDataSuccessfulFetchingEvent>(mcxDataSuccessfulFetchingEvent);
    on<BuyStocksEvent>(buyStocksEvent);
    on<GetMCXSymbolDataSuccessEvent>(getMCXSymbolDataSuccessEvent);
    // on<SearchStockBySymbolEvent>(searchStockBySymbolEvent);
  }



  FutureOr<void> nseDataSuccessfulFetchingEvent(
    NSEDataSuccessfulFetchingEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeInitialState());
    try {
      final nseTrade = await TradeRepository().nseTradeDataLoader();
      emit(HomeSuccessStateForNSETrading(nseDataEntity: nseTrade));
    } catch (e) {
      log(e.toString());
      emit(HomeFailedErrorStateForNSETrading(error: e.toString()));
    }
  }

  FutureOr<void> fetchStocksCategoryListEvent(
    FetchStocksCategoryListEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeInitialState());
    try {
      final category = await HomeRepository.getStockCategoryList();
      emit(
        StockCategorySuccessfulLoadedSuccessState(
          stocksCategoryEntity: category,
        ),
      );
    } catch (e) {
      emit(StockCategoryFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> saleStocksEvent(
    SaleStocksEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());
    try {
      final saleStocks = await StockBuyAndSaleRepository.saleStock(
        context: event.context,
        symbolKey: event.symbolKey,
        categoryName: event.categoryName,
        stockPrice: event.stockPrice,
        stockQty: event.stockQty,
      );
      emit(SaleStockLoadedSuccessState(buySaleEntity: saleStocks));
    } catch (e) {
      log('Sale Stock Bloc Error =>> $e');
      emit(BuyStockLFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> buyStocksEvent(
    BuyStocksEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());
    try {
      final buyStocks = await StockBuyAndSaleRepository.buyStock(
        context: event.context,
        symbolKey: event.symbolKey,
        categoryName: event.categoryName,
        stockPrice: event.stockPrice,
        stockQty: event.stockQty,
      );
      emit(BuyStockLoadedSuccessState(buySaleEntity: buyStocks));
    } catch (e) {
      log('Sale Stock Bloc Error =>> $e');
      emit(BuyStockLFailedErrorState(error: e.toString()));
    }
  }

  Stream<void> getMCXSymbolDataSuccessEvent(
    GetMCXSymbolDataSuccessEvent event,
    Emitter<HomeState> emit,
  ) async* {
    emit(HomeLoadingState());
    try {
      final getStockRecordEntity = await TradeRepository.getMCXStockRecords(
        event.symbolKey,
        event.categoryName,
      );
      emit(
        GetMCXSymbolDataSuccessState(
          getStockRecordEntity: getStockRecordEntity,
        ),
      );
    } catch (e) {
      log('Get MCX Symbol Data Error =>> $e');
      emit(GetMCXSymbolDataFailedErrorState(error: e.toString()));
    }
  }

  
}
