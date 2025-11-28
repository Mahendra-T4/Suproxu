import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:suproxu/features/navbar/Portfolio/model/active_portfolio.dart';
import 'package:suproxu/features/navbar/Portfolio/model/active_portfolio_stock_entity.dart';
import 'package:suproxu/features/navbar/Portfolio/model/close_portfolio_stock_entity.dart';
import 'package:suproxu/features/navbar/Portfolio/repositories/portfolio_repo.dart';

part 'portfolio_event.dart';
part 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  late StreamController<ActivePorfolioEntity> activePortfolioController;
  StreamSubscription? activePortfolioSubscription;
  Timer? activePortfolioUpdateTimer;

  PortfolioBloc() : super(PortfolioInitial()) {
    on<ActivePortfolioDataFetchingEvent>(activePortfolioDataFetchingEvent);
    // on<LiveActivePortfolioDataReceived>(liveActivePortfolioDataReceived);
    // on<StartActivePortfolioDataStream>(startActivePortfolioDataStream);
    on<ClosePortfolioDataFetchingEvent>(closePortfolioDataFetchingEvent);
  }

  FutureOr<void> activePortfolioDataFetchingEvent(
      ActivePortfolioDataFetchingEvent event,
      Emitter<PortfolioState> emit) async {
    emit(PortfolioLoadingState());
    try {
      final activeTrade = await PortfolioRepository.activePortfolio();
      emit(ActivePortfolioLoadedSuccessState(
          activePortfolioStockEntity: activeTrade));
    } catch (e) {
      log('Active Portfolio Bloc Error =>> $e');
      emit(ActivePortfolioFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> closePortfolioDataFetchingEvent(
      ClosePortfolioDataFetchingEvent event,
      Emitter<PortfolioState> emit) async {
    emit(PortfolioLoadingState());
    try {
      final closedPortfolio = await PortfolioRepository.closePortfolio();
      emit(ClosedPortfolioLoadedSuccessState(
          closePortfolioStockEntity: closedPortfolio));
    } catch (e) {
      emit(ClosedPortfolioFailedErrorState(error: e.toString()));
      print(e);
    }
  }

  // FutureOr<void> liveActivePortfolioDataReceived(
  //     LiveActivePortfolioDataReceived event,
  //     Emitter<PortfolioState> emit) async {
  //   if (state is ActivePortfolioLoadedSuccessState) {
  //     emit(ActivePortfolioLoadedSuccessState(
  //         activePortfolioEntity: event.activePorfolioEntity));
  //   }
  // }

  // FutureOr<void> startActivePortfolioDataStream(
  //     StartActivePortfolioDataStream event,
  //     Emitter<PortfolioState> emit) async {
  //   try {
  //     activePortfolioSubscription?.cancel();

  //     activePortfolioUpdateTimer =
  //         Timer.periodic(const Duration(seconds: 1), (timer) async {
  //       try {
  //         final updatedData = await PortfolioRepository.activePortfolio();
  //         activePortfolioController.add(updatedData);
  //       } catch (e) {
  //         activePortfolioController.addError(e);
  //         // print(e);
  //       }
  //     });
  //     activePortfolioSubscription = activePortfolioController.stream.listen(
  //         (data) => add(LiveActivePortfolioDataReceived(data)),
  //         onError: (error) =>
  //             emit(ActivePortfolioFailedErrorState(error: error)));
  //   } catch (e) {
  //     print(e);
  //   }

  // }
}
