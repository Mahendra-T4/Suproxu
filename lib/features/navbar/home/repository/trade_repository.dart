import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/service/repositorie/global_respo.dart';
import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';

import 'dart:developer';

import 'package:suproxu/features/navbar/home/model/mcx_entity.dart';
import 'package:suproxu/features/navbar/home/model/nfo_entity.dart';
import 'package:suproxu/features/navbar/home/model/nse_enity.dart';

class TradeRepository {
  static Future<MCXDataEntity> mcxTradeDataLoader(
      {required String query}) async {
    final client = http.Client();
    MCXDataEntity mcxDataEntity = MCXDataEntity();
    final stockList = await GlobalRepository.stocksMapper();
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    final stockName = stockList.stocks!
        .firstWhere((stock) => stock.categoryName == 'MCX')
        .categoryCode;
    try {
      final response = await client.post(url, body: {
        'activity': "get-stock-list",
        'userKey': uKey.toString(),
        'dataRelatedTo': stockName,
        "deviceID": deviceID.toString(),
        'keyword': query
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        mcxDataEntity = MCXDataEntity.fromJson(jsonResponse);
        log(mcxDataEntity.message.toString());
        // log(response.body);
      } else {
        throw Exception('Failed to load mcx data from server');
      }
    } catch (e) {
      log('MCX Error => $e');
      throw Exception(e.toString());
    }
    return mcxDataEntity;
  }

  Future<NSEDataEntity> nseTradeDataLoader() async {
    final client = http.Client();
    final stockList = await GlobalRepository.stocksMapper();
    NSEDataEntity nseDataEntity = NSEDataEntity();
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    final stockName = stockList.stocks!
        .firstWhere((stock) => stock.categoryName == 'NSE')
        .categoryCode;
    try {
      final response = await client.post(url, body: {
        'activity': "get-stock-list",
        'userKey': uKey,
        "deviceID": deviceID.toString(),
        'dataRelatedTo': stockName
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        nseDataEntity = NSEDataEntity.fromJson(jsonResponse);
        log(nseDataEntity.message.toString());
        log('NSE SYMBOLKEY ${nseDataEntity.response?.first.symbolKey.toString()}');
      } else {
        throw ('Failed to load nse data from server');
      }
    } catch (e) {
      log('NSE Error => $e');
      throw (e.toString());
    }
    return nseDataEntity;
  }

  static Future<NFODataEntity> nfoTradeDataLoader(
      {required String query}) async {
    final client = http.Client();
    final stockList = await GlobalRepository.stocksMapper();
    NFODataEntity nfoDataEntity = NFODataEntity();
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    final stockName = stockList.stocks!
        .firstWhere((stock) => stock.categoryName == "NSE Future")
        .categoryCode;
    try {
      final response = await client.post(url, body: {
        'activity': "get-stock-list",
        'userKey': uKey,
        'dataRelatedTo': stockName,
        "deviceID": deviceID.toString(),
        'keyword': query
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        nfoDataEntity = NFODataEntity.fromJson(jsonResponse);
        log(nfoDataEntity.message.toString());
      } else {
        throw ('Failed to load nse data from server');
      }
    } catch (e) {
      log('NFO Error => $e');
      throw (e.toString());
    }
    return nfoDataEntity;
  }

  static Future<GetStockRecordEntity> getStockRecords(
      String symbolKey, String categoryName) async {
    GetStockRecordEntity getStockRecordEntity = GetStockRecordEntity();
    final client = http.Client();
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(url, body: {
        'activity': "get-stock-record",
        'userKey': uKey.toString(),
        'symbolKey': symbolKey.toString(),
        "deviceID": deviceID.toString(),
        'dataRelatedTo': categoryName
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log('SymbolKey =>>$symbolKey');
        getStockRecordEntity = GetStockRecordEntity.fromJson(jsonResponse);
        log('MCX Symbol Response =>> ${response.body}');
        log('Get Stock Record message => ${getStockRecordEntity.message}');
      } else {
        log('failed to load $categoryName data from server');
      }
    } catch (e) {
      log('Get Stock Record Error =>> $e');
    }
    return getStockRecordEntity;
  }

  static Future<GetStockRecordEntity> getMCXStockRecords(
      String symbolKey, String categoryName) async {
    GetStockRecordEntity getStockRecordEntity = GetStockRecordEntity();
    final client = http.Client();
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    try {
      while (true) {
        final response = await client.post(url, body: {
          'activity': "get-stock-record",
          'userKey': uKey.toString(),
          'symbolKey': symbolKey.toString(),
          "deviceID": deviceID.toString(),
          'dataRelatedTo': categoryName
        });
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          log('SymbolKey =>>$symbolKey');
          getStockRecordEntity = GetStockRecordEntity.fromJson(jsonResponse);
          log('MCX Symbol Response =>> ${response.body}');
          log('Get Stock Record message => ${getStockRecordEntity.message}');
        } else {
          log('failed to load $categoryName data from server');
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      log('Get Stock Record Error =>> $e');
    }
    return getStockRecordEntity;
  }
}
