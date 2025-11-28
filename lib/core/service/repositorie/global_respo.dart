import 'dart:convert';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/home/model/stock_list_entity.dart';

class GlobalRepository {
  static Future<StockListEntity> stocksMapper() async {
    final client = http.Client();
    StockListEntity stockListEntity = StockListEntity();
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(url, body: {
        'activity': 'get-stock-category',
        "deviceID": deviceID.toString(),
        'userKey': uKey.toString()
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        stockListEntity = StockListEntity.fromJson(jsonResponse);
        // stockName = stockListEntity.stocks!
        //     .firstWhere((stock) => stock.categoryCode == 'NFO');
        log('StockList Api Response =>> ${stockListEntity.message}');
      } else {
        throw Exception('failed to load data from server');
      }
    } catch (e) {
      log('StockList Api Error =>>$e');
    }
    return stockListEntity;
  }
}
