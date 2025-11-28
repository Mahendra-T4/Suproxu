import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/service/device_service.dart';
import 'package:suproxu/features/navbar/profile/model/bank_details.dart';
import 'package:suproxu/features/navbar/profile/model/trans_req_entity.dart';
import 'package:suproxu/features/navbar/profile/model/transaction_req_entity.dart';

typedef EitherHandler<T> = Either<String, T>;

class TransactionRepository {
  static final client = http.Client();
  static final url = Uri.parse(superTradeBaseApiEndPointUrl);
  static DatabaseService databaseService = DatabaseService();

  static Future<EitherHandler<TransRequestListEntity>>
      transactionRequests() async {
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(url, body: {
        'activity': 'transaction-request-list',
        "deviceID": deviceID.toString(),
        'userKey': uKey
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        TransRequestListEntity transRequestListEntity =
            TransRequestListEntity.fromJson(jsonResponse);
        return right(transRequestListEntity);
      } else {
        log('Failed to load data from server');
        return left('Failed to load data from server');
      }
    } catch (e) {
      log('Transaction Request Api =>> $e');
      return left('Transaction Request Api =>> $e');
    }
  }

  static Future<EitherHandler<TransRequestEntity>> transactionRequest(
      String utrNumber,
      String transDate,
      String transAmount,
      File? prof,
      BuildContext context) async {
    final uKey = await databaseService.getUserData(key: userIDKey);
    TransRequestEntity transRequestEntity = TransRequestEntity();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['activity'] = 'transaction-request'
        ..fields['transactionAmount'] = transAmount
        ..fields['userKey'] = uKey
        ..fields['utrNumber'] = utrNumber
        ..fields['deviceID'] = deviceID.toString()
        ..fields['transactionDate'] = transDate;

      // Add file only if it's provided
      if (prof != null) {
        request.files.add(
            await http.MultipartFile.fromPath('transactionProof', prof.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        transRequestEntity = TransRequestEntity.fromJson(jsonResponse);
        log('Deposit Date =>> $transDate');
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const PaymentScreen()));
        Navigator.pop(context);
        return right(transRequestEntity);
      } else {
        return left('Failed to load data from server');
      }
    } catch (e) {
      log('Transaction Request Error =>> $e');
      return left(e.toString());
    }
  }

  static Future<BankDetails> fetchOwnerBankDetails() async {
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    BankDetails bankDetails = BankDetails();
    try {
      final response = await client.post(url, body: {
        'activity': 'get-bank-details',
        'userKey': uKey,
        "deviceID": deviceID.toString(),
      });
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        bankDetails = BankDetails.fromJson(jsonData);
        log('Bank Details =>> ${response.body}');
      } else {
        log('Failed to load bank details from server');
        throw Exception('Failed to load bank details from server');
      }
    } catch (e) {
      log('Fetch Owner Bank Details Error =>> $e');
      throw Exception('Fetch Owner Bank Details Error =>> $e');
    }
    return bankDetails;
  }
}
