import 'package:flutter/material.dart';
import 'custom_toast.dart';

void successToastMsg(BuildContext context, String message) {
  CustomToast.showSuccess(context, message);
}

void failedToast(BuildContext context, String message) {
  CustomToast.showError(context, message);
}

void waringToast(BuildContext context, String message) {
  CustomToast.showWarning(context, message);
}
