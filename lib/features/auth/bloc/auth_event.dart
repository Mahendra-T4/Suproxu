part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class AuthUserLoginEvent extends AuthEvent {
  final String uEmail;
  final String uPassword;

  AuthUserLoginEvent({
    required this.uEmail,
    required this.uPassword,
  });
}

final class NavigateToGlobalNavbarEvent extends AuthEvent {}

final class AuthForgotUserPasswordEvent extends AuthEvent {
  final String uEmail;
  final BuildContext context;

  AuthForgotUserPasswordEvent({required this.uEmail, required this.context});
}

final class AuthChangeUserPasswordEvent extends AuthEvent {
  final String currentPass;
  final String newPassword;
  final String confirmPassword;

  AuthChangeUserPasswordEvent(
      {required this.currentPass,
      required this.newPassword,
      required this.confirmPassword});
}

final class NaviatorPopForChangePasswordActionEvent extends AuthEvent {}
