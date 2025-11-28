import 'dart:convert';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/home/model/stock_cat_list.dart';

// typedef EitherHandler<T> = Either<String, T>;

class HomeRepository {
  static final Dio _dio = Dio();

  static Future<StocksCategoryEntity> getStockCategoryList() async {
    DatabaseService databaseService = DatabaseService();
    StocksCategoryEntity stocksCategoryEntity = StocksCategoryEntity();

    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();

    try {
      final response = await _dio.post(
        stocksListApiEndPointUrl,
        data: {
          'activity': 'get-stock-category',
          "deviceID": deviceID.toString(),
          'userKey': uKey,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.data);
        stocksCategoryEntity = StocksCategoryEntity.fromJson(jsonResponse);
        log(stocksCategoryEntity.message.toString());
        // return right(stocksCategoryEntity);
      } else {
        log('Failed to load data from server');
      }
    } catch (e) {
      log('Stock Category Error =>> $e');
    }
    return stocksCategoryEntity;
  }
}
