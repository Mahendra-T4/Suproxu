import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/service/device_service.dart';
import 'package:suproxu/features/navbar/profile/model/balance_log.dart';
import 'package:suproxu/features/navbar/profile/model/withdraw_req_model.dart';
import 'package:suproxu/features/navbar/profile/model/withdrawlist.dart';

class WithdrawRepository {
  static final client = http.Client();

  static final url = Uri.parse(superTradeBaseApiEndPointUrl);

  static Future<WithdrawList> fetchWithdrawList() async {
    final DatabaseService dbService = DatabaseService();
    final userKey = await dbService.getUserData(key: userIDKey);
     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    WithdrawList withdrawList = WithdrawList();
    try {
      final response = await client.post(
        url,
        body: {
          'activity': 'withdraw-list',
          "deviceID": deviceID.toString(),
          'userKey': userKey.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        withdrawList = WithdrawList.fromJson(jsonData);
        log('Withdraw list fetched successfully: ${withdrawList.message}');
      } else {
        log('Failed to load withdraw list');
        return WithdrawList()..message = 'Failed to load withdraw list';
      }
    } catch (e) {
      print(e);
    }
    return withdrawList;
  }

  static Future<WithdrawRequest> requestWithdraw(
      {required String amount}) async {
    final DatabaseService dbService = DatabaseService();
    final userKey = await dbService.getUserData(key: userIDKey);
     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    WithdrawRequest withdrawRequest = WithdrawRequest();
    try {
      final response = await client.post(
        url,
        body: {
          'activity': 'withdraw-request',
          'userKey': userKey,
          'amount': amount.toString(),
          "deviceID": deviceID.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        withdrawRequest = WithdrawRequest.fromJson(jsonData);
        log('Withdraw request made successfully: ${withdrawRequest.message}');
      } else {
        log('Withdraw request Failed to Fetch');
        return WithdrawRequest()..message = 'Failed to make withdraw request';
      }
    } catch (e) {
      log('Error making withdraw request: $e');
    }
    return withdrawRequest;
  }

  static Future<BalanceLogModel> balanceLog() async {
    final DatabaseService dbService = DatabaseService();
    final userKey = await dbService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    BalanceLogModel balanceLogModel = BalanceLogModel();
    try {
      final response = await client.post(
        url,
        body: {
          'activity': 'balance-log',
          "deviceID": deviceID.toString(),
          'userKey': userKey.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        balanceLogModel = BalanceLogModel.fromJson(jsonData);
        log('Balance log fetched successfully: ${balanceLogModel.message}');
      } else {
        log('Failed to load balance log');
        return BalanceLogModel()..message = 'Failed to load balance log';
      }
    } catch (e) {
      log('Error fetching balance log: $e');
    }
    return balanceLogModel;
  }
}
