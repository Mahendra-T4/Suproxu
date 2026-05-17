part of 'global_bloc.dart';

@immutable
sealed class GlobalEvent {}

final class LoadPerkLogoImageFromServerEvent extends GlobalEvent {}
