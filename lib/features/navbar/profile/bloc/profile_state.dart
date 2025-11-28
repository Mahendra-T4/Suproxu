part of 'profile_bloc.dart';

sealed class ProfileState {}

sealed class ProfileActionState extends ProfileState {}

final class ProfileInitialState extends ProfileState {}

final class ProfileLoadingState extends ProfileState {}

final class ProfileLoadedSuccessStateForNotification extends ProfileState {
  final NotificationEntity notificationEntity;

  ProfileLoadedSuccessStateForNotification({required this.notificationEntity});
}

final class ProfileFailedErrorStateForNotification extends ProfileState {
  final String error;

  ProfileFailedErrorStateForNotification({required this.error});
}

final class TransactionRequestLoadedSuccessState extends ProfileState {
  final TransRequestEntity transRequestEntity;

  TransactionRequestLoadedSuccessState({required this.transRequestEntity});
}

final class TransactionRequestFailedErrorState extends ProfileState {
  final String error;

  TransactionRequestFailedErrorState({required this.error});
}

final class TransactionListSuccessfulLoadedState extends ProfileState {
  final TransRequestListEntity transRequestListEntity;

  TransactionListSuccessfulLoadedState({required this.transRequestListEntity});
}

final class TransactionListFailedErrorState extends ProfileState {
  final String error;

  TransactionListFailedErrorState({required this.error});
}

//! ledge complaint states

final class LedgeComplaintLoadedSuccessState extends ProfileState {
  final LedgeComplaintEntity ledgeComplaintEntity;

  LedgeComplaintLoadedSuccessState({required this.ledgeComplaintEntity});
}

final class LedgeComplaintFailedErrorState extends ProfileState {
  final String error;

  LedgeComplaintFailedErrorState({required this.error});
}

final class LoadUserWalletDataSuccessStatus extends ProfileState {
  final BalanceEntity balanceEntity;

  LoadUserWalletDataSuccessStatus({required this.balanceEntity});
}

final class LoadUserWalletDataFailedStatus extends ProfileState {
  final String error;

  LoadUserWalletDataFailedStatus({required this.error});
}

final class FetchLedgerRecordSuccessStatus extends ProfileState {
  final LedgerEntity ledgerEntity;

  FetchLedgerRecordSuccessStatus({required this.ledgerEntity});
}

final class FetchLedgerRecordFailedStatus extends ProfileState {
  final String error;

  FetchLedgerRecordFailedStatus({required this.error});
}

final class FetchOwnerBankDetailsSuccessStatus extends ProfileState {
  final BankDetails bankDetails;

  FetchOwnerBankDetailsSuccessStatus({required this.bankDetails});
}

final class FetchOwnerBankDetailsFailedStatus extends ProfileState {
  final String error;

  FetchOwnerBankDetailsFailedStatus({required this.error});
}

final class FetchUserProfileInfoSuccessStatus extends ProfileState {
  final ProfileInfoModel profileInfoModel;
  final Map<String, dynamic>? profileJsonData;
  final List<Map<String, dynamic>> marginHolding;
  final List<Map<String, dynamic>> marginUsed;

  FetchUserProfileInfoSuccessStatus(
      {required this.profileInfoModel,
      required this.profileJsonData,
      required this.marginHolding,
      required this.marginUsed});
}

final class FetchUserProfileInfoFailedStatus extends ProfileState {
  final String error;

  FetchUserProfileInfoFailedStatus({required this.error});
}

final class NavigateToActivePortfolioStatus extends ProfileActionState {}



final class FetchingWithdrawListSuccessStatus extends ProfileState {
  final WithdrawList withdrawList;

  FetchingWithdrawListSuccessStatus({required this.withdrawList});
}

final class FetchingWithdrawListFailedStatus extends ProfileState {
  final String error;

  FetchingWithdrawListFailedStatus({required this.error});
}


final class FetchingBalanceLogSuccessStatus extends ProfileState {
  final BalanceLogModel balanceLogModel;

  FetchingBalanceLogSuccessStatus({required this.balanceLogModel});
}
final class FetchingBalanceLogFailedStatus extends ProfileState {
  final String error;

  FetchingBalanceLogFailedStatus({required this.error});
}
