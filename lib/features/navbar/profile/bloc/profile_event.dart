part of 'profile_bloc.dart';

sealed class ProfileEvent {}

final class FetchingNotificationFromServerEvent extends ProfileEvent {}

final class FetchClientTransactionListFromServerEvent extends ProfileEvent {}

final class MakeTransactionRequestFromServerEvent extends ProfileEvent {
  final String utrNumber;
  final String transDate;
  final String transAmount;
  dynamic file;
  final BuildContext context;

  MakeTransactionRequestFromServerEvent(
      {required this.utrNumber,
      required this.transDate,
      required this.transAmount,
      this.file,
      required this.context});
}

final class LoadTransactionRequestListEvent extends ProfileEvent {}

final class LedgeUserComplaintEvent extends ProfileEvent {
  final String subject;
  final String complaint;

  LedgeUserComplaintEvent({required this.subject, required this.complaint});
}

final class LoadUserWalletDataEvent extends ProfileEvent {}

final class FetchLedgerRecordsEvent extends ProfileEvent {}

final class FetchOwnerBankDetailsEvent extends ProfileEvent {}

final class FetchUserProfileInfoEvent extends ProfileEvent {}

final class NavigateToActivePortfolioEvent extends ProfileEvent {
  final BuildContext context;

  NavigateToActivePortfolioEvent({required this.context});
}

final class FetchingWithdrawListEvent extends ProfileEvent {}

final class FetchingBalanceLogEvent extends ProfileEvent {}

// final class MakingWithdrawRequestEvent extends ProfileEvent {}
