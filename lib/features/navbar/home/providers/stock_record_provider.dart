// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';
// import 'package:trading_app/core/constants/apis/api_urls.dart';
// import 'package:trading_app/features/navbar/home/model/get_stock_record_entity.dart';

// final stockRecordProvider =
//     StreamProvider.family<GetStockRecordEntity, StockRecordParams>(
//         (ref, StockRecordParams) async* {
//   GetStockRecordEntity getStockRecordEntity = GetStockRecordEntity();
//   final client = http.Client();
//   final url = Uri.parse(superTradeBaseApiEndPointUrl);
//   DatabaseService databaseService = DatabaseService();
//   final uKey = await databaseService.getUserData(key: userIDKey);
//    ref.keepAlive();
//   while (true) {
//     try {
//       final response = await client.post(url, body: {
//         'activity': "get-stock-record",
//         'userKey': uKey.toString(),
//         'symbolKey': StockRecordParams.symbolKey.toString(),
//         'dataRelatedTo': StockRecordParams.categoryName.toString()
//       });
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         log('SymbolKey =>>$StockRecordParams.symbolKey');
//         getStockRecordEntity = GetStockRecordEntity.fromJson(jsonResponse);
//         log('MCX Symbol Response =>> ${response.body}');
//         log('Get Stock Record message => ${getStockRecordEntity.message}');
//         yield getStockRecordEntity;
//       } else {
//         log('failed to load $StockRecordParams.categoryName data from server');
//       }
//     } catch (e) {
//       log('Get Stock Record Error =>> $e');
//     }
//     await Future.delayed(const Duration(milliseconds: 100));
//   }
// });

// class StockRecordParams {
//   final String symbolKey;
//   final String categoryName;
//   StockRecordParams({required this.symbolKey, required this.categoryName});
// }
