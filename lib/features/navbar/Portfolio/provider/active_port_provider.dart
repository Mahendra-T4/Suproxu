import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/Portfolio/model/active_portfolio_stock_entity.dart';

final activePortfolioProvider =
    StreamProvider<ActivePortfolioStockEntity>((ref) async* {
  DatabaseService config = DatabaseService();
  final userKey = await config.getUserData(key: userIDKey);
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
  final url = Uri.parse(superTradeBaseApiEndPointUrl);
  ActivePortfolioStockEntity activePorfolioEntity =
      ActivePortfolioStockEntity();

  while (true) {
    try {
      final response = await http.post(url, body: {
        'activity': 'active-portfolio-stock',
        "deviceID": deviceID.toString(),
        'userKey': userKey
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        activePorfolioEntity =
            ActivePortfolioStockEntity.fromJson(jsonResponse);
        log('Active Porfolio : ${activePorfolioEntity.message}');
        log('Active Porfolio Response ${response.body}');
        yield ActivePortfolioStockEntity.fromJson(jsonResponse);
      } else {
        log('Failed to load data from Super Trade Server');
      }
    } catch (e) {
      log('Active Portfolio Repo Error =>> $e');
    }
    await Future.delayed(const Duration(milliseconds: 400));
  }
});
