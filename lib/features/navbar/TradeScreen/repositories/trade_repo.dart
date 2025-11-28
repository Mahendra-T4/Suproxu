import 'dart:convert';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/active_trade_entity.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/features/navbar/TradeScreen/model/cancel_order_entity.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/close_all_order_model.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/closed_trade_entity.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/param.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/pending_trade_entity.dart';

final pendingTradeProvider = FutureProvider<PendingTradeEntity>(
    (ref) => TradeStockRepository.pendingTrade());

abstract class TradeStockRepository {
  static Future<ActiveTradeEntity> activeTrade() async {
    ActiveTradeEntity activeTradeEntity = ActiveTradeEntity();
    try {
      DatabaseService databaseService = DatabaseService();

      final userKey = await databaseService.getUserData(key: userIDKey);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final deviceID = androidInfo.id.toString();

      final response = await http.post(
        Uri.parse(superTradeBaseApiEndPointUrl),
        body: {
          'activity': 'active-stock',
          "deviceID": deviceID.toString(),
          'userKey': userKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (kDebugMode) {
          log("Active Trade Repository:=> ${response.body}");
        }
        log("Device ID:=> $deviceID");
        activeTradeEntity = ActiveTradeEntity.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          log("Failed to load active trade data");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log("Active Trade Repository:=> $e");
      }
    }
    return activeTradeEntity;
  }

  static Future<ClosedTradeEntity> closedTrade() async {
    try {
      DatabaseService databaseService = DatabaseService();
      final userKey = await databaseService.getUserData(key: userIDKey);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final deviceID = androidInfo.id.toString();

      final response = await http.post(
        Uri.parse(superTradeBaseApiEndPointUrl),
        body: {
          'activity': 'closed-stock',
          "deviceID": deviceID.toString(),
          'userKey': userKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (kDebugMode) {
          log("Closed Trade Repository:=> ${response.body}");
        }
        return ClosedTradeEntity.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          log("Failed to load Closed trade data");
        }
        return ClosedTradeEntity(
          status: 0,
          message: 'Failed to load Closed trade data',
          record: [],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log("Closed Trade Repository:=> $e");
      }
      return ClosedTradeEntity(
        status: 500,
        message: e.toString(),
        record: [],
      );
    }
  }

  static Future<PendingTradeEntity> pendingTrade() async {
    try {
      DatabaseService databaseService = DatabaseService();
      final userKey = await databaseService.getUserData(key: userIDKey);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final deviceID = androidInfo.id.toString();

      final response = await http.post(
        Uri.parse(superTradeBaseApiEndPointUrl),
        body: {
          'activity': 'pending-stock',
          "deviceID": deviceID.toString(),
          'userKey': userKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // if (kDebugMode) {
        //   log("Active Trade Repository:=> ${response.body}");
        // }
        return PendingTradeEntity.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          log("Failed to load active trade data");
        }
        return PendingTradeEntity(
          status: 0,
          message: 'Failed to load active trade data',
          record: [],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log("Active Trade Repository:=> $e");
      }
      return PendingTradeEntity(
        status: 500,
        message: e.toString(),
        record: [],
      );
    }
  }

  static Future<CancelOrderEntity> cancelPendingTrade(
      {required String tradeKey}) async {
    CancelOrderEntity cancelOrderEntity = CancelOrderEntity();
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
        "deviceID": deviceID.toString(),
        'tradeKey': tradeKey
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      cancelOrderEntity = CancelOrderEntity.fromJson(jsonData);

      log('Cancel Order Response => ${cancelOrderEntity.message.toString()}');

      log('Trade Key: $tradeKey');
    } else {
      log('Invalid Response');
    }
    return cancelOrderEntity;
  }

  static Future<CloseAllOrderModel> closeAllOrders(
      {required CloseOrderParam param}) async {
    CloseAllOrderModel cancelOrderEntity = CloseAllOrderModel();
    DatabaseService databaseService = DatabaseService();
    final userKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();

    final response = await http.post(
      Uri.parse(superTradeBaseApiEndPointUrl),
      body: {
        'activity': 'close-all-trade',
        'userKey': userKey,
        "deviceID": deviceID.toString(),
        "dataRelatedTo": param.dataRelatedTo,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      cancelOrderEntity = CloseAllOrderModel.fromJson(jsonData);

      if (cancelOrderEntity.status == 1) {
        log('Close All Orders Response => ${cancelOrderEntity.message.toString()}');
        if (param.context.mounted) {
          successToastMsg(param.context, cancelOrderEntity.message.toString());
        }
      } else {
        log('Invalid Response: ${cancelOrderEntity.message.toString()}');
        if (param.context.mounted) {
          failedToast(param.context, cancelOrderEntity.message.toString());
        }
      }
      // log('Close All Orders Response => ${cancelOrderEntity.message.toString()}');
    } else {
      log('Failed to close all orders. Status code: ${response.statusCode}');
    }
    return cancelOrderEntity;
  }
}
