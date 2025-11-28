import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/features/navbar/home/model/ledge_complaint.dart';
import 'package:suproxu/features/navbar/navbar.dart';
import 'package:suproxu/features/navbar/profile/model/balance_log.dart';
import 'package:suproxu/features/navbar/profile/model/balence_entity.dart';
import 'package:suproxu/features/navbar/profile/model/bank_details.dart';
import 'package:suproxu/features/navbar/profile/model/ledger_model.dart';
import 'package:suproxu/features/navbar/profile/model/notification_entity.dart';
import 'package:suproxu/features/navbar/profile/model/profile_info.dart';
import 'package:suproxu/features/navbar/profile/model/trans_req_entity.dart';
import 'package:suproxu/features/navbar/profile/model/transaction_req_entity.dart';
import 'package:suproxu/features/navbar/profile/model/withdrawlist.dart';
import 'package:suproxu/features/navbar/profile/repository/ledger_repo.dart';
import 'package:suproxu/features/navbar/profile/repository/profile_repo.dart';
import 'package:suproxu/features/navbar/profile/repository/transaction_repo.dart';
import 'package:suproxu/features/navbar/profile/repository/withdraw_repo.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitialState()) {
    on<FetchingNotificationFromServerEvent>(
        fetchingNotificationFromServerEvent);
    on<MakeTransactionRequestFromServerEvent>(
        makeTransactionRequestFromServerEvent);
    on<LoadTransactionRequestListEvent>(loadTransactionRequestListEvent);
    on<LedgeUserComplaintEvent>(ledgeUserComplaintEvent);
    on<LoadUserWalletDataEvent>(loadUserWalletDataEvent);
    on<FetchLedgerRecordsEvent>(fetchLedgerRecordsEvent);
    on<FetchOwnerBankDetailsEvent>(fetchOwnerBankDetailsEvent);
    on<FetchUserProfileInfoEvent>(fetchUserProfileInfoEvent);
    on<NavigateToActivePortfolioEvent>(navigateToActivePortfolioEvent);
    on<FetchingWithdrawListEvent>(fetchingWithdrawListEvent);
    on<FetchingBalanceLogEvent>(fetchingBalanceLogEvent);
  }

  FutureOr<void> fetchingNotificationFromServerEvent(
      FetchingNotificationFromServerEvent event,
      Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    final notification = await ProfileRepository.notification();
    notification.fold(
        (left) => emit(ProfileFailedErrorStateForNotification(error: left)),
        (right) => emit(ProfileLoadedSuccessStateForNotification(
            notificationEntity: right)));
  }

  FutureOr<void> makeTransactionRequestFromServerEvent(
      MakeTransactionRequestFromServerEvent event,
      Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    final transaction = await TransactionRepository.transactionRequest(
        event.utrNumber,
        event.transDate,
        event.transAmount,
        event.file,
        event.context);

    transaction.fold(
        (left) => emit(TransactionRequestFailedErrorState(error: left)),
        (right) => emit(
            TransactionRequestLoadedSuccessState(transRequestEntity: right)));
  }

  FutureOr<void> loadTransactionRequestListEvent(
      LoadTransactionRequestListEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    final requests = await TransactionRepository.transactionRequests();

    requests.fold(
        (left) => emit(TransactionListFailedErrorState(error: left)),
        (right) => emit(TransactionListSuccessfulLoadedState(
            transRequestListEntity: right)));
  }

  FutureOr<void> ledgeUserComplaintEvent(
      LedgeUserComplaintEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    try {
      final ledgeComplaintEntity = await LedgerRepository.ledgetComplaint(
          subject: event.subject, complaint: event.complaint);
      emit(LedgeComplaintLoadedSuccessState(
          ledgeComplaintEntity: ledgeComplaintEntity));
    } catch (e) {
      log('Ledger Complaint Bloc Error: ${e.toString()}');
      emit(LedgeComplaintFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> loadUserWalletDataEvent(
      LoadUserWalletDataEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    try {
      final balanceEntity = await ProfileRepository.userWallet();
      emit(LoadUserWalletDataSuccessStatus(balanceEntity: balanceEntity));
    } catch (e) {
      print(e);
      emit(LoadUserWalletDataFailedStatus(error: e.toString()));
    }
  }

  FutureOr<void> fetchLedgerRecordsEvent(
      FetchLedgerRecordsEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    try {
      final ledger = await LedgerRepository.ledgerRecords();
      emit(FetchLedgerRecordSuccessStatus(ledgerEntity: ledger));
    } catch (e) {
      emit(FetchLedgerRecordFailedStatus(error: e.toString()));
      log('Fetch Ledger Record Error From Bloc : $e');
    }
  }

  FutureOr<void> fetchOwnerBankDetailsEvent(
      FetchOwnerBankDetailsEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    try {
      final bankDetails = await TransactionRepository.fetchOwnerBankDetails();
      emit(FetchOwnerBankDetailsSuccessStatus(bankDetails: bankDetails));
    } catch (e) {
      emit(FetchOwnerBankDetailsFailedStatus(error: e.toString()));
      log('Fetch Owner Bank Details Error From Bloc : $e');
    }
  }

  FutureOr<void> fetchUserProfileInfoEvent(
      FetchUserProfileInfoEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    try {
      final profileInfoModel = await ProfileRepository.profileInfo();
      final profileJsonData = ProfileRepository.profileJsonData;
      emit(FetchUserProfileInfoSuccessStatus(
          profileInfoModel: profileInfoModel,
          profileJsonData: profileJsonData,
          marginHolding: ProfileRepository.marginHolding,
          marginUsed: ProfileRepository.marginUsed));
    } catch (e) {
      print(e);
      emit(FetchUserProfileInfoFailedStatus(error: e.toString()));
    }
  }

  FutureOr<void> navigateToActivePortfolioEvent(
      NavigateToActivePortfolioEvent event, Emitter<ProfileState> emit) {
    emit(NavigateToActivePortfolioStatus());
  }

  FutureOr<void> fetchingWithdrawListEvent(
      FetchingWithdrawListEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    try {
      final withdrawList = await WithdrawRepository.fetchWithdrawList();
      emit(FetchingWithdrawListSuccessStatus(withdrawList: withdrawList));
    } catch (e) {
      emit(FetchingWithdrawListFailedStatus(error: e.toString()));
      log('Fetching Withdraw List Error From Bloc : $e');
    }
  }

  FutureOr<void> fetchingBalanceLogEvent(
      FetchingBalanceLogEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());
    try {
      final balanceLog = await WithdrawRepository.balanceLog();
      emit(FetchingBalanceLogSuccessStatus(balanceLogModel: balanceLog));
    } catch (e) {
      emit(FetchingBalanceLogFailedStatus(error: e.toString()));
      log('Fetching Balance Log Error From Bloc : $e');
    }
  }
}
