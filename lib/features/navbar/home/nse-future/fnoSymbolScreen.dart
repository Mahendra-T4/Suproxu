// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';
// import 'package:trading_app/core/constants/apis/api_urls.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/core/service/Auth/user_validation.dart';
// import 'package:trading_app/features/navbar/home/mcx/McxSymbolsScreen.dart';
// import 'package:trading_app/features/navbar/home/model/buy_sale_entity.dart';
// import 'package:trading_app/features/navbar/home/model/get_stock_record_entity.dart';
// import 'package:trading_app/features/navbar/home/nse-future/nfo_symbol_helper.dart';
// import 'package:trading_app/features/navbar/home/repository/trade_repository.dart';
// import 'package:trading_app/features/navbar/profile/notification/notificationScreen.dart';

// // class SymbolScreenParams {
// //   final String symbol;
// //   final int index;
// //   final String symbolKey;

// //   const SymbolScreenParams({
// //     required this.symbol,
// //     required this.index,
// //     required this.symbolKey,
// //   });
// // }

// class NFOSymbols extends ConsumerStatefulWidget {
//   final SymbolScreenParams params;
//   // final String symbol;
//   // final int index;
//   // final String symbolKey;

//   const NFOSymbols({
//     super.key,
//     required this.params,
//   });

//   static const String routeName = '/nfo-symbol-screen';

//   @override
//   ConsumerState<NFOSymbols> createState() => _NFOSymbolsState();
// }

// class NFO {
//   dynamic ohlc;
//   dynamic response;

//   NFO({this.ohlc, this.response});
// }

// class _NFOSymbolsState extends ConsumerState<NFOSymbols> {
//   final StreamController<GetStockRecordEntity> _streamController =
//       StreamController<GetStockRecordEntity>.broadcast();
//   late Timer _timer;
//   @override
//   void initState() {
//     _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       AuthService().checkUserValidation();
//     });

//     AuthService().checkUserValidation();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // backgroundColor: Colors.black,
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//           ),
//           actions: [
//             IconButton(
//               icon: Image.asset(
//                 Assets.assetsImagesSupertradeNotification,
//                 scale: 20,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 Navigator.pushNamed(context, NotificationScreen.routeName);
//               },
//             ),
//           ],
//           title: Text(
//             widget.params.symbol,
//           ).textStyleH(),
//         ),
//         body: NFOSymbolHelper(
//           symbolKey: widget.params.symbolKey.toString(),
//         ));
//   }
// }
