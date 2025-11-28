import 'dart:convert';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/service/device_service.dart';

final cancelTradeProvider =
    FutureProvider.family<void, CancelTradeParams>((ref, params) async {
  DatabaseService databaseService = DatabaseService();
  final userKey = await databaseService.getUserData(key: userIDKey);
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
  final response = await http.post(
    Uri.parse(superTradeBaseApiEndPointUrl),
    body: {
      'activity': 'cancel-order',
      'userKey': userKey,
      'tradeKey': params.tradeKey,
      "deviceID": deviceID.toString(),
    },
  );
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    log('Cancel Order Response => ${jsonData['message']}');
    if (jsonData['status'] == 1) {
      successToastMsg(params.context, jsonData['message']);
    } else {
      failedToast(params.context, jsonData['message']);
    }
  } else {
    log('Invalid Response');
  }
});

class CancelTradeParams {
  final String tradeKey;
  final BuildContext context;
  CancelTradeParams({required this.tradeKey, required this.context});
}
