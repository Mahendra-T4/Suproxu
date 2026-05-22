import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/Portfolio/model/active_portfolio_stock_entity.dart';

final activePortfolioProvider = StreamProvider<ActivePortfolioStockEntity>((
  ref,
) async* {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
  final url = Uri.parse(superTradeBaseApiEndPointUrl);

  // This provider runs indefinitely emitting updates every short delay.
  // Instead of capturing the userKey once, fetch it on each iteration so that
  // switching accounts or invalidating the provider will pick up the new
  // value.  Consumers can still call `ref.invalidate(activePortfolioProvider)`
  // when the logged-in user changes, but even without explicit invalidation the
  // loop will read the current key from the database each time.
  while (true) {
    final userKey = await DatabaseService().getUserData(key: userIDKey);
    try {
      final response = await http.post(
        url,
        body: {
          'activity': 'active-portfolio-stock',
          "deviceID": deviceID.toString(),
          'userKey': userKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final activePorfolioEntity = ActivePortfolioStockEntity.fromJson(
          jsonResponse,
        );
        log('Active Porfolio : ${activePorfolioEntity.message}');
        log('Active Porfolio Response ${response.body}');
        yield activePorfolioEntity;
      } else {
        log('Failed to load data from Super Trade Server');
      }
    } catch (e) {
      log('Active Portfolio Repo Error =>> $e');
    }

    // throttle the loop to avoid overwhelming the server; original code used
    // microseconds which is essentially tight loop, keep similar behaviour.
    await Future.delayed(const Duration(milliseconds: 100));
  }
});
