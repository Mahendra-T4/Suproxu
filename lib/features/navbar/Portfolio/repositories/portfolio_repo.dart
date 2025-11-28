import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/Portfolio/model/active_portfolio_stock_entity.dart';
import 'package:suproxu/features/navbar/Portfolio/model/close_portfolio_stock_entity.dart';

abstract class PortfolioRepository {
  static final client = http.Client();
  static DatabaseService config = DatabaseService();
  static final url = Uri.parse(superTradeBaseApiEndPointUrl);

  static Future<ActivePortfolioStockEntity> activePortfolio() async {
    ActivePortfolioStockEntity activePorfolioEntity =
        ActivePortfolioStockEntity();
    final userKey = await config.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(url,
          body: {'activity': 'active-portfolio-stock', "deviceID": deviceID.toString(), 'userKey': userKey});

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        activePorfolioEntity =
            ActivePortfolioStockEntity.fromJson(jsonResponse);
        log('Active Porfolio ${activePorfolioEntity.message}');
        return ActivePortfolioStockEntity.fromJson(jsonResponse);
      } else {
        return ActivePortfolioStockEntity(
            status: 0, message: 'Failed to load data from Super Trade Server');
      }
    } catch (e) {
      log('Active Portfolio Repo Error =>> $e');
      return ActivePortfolioStockEntity(status: 0, message: e.toString());
    }
  }

  static Future<ClosePortfolioStockEntity> closePortfolio() async {
    ClosePortfolioStockEntity closePorfolioEntity = ClosePortfolioStockEntity();
    final userKey = await config.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(url,
          body: {'activity': 'closed-portfolio-stock', "deviceID": deviceID.toString(), 'userKey': userKey});

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        closePorfolioEntity = ClosePortfolioStockEntity.fromJson(jsonResponse);
        log('Active Porfolio ${closePorfolioEntity.message}');
        return ClosePortfolioStockEntity.fromJson(jsonResponse);
      } else {
        return ClosePortfolioStockEntity(
            status: 0, message: 'Failed to load data from Super Trade Server');
      }
    } catch (e) {
      log('Active Portfolio Repo Error =>> $e');
      return ClosePortfolioStockEntity(status: 0, message: e.toString());
    }
  }
}
