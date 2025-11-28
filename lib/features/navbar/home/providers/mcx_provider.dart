// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';
// import 'package:trading_app/core/constants/apis/api_urls.dart';
// import 'package:trading_app/core/service/repositorie/global_respo.dart';
// import 'package:trading_app/features/navbar/home/model/mcx_entity.dart';

// final mcxProvider =
//     StreamProvider.family<MCXDataEntity, String>((ref, query) async* {
//   final client = http.Client();
//   try {
//     final stockList = await GlobalRepository.stocksMapper();
//     final url = Uri.parse(superTradeBaseApiEndPointUrl);
//     DatabaseService databaseService = DatabaseService();
//     final uKey = await databaseService.getUserData(key: userIDKey);
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//     final deviceID = androidInfo.id.toString();
//     final stockName = stockList.stocks!
//         .firstWhere((stock) => stock.categoryName == 'MCX')
//         .categoryCode;
//     ref.keepAlive();

//     while (true) {
//       try {
//         final response = await client.post(
//           url,
//           body: {
//             'activity': "get-stock-list",
//             'userKey': uKey,
//             'dataRelatedTo': stockName,
//             "deviceID": deviceID.toString(),
//             'keyword': query
//           },
//         ).timeout(
//           const Duration(seconds: 10),
//           onTimeout: () {
//             throw TimeoutException('Request timed out');
//           },
//         );

//         if (response.statusCode == 200) {
//           final jsonResponse = jsonDecode(response.body);
//           yield MCXDataEntity.fromJson(jsonResponse);
//         } else {
//           throw ('Failed to load MCX data from server: ${response.statusCode}');
//         }
//       } catch (e) {
//         log('MCX Data Error: $e');
//         if (e is TimeoutException) {
//           yield MCXDataEntity()
//             ..message = 'Request timed out. Please check your connection.';
//         } else {
//           yield MCXDataEntity()
//             ..message = 'Error loading data: ${e.toString()}';
//         }
//       }

//       // Increased delay to reduce server load
//       await Future.delayed(const Duration(milliseconds: 400));
//     }
//   } finally {
//     client.close();
//   }
// });
