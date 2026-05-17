import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:suproxu/features/navbar/home/model/logo_model.dart';
import 'package:suproxu/features/navbar/home/repository/home_repo.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc() : super(GlobalInitial()) {
    on<LoadPerkLogoImageFromServerEvent>(loadPerkLogoImageFromServerEvent);
  }

  FutureOr<void> loadPerkLogoImageFromServerEvent(
    LoadPerkLogoImageFromServerEvent event,
    Emitter<GlobalState> emit,
  ) async {
    emit(GlobalLoadingState());
    try {
      final logo = await HomeRepository.getLogo();
      emit(LoadPerkLogoImageFromServerSuccessState(logoModel: logo));
    } catch (e) {
      log('Load Perk Logo Image From Server Error =>> $e');
      emit(LoadPerkLogoImageFromServerFailedErrorState(error: e.toString()));
    }
  }
}
