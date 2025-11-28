part of 'auth_bloc.dart';

sealed class AuthState {}

sealed class AuthActionState extends AuthState {}

final class AuthInitialState extends AuthState {}

final class AuthLoadingState extends AuthState {}

//! Login States

final class AuthLoadedSuccessStateForUserLogin extends AuthState {
  final LoginModel loginModel;

  AuthLoadedSuccessStateForUserLogin({required this.loginModel});
}

final class AuthFailedErrorStateForUserLogin extends AuthState {
  final String error;

  AuthFailedErrorStateForUserLogin({required this.error});
}

final class NavigateToGlobalNavBarAuthActionState extends AuthActionState {}




//! forgot pass states

final class AuthForgotPasswordSuccessState extends AuthState {
  final ForgotPasswordEntity forgotPasswordEntity;

  AuthForgotPasswordSuccessState({required this.forgotPasswordEntity});
}

final class AuthForgotPasswordFailedErrorState extends AuthState {
  final String error;

  AuthForgotPasswordFailedErrorState({required this.error});
}



//! change pass states

final class AuthChangeUserPasswordSuccessState extends AuthState {
  final ChangePasswordEntity changePasswordEntity;

  AuthChangeUserPasswordSuccessState({required this.changePasswordEntity});
}

final class AuthChangePasswordFailedErrorState extends AuthState {
  final String error;

  AuthChangePasswordFailedErrorState({required this.error});
}
