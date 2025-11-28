// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';
// import 'package:trading_app/core/constants/apis/api_urls.dart';
// import 'package:trading_app/core/service/device_service.dart';
// import 'package:trading_app/features/navbar/wishlist/model/wishlist_entity.dart';

// final nfoWishlistProvider = StreamProvider((ref) async* {
//   NFOWishlistEntity wishlistStocksEntity = NFOWishlistEntity();
//   DatabaseService databaseService = DatabaseService();
//   final url = Uri.parse(superTradeBaseApiEndPointUrl);
//   final uKey = await databaseService.getUserData(key: userIDKey);
//    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//   final deviceID = androidInfo.id.toString();
//   ref.keepAlive();
//   while (true) {
//     try {
//       final response = await http.post(url, body: {
//         'activity': 'wishlist',
//         'userKey': uKey,
//          "deviceID": deviceID.toString(),
//         'dataRelatedTo': 'NFO'
//       }).timeout(
//         const Duration(seconds: 10),
//         onTimeout: () {
//           throw TimeoutException('Request timed out');
//         },
//       );
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         wishlistStocksEntity = NFOWishlistEntity.fromJson(jsonResponse);
//         log('WishList =>>${wishlistStocksEntity.message}');
//         yield wishlistStocksEntity;
//       } else {
//         log('Wishlist=>> failed to load data from Server');
//       }
//     } catch (e) {
//       if (e is TimeoutException) {
//         yield NFOWishlistEntity()
//           ..message = 'Request timed out. Please check your connection.';
//       } else {
//         yield NFOWishlistEntity()
//           ..message = 'Error loading data: ${e.toString()}';
//       }
//     }
//     await Future.delayed(const Duration(milliseconds: 400));
//   }
// });
