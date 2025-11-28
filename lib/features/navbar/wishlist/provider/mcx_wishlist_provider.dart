// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:riverpod/riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';
// import 'package:trading_app/core/constants/apis/api_urls.dart';
// import 'package:trading_app/features/navbar/wishlist/model/mcx_wishlist_entity.dart';

// // Keep track of previous prices for comparison
// // Map<String, dynamic> _previousPrices = {};

// final mcxWishlistProvider = StreamProvider<MCXWishlistEntity>((ref) async* {
//   MCXWishlistEntity mcxWishlistEntity = MCXWishlistEntity();
//   DatabaseService databaseService = DatabaseService();
//   final uKey = await databaseService.getUserData(key: userIDKey);
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//   final deviceID = androidInfo.id.toString();
//   final url = Uri.parse(superTradeBaseApiEndPointUrl);
//   ref.keepAlive();
//   while (true) {
//     try {
//       final response = await http.post(url, body: {
//         'activity': 'wishlist',
//         'userKey': uKey.toString(),
//         "deviceID": deviceID.toString(),
//         'dataRelatedTo': 'MCX'
//       });
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         mcxWishlistEntity = MCXWishlistEntity.fromJson(jsonResponse);
//         // log(name: 'MCX WatchList', response.body);
//         log(name: 'User Key', uKey.toString());
//         log(name: 'Device ID', deviceID.toString());
//         log('WishList =>>${mcxWishlistEntity.message}');
//         yield mcxWishlistEntity;
//       } else {
//         log('Wishlist=>> failed to load data from Server');
//       }
//     } catch (error) {
//       if (error is TimeoutException) {
//         yield MCXWishlistEntity()
//           ..message = 'Request timed out. Please check your connection.';
//       } else {
//         yield MCXWishlistEntity()..message = 'Error loading data: $error';
//       }
//       log('Wishlist MCX Failed=>> $error');
//     }
//     await Future.delayed(const Duration(milliseconds: 400));
//   }
// });
