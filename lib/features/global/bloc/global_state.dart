part of 'global_bloc.dart';

sealed class GlobalState {}

final class GlobalInitial extends GlobalState {}

final class GlobalLoadingState extends GlobalState {}

final class LoadPerkLogoImageFromServerSuccessState extends GlobalState {
  final LogoModel logoModel;

  LoadPerkLogoImageFromServerSuccessState({required this.logoModel});
}

final class LoadPerkLogoImageFromServerFailedErrorState extends GlobalState {
  final String error;

  LoadPerkLogoImageFromServerFailedErrorState({required this.error});
}
