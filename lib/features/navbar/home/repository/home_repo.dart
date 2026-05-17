import 'dart:convert';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/home/model/logo_model.dart';
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

  static Future<LogoModel> getLogo() async {
    LogoModel logoModel = LogoModel();
    try {
      final response = await _dio.post(
        superTradeBaseApiEndPointUrl,
        data: FormData.fromMap({'activity': 'logo'}),
      );
      log('Logo API Response Status: ${response.statusCode}');
      log('Logo API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        try {
          logoModel = LogoModel.fromJson(response.data);
          log('Logo Model Status: ${logoModel.status}');
          log('Logo URL: ${logoModel.logo}');
          log('Transparent URL: ${logoModel.transparent}');
          log('Logo Message: ${logoModel.message}');
        } catch (parseError) {
          log('Logo Parsing Error =>> $parseError');
          log('Response Data Type: ${response.data.runtimeType}');
        }
      } else {
        log('Failed to load data from server. Status: ${response.statusCode}');
      }
    } catch (e) {
      log('Logo Error =>> $e');
      log('Logo Error Type: ${e.runtimeType}');
    }
    return logoModel;
  }
}
