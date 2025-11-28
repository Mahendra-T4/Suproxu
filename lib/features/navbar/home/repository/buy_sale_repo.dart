import 'dart:convert';
import 'dart:developer'; // Correct import for the log function
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/features/navbar/home/model/buy_sale_entity.dart';
import 'package:suproxu/features/navbar/home/model/close_stock_param.dart';

final saleStockProvider =
    FutureProvider.family<BuySaleEntity, CloseStockParam>((ref, param) {
  return StockBuyAndSaleRepository.saleStock(
    symbolKey: param.symbolKey,
    categoryName: param.categoryName,
    stockPrice: param.stockPrice,
    stockQty: param.stockQty,
    context: param.context,
  );
});

final buyStockProvider =
    FutureProvider.family<BuySaleEntity, CloseStockParam>((ref, param) {
  return StockBuyAndSaleRepository.buyStock(
    symbolKey: param.symbolKey,
    categoryName: param.categoryName,
    stockPrice: param.stockPrice,
    stockQty: param.stockQty,
    context: param.context,
  );
});

abstract class StockBuyAndSaleRepository {
  static final client = http.Client();
  static final url = Uri.parse(superTradeBaseApiEndPointUrl);

  static Future<BuySaleEntity> buyStock(
      {required String symbolKey,
      required String categoryName,
      required String stockPrice,
      required String stockQty,
      required BuildContext context}) async {
    BuySaleEntity buySaleEntity = BuySaleEntity();
    try {
      DatabaseService databaseService = DatabaseService();
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final deviceID = androidInfo.id.toString();
      final userKey = await databaseService.getUserData(key: userIDKey);
      final response = await client.post(url, body: {
        'activity': 'buy-stock',
        'userKey': userKey,
        'symbolKey': symbolKey, // Fixed typo: 'symbolKey:' to 'symbolKey'
        'dataRelatedTo': categoryName,
        "deviceID": deviceID.toString(),
        'stockPrice': stockPrice,

        'stockQty': stockQty,
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log('buy stock message =>> ${jsonResponse['message']}');
        buySaleEntity = BuySaleEntity.fromJson(jsonResponse);
        if (buySaleEntity.status == 1) {
          successToastMsg(context, buySaleEntity.message.toString());
        } else {
          failedToast(context, buySaleEntity.message.toString());
        }
        return BuySaleEntity.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          log('Buy Stock Error => ${response.body}');
        }
        failedToast(context, buySaleEntity.message.toString());
        return BuySaleEntity(
          status: 0,
          message: 'failed to load Stock Buy data',
        );
      }
    } catch (e) {
      log('Buy Stock Repo Error =>> $e'); // Changed message for clarity
      return BuySaleEntity(
        status: 0,
        message: 'failed to load Stock Buy data',
      );
    }
  }

  static Future<BuySaleEntity> saleStock(
      {required String symbolKey,
      required String categoryName,
      required String stockPrice,
      required String stockQty,
      required BuildContext context}) async {
    BuySaleEntity buySaleEntity = BuySaleEntity();
    try {
      DatabaseService databaseService = DatabaseService();
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final deviceID = androidInfo.id.toString();
      final userKey = await databaseService.getUserData(key: userIDKey);
      final response = await client.post(url, body: {
        'activity': 'sale-stock',
        'userKey': userKey,
        'symbolKey': symbolKey, // Fixed typo: 'symbolKey:' to 'symbolKey'
        'dataRelatedTo': categoryName,
        'stockPrice': stockPrice,
        "deviceID": deviceID.toString(),
        'stockQty': stockQty,
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        buySaleEntity = BuySaleEntity.fromJson(jsonResponse);

        log('sale stock message =>> ${jsonResponse['message']}');
        if (buySaleEntity.status == 1) {
          successToastMsg(context, buySaleEntity.message.toString());
        } else {
          failedToast(context, buySaleEntity.message.toString());
        }
        return BuySaleEntity.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          log('Sale Stock Error => ${response.body}');
        }
        failedToast(context, buySaleEntity.message.toString());
        return BuySaleEntity(
          status: 0,
          message: 'failed to load Stock Sale data',
        );
      }
    } catch (e) {
      log('Sale Stock Repo Error =>> $e');
      return BuySaleEntity(
        status: 0,
        message: 'failed to load Stock Sale data',
      );
    }
  }
}
