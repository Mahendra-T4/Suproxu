import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/service/device_service.dart';
import 'package:suproxu/features/navbar/home/model/ledge_complaint.dart';
import 'package:suproxu/features/navbar/profile/model/ledger_model.dart';

abstract class LedgerRepository {
  static final client = http.Client();
  static final url =
      Uri.parse(superTradeBaseApiEndPointUrl); // Replace with your API endpoint
  static Future<LedgeComplaintEntity> ledgetComplaint(
      {required String subject, required String complaint}) async {
    try {
      final dbConfig = DatabaseService();
      final userKey = await dbConfig.getUserData(key: userIDKey);
       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
      final response = await client.post(url, body: {
        'activity': 'lodge-complain',
        'userKey': userKey,
        'subject': subject,
        "deviceID": deviceID.toString(),
        'complain': complaint
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final ledgeComplaintEntity =
            LedgeComplaintEntity.fromJson(jsonResponse);
        log('Response: ${ledgeComplaintEntity.message}');
        return LedgeComplaintEntity.fromJson(jsonResponse);
      } else {
        return LedgeComplaintEntity(
          status: 0,
          message: 'Ops! Something went wrong.',
        );
      }
    } catch (e) {
      print(e);
      return LedgeComplaintEntity(
        status: 0,
        message: e.toString(),
      );
    }
  }

  static Future<LedgerEntity> ledgerRecords() async {
    LedgerEntity ledgerEntity = LedgerEntity();
    try {
      final dbConfig = DatabaseService();
      final userKey = await dbConfig.getUserData(key: userIDKey);
       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
      final response = await client.post(url, body: {
        'activity': 'ledger',
        'userKey': userKey,
        "deviceID": deviceID.toString(),
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        ledgerEntity = LedgerEntity.fromJson(jsonData);
        log('Ledger Record Response : ${ledgerEntity.message}');
      } else {
        log('Failed to load ledger data');
      }
    } catch (e) {
      log('Ledger Error : $e');
    }
    return ledgerEntity;
  }
}
