import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:suproxu/features/auth/model/change_pass_entity.dart';
import 'package:suproxu/features/auth/model/forgot_pass_entity.dart';
import 'package:suproxu/features/auth/model/login_entity.dart';
import 'package:suproxu/features/auth/repository/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<AuthUserLoginEvent>(authUserLoginEvent);
    on<NavigateToGlobalNavbarEvent>(navigateToGlobalNavbarEvent);
    on<AuthForgotUserPasswordEvent>(authForgotUserPasswordEvent);
    on<AuthChangeUserPasswordEvent>(authChangeUserPasswordEvent);
  }

  FutureOr<void> authUserLoginEvent(
    AuthUserLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final userLogin = await AuthRepository.userLogin(
        email: event.uEmail,

        password: event.uPassword,
      );
      emit(AuthLoadedSuccessStateForUserLogin(loginModel: userLogin));
    } catch (e) {
      log('Login Error Bloc=>> $e');
      emit(AuthFailedErrorStateForUserLogin(error: e.toString()));
    }
  }

  FutureOr<void> navigateToGlobalNavbarEvent(
    NavigateToGlobalNavbarEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(NavigateToGlobalNavBarAuthActionState());
  }

  FutureOr<void> authForgotUserPasswordEvent(
    AuthForgotUserPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final forgot = await AuthRepository.forgotUserPassword(
        uEmail: event.uEmail,
        context: event.context,
      );
      emit(AuthForgotPasswordSuccessState(forgotPasswordEntity: forgot));
    } catch (e) {
      // print(e);
      emit(AuthForgotPasswordFailedErrorState(error: e.toString()));
    }
  }

  FutureOr<void> authChangeUserPasswordEvent(
    AuthChangeUserPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final changePass = await AuthRepository.changePassword(
        currentPass: event.currentPass,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(
        AuthChangeUserPasswordSuccessState(changePasswordEntity: changePass),
      );
    } catch (e) {
      print(e);
      emit(AuthChangePasswordFailedErrorState(error: e.toString()));
    }
  }
}
