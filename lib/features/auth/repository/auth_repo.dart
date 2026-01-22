import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/auth/login/loginPage.dart';
import 'package:suproxu/features/auth/model/change_pass_entity.dart';
import 'package:suproxu/features/auth/model/forgot_pass_entity.dart';
import 'package:suproxu/features/auth/model/login_entity.dart';

typedef EitherHandler<T> = Either<String, T>;

class AuthRepository {
  static final client = http.Client();

  //! user login

  static Future<LoginModel> userLogin({
    required String email,
    required String password,
  }) async {
    DatabaseService dbService = DatabaseService();
    SharedPreferences pref = await SharedPreferences.getInstance();
    LoginModel loginModel = LoginModel();
    final client = http.Client();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    final url = Uri.parse(loginApiEndPointUrl);
    var userDeviceID;
    DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo _androidInfo = await _deviceInfo.androidInfo;

    if (Platform.isAndroid) {
      userDeviceID = _androidInfo.id.toString();
    }
    try {
      final response = await client.post(
        url,
        body: {
          "activity": "login",
          "deviceID": deviceID.toString(),
          "uEmail": email,
          "uPassword": password,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        loginModel = LoginModel.fromJson(jsonResponse);
        // successToastMsg(context, message);
        log('User Key =>>${loginModel.record!.userKey.toString()}');
        log('User Login Json Response =>>${response.body}');

        //* save user first name
        dbService.saveUserData(
          key: userFirstNameKey,
          value: loginModel.record!.userFirstName.toString(),
        );

        //* save user last name
        dbService.saveUserData(
          key: userLastNameKey,
          value: loginModel.record!.userLastName.toString(),
        );

        //* save user email
        dbService.saveUserData(
          key: userEmailIDKey,
          value: loginModel.record!.userEmailID.toString(),
        );

        //* save user mobile
        dbService.saveUserData(
          key: mobileNumberKey,
          value: loginModel.record!.userMobileNumber.toString(),
        );

        //* save user alternate mobile number
        dbService.saveUserData(
          key: alternateMobileKey,
          value: loginModel.record!.userAlternateNumber.toString(),
        );

        //* save user userImage
        dbService.saveUserData(
          key: userImageKey,
          value: loginModel.record!.userImage.toString(),
        );

        //* save user userImage
        dbService.saveUserData(
          key: userBalanceKey,
          value: loginModel.record!.userBalance.toString(),
        );

        //* save userKey
        dbService.saveUserData(
          key: userIDKey,
          value: loginModel.record!.userKey.toString(),
        );
        log('UserID =>> ${loginModel.record!.userKey.toString()}');

        //* save userPoints
        dbService.saveUserData(
          key: activeTradeKey,
          value: loginModel.record!.userActiveTrade.toString(),
        );

        //* save user trade
        dbService.saveUserData(
          key: closeTradeKey,
          value: loginModel.record!.userCloseTrade.toString(),
        );
        //* save user trade
        dbService.saveUserData(
          key: pendingTradeKey,
          value: loginModel.record!.userPendingTrade.toString(),
        );

        //* save user trade
        dbService.saveUserData(
          key: profitAndLossKey,
          value: loginModel.record!.userProfitLoss.toString(),
        );

        //* save userQR
        dbService.saveUserData(
          key: agentQRKey,
          value: loginModel.record!.agentQR.toString(),
        );

        //* save user login token
        pref.setBool(loginToken, true);
      } else {
        log('data not found something want wrong');
      }
    } catch (e) {
      log('Login Error =>> $e');
      left(e.toString());
    }
    return loginModel;
  }

  //! forgot password

  static Future<ForgotPasswordEntity> forgotUserPassword({
    required String uEmail,
    required BuildContext context,
  }) async {
    // DatabaseService databaseService = DatabaseService();
    // final uEmail = databaseService.getUserData(key: userEmailIDKey);
    final url = Uri.parse(forgotPasswordApiEndPointUrl);
    ForgotPasswordEntity forgotPasswordEntity = ForgotPasswordEntity();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(
        url,
        body: {
          'activity': 'forget-password',
          "deviceID": deviceID.toString(),
          'uEmail': uEmail.toString(),
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        forgotPasswordEntity = ForgotPasswordEntity.fromJson(jsonResponse);
        // return right(forgotPasswordEntity);
        if (jsonResponse['status'] == 1) {
          // Navigator.pushReplacementNamed(context, LoginPages.routeName);
          GoRouter.of(context).goNamed(LoginPages.routeName);
        }
      } else {
        log('Failed to load api data');
      }
    } catch (e) {
      log(e.toString());
      // return left(e.toString());
    }
    return forgotPasswordEntity;
  }

  //! change password

  static Future<ChangePasswordEntity> changePasswordEntity({
    required String currentPass,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse(changePasswordApiUrlEndPointUrl);
    ChangePasswordEntity changePasswordEntity = ChangePasswordEntity();
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(
        url,
        body: {
          'activity': 'change-password',
          'userKey': uKey,
          'currentPass': currentPass,
          'newPassword': newPassword,
          "deviceID": deviceID.toString(),
          'confirmPassword': confirmPassword,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        changePasswordEntity = ChangePasswordEntity.fromJson(jsonResponse);
      } else {
        log('Failed to load api data');
      }
    } catch (e) {
      log('Change Password Error =>> $e');
    }
    return changePasswordEntity;
  }
}
