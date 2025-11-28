// import 'dart:developer' as developer;

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
// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';
// import 'package:trading_app/core/constants/apis/api_urls.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/constants/extensions/double_etx.dart';
// import 'package:trading_app/core/constants/widget/toast.dart';
// import 'package:trading_app/core/extensions/color_ext.dart';
// import 'package:trading_app/core/extensions/neg-pos-tracker.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/core/service/Auth/user_validation.dart';
// import 'package:trading_app/features/navbar/home/mcx/McxSymbolsScreen.dart';
// import 'package:trading_app/features/navbar/home/model/buy_sale_entity.dart';
// import 'package:trading_app/features/navbar/home/model/get_stock_record_entity.dart';
// import 'package:trading_app/features/navbar/home/providers/nfo_symbol_ws_provider.dart';
// import 'package:trading_app/features/navbar/home/repository/trade_repository.dart';

// class NFOSymbolHelper extends ConsumerStatefulWidget {
//   final String symbolKey;
//   // final String symbol;
//   // final int index;
//   // final String symbolKey;

//   const NFOSymbolHelper({
//     super.key,
//     required this.symbolKey,
//   });

//   static const String routeName = '/nfo-symbol-screen';

//   @override
//   ConsumerState<NFOSymbolHelper> createState() => _NFOSymbolHelperState();
// }

// class NFO {
//   dynamic ohlc;
//   dynamic response;

//   NFO({this.ohlc, this.response});
// }

// class _NFOSymbolHelperState extends ConsumerState<NFOSymbolHelper> {
//   final StreamController<GetStockRecordEntity> _streamController =
//       StreamController<GetStockRecordEntity>.broadcast();
//   final ValueNotifier<int> lotsNotifierMrk = ValueNotifier<int>(1);
//   final ValueNotifier<int> lotsNotifierLmt = ValueNotifier<int>(1);
//   final TextEditingController _lotsMktController =
//       TextEditingController(text: '1');
//   final TextEditingController _lotsOdrController =
//       TextEditingController(text: '1');

//   bool isMarketOpen = true;
//   final TextEditingController _usernameController =
//       TextEditingController(text: '0');
//   int lots = 1; // Variable to track the lot count
//   int selecteddTab = 0;
//   late Timer _timer;
//   bool isBuyClicked = false;
//   bool isSellClicked = false;
//   var ohlcNFO;
//   var recordNFO;

//   final client = http.Client();
//   final url = Uri.parse(superTradeBaseApiEndPointUrl);

//   NFO nfo = NFO();

//   Future<void> buyStock(
//       {required String symbolKey,
//       required String activity,
//       required String categoryName,
//       required String stockPrice,
//       required String stockQty,
//       required BuildContext context}) async {
//     BuySaleEntity buySaleEntity = BuySaleEntity();
//     try {
//       DatabaseService databaseService = DatabaseService();
//       final userKey = await databaseService.getUserData(key: userIDKey);
//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       final deviceID = androidInfo.id.toString();
//       if (!mounted) return;
//       setState(() {
//         isBuyClicked = true;
//       });
//       final response = await client.post(url, body: {
//         // 'activity': 'buy-stock',
//         'activity': activity,
//         'userKey': userKey,
//         'symbolKey': symbolKey, // Fixed typo: 'symbolKey:' to 'symbolKey'
//         'dataRelatedTo': categoryName,
//         'stockPrice': stockPrice,
//         "deviceID": deviceID.toString(),
//         'stockQty': stockQty,
//       });
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         setState(() {
//           isBuyClicked = false;
//         });
//         log('buy stock message =>> ${jsonResponse['message']}');
//         buySaleEntity = BuySaleEntity.fromJson(jsonResponse);

//         showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               contentPadding: const EdgeInsets.all(16),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.check_circle_outlined,
//                     color: Colors.green,
//                     size: 48,
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     buySaleEntity.message.toString(),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 Center(
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text(
//                       "OK",
//                       style: TextStyle(color: Colors.black, fontSize: 20),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//         // return BuySaleEntity.fromJson(jsonResponse);
//       } else {
//         if (kDebugMode) {
//           log('Buy Stock Error => ${response.body}');
//         }
//         // return BuySaleEntity(
//         //   status: 0,
//         //   message: 'failed to load Stock Buy data',
//         // );
//       }
//     } catch (e) {
//       log('Buy Stock Repo Error =>> $e'); // Changed message for clarity
//       // return BuySaleEntity(
//       //   status: 0,
//       //   message: 'failed to load Stock Buy data',
//       // );
//     }
//   }

//   Future<void> saleStock(
//       {required String symbolKey,
//       required String activity,
//       required String categoryName,
//       required String stockPrice,
//       required String stockQty,
//       required BuildContext context}) async {
//     BuySaleEntity buySaleEntity = BuySaleEntity();
//     try {
//       DatabaseService databaseService = DatabaseService();
//       final userKey = await databaseService.getUserData(key: userIDKey);
//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       final deviceID = androidInfo.id.toString();
//       setState(() {
//         isSellClicked = true;
//       });
//       final response = await client.post(url, body: {
//         // 'activity': 'sale-stock',
//         'activity': activity,
//         'userKey': userKey,
//         'symbolKey': symbolKey, // Fixed typo: 'symbolKey:' to 'symbolKey'
//         'dataRelatedTo': categoryName,
//         'stockPrice': stockPrice,
//         "deviceID": deviceID.toString(),
//         'stockQty': stockQty,
//       });
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         buySaleEntity = BuySaleEntity.fromJson(jsonResponse);
//         if (!mounted) return;
//         setState(() {
//           isSellClicked = false;
//         });
//         showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               contentPadding: const EdgeInsets.all(16),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.check_circle_outlined,
//                     color: Colors.green,
//                     size: 48,
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     buySaleEntity.message.toString(),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 Center(
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text(
//                       "OK",
//                       style: TextStyle(color: Colors.black, fontSize: 20),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );

//         log('sale stock message =>> ${jsonResponse['message']}');

//         // return BuySaleEntity.fromJson(jsonResponse);
//       } else {
//         if (kDebugMode) {
//           log('Sale Stock Error => ${response.body}');
//         }
//         // return BuySaleEntity(
//         //   status: 0,
//         //   message: 'failed to load Stock Sale data',
//         // );
//       }
//     } catch (e) {
//       log('Sale Stock Repo Error =>> $e');
//       // return BuySaleEntity(
//       //   status: 0,
//       //   message: 'failed to load Stock Sale data',
//       // );
//     }
//   }

//   dynamic uBalance;
//   initUser() async {
//     DatabaseService databaseService = DatabaseService();
//     final userBalance = await databaseService.getUserData(key: userBalanceKey);
//     if (!mounted) return;
//     setState(() {
//       uBalance = userBalance;
//     });
//   }

//   void _checkMarketStatus() {
//     final now = DateTime.now();
//     final marketOpenTime = DateTime(now.year, now.month, now.day, 9, 15);
//     final marketCloseTime = DateTime(now.year, now.month, now.day, 15, 30);

//     // Make sure the system is not on Saturday or Sunday
//     final isWeekday =
//         now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;

//     final newMarketStatus = isWeekday &&
//         now.isAfter(marketOpenTime) &&
//         now.isBefore(marketCloseTime);

//     if (isMarketOpen != newMarketStatus) {
//       setState(() {
//         isMarketOpen = newMarketStatus;
//       });
//     }

//     print('Now: $now');
//     print('Market Open Time: $marketOpenTime');
//     print('Market Close Time: $marketCloseTime');
//     print('Market Status: $isMarketOpen');
//   }

//   @override
//   void initState() {
//     _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       _fetchLiveData();
//       initUser();
//       AuthService().checkUserValidation();
//       _checkMarketStatus();
//     });

//     lotsNotifierMrk.addListener(() {
//       if (lotsNotifierMrk.value > 0) {
//         _lotsMktController.text = lotsNotifierMrk.value.toString();
//       }
//     });

//     lotsNotifierLmt.addListener(() {
//       if (lotsNotifierLmt.value > 0) {
//         _lotsOdrController.text = lotsNotifierLmt.value.toString();
//       }
//     });
//     _fetchLiveData();
//     initUser();
//     _checkMarketStatus();
//     AuthService().checkUserValidation();
//     super.initState();
//   }

//   Future<void> _fetchLiveData() async {
//     if (!mounted) return;

//     try {
//       GetStockRecordEntity data = await TradeRepository.getStockRecords(
//         widget.symbolKey,
//         'NFO',
//       );

//       if (data.status != 1) {
//         if (!_streamController.isClosed && mounted) {
//           _streamController.addError('Invalid data status: ${data.message}');
//         }
//         return;
//       }

//       if (data.response.isEmpty) {
//         if (!_streamController.isClosed && mounted) {
//           _streamController.addError('No data available');
//         }
//         return;
//       }

//       if (!_streamController.isClosed && mounted) {
//         _streamController.add(data);
//       }
//     } catch (e) {
//       developer.log("Error fetching live data: $e");
//       if (!_streamController.isClosed && mounted) {
//         _streamController.addError('Failed to fetch data: ${e.toString()}');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final webSocket = ref.watch(nfoSymbolWSProvider(widget.symbolKey));
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     if (webSocket.isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (webSocket.errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, color: Colors.red, size: 48),
//             const SizedBox(height: 16),
//             Text('Error: ${webSocket.errorMessage}'),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () {
//                 ref
//                     .read(nfoSymbolWSProvider(widget.symbolKey).notifier)
//                     .reconnect();
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (webSocket.record == null) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.info_outline, color: Colors.blue, size: 48),
//             SizedBox(height: 16),
//             Text('No NFO data available'),
//           ],
//         ),
//       );
//     }

//     if (webSocket.record?.status != 1) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.warning_amber_rounded,
//                 color: Colors.orange, size: 48),
//             const SizedBox(height: 16),
//             Text(webSocket.record!.message.toString()),
//           ],
//         ),
//       );
//     }

//     var record = webSocket.record!.response.first;

//     var ohlc = record.ohlc;

//     return Column(
//       children: [
//         SizedBox(height: screenHeight * 0.01),
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: kWhiteColor,
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => selecteddTab = 0),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       alignment: Alignment.center,
//                       padding:
//                           EdgeInsets.symmetric(vertical: screenHeight * 0.018),
//                       decoration: BoxDecoration(
//                         // color: selecteddTab == 1
//                         //     ? Colors.green
//                         //     : Colors.transparent,
//                         gradient: selecteddTab == 0
//                             ? LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   const Color(0xFF00C853),
//                                   const Color(
//                                     0xFF00C853,
//                                   ).withOpacity(0.8),
//                                 ],
//                               )
//                             : null,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: selecteddTab == 0
//                             ? [
//                                 BoxShadow(
//                                   color:
//                                       const Color(0xFF00C853).withOpacity(0.3),
//                                   spreadRadius: 1,
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ]
//                             : null,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.show_chart,
//                             color: selecteddTab == 0 ? Colors.white : zBlack,
//                             size: 20,
//                           ),
//                           SizedBox(width: 8.h),
//                           Text(
//                             "Market",
//                             style: TextStyle(
//                               color: selecteddTab == 0
//                                   ? Colors.white
//                                   : Colors.black,
//                               fontWeight: FontWeight.w800,
//                               fontSize: 16,
//                               // fontFamily: 'JetBrainsMono',
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.h),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => selecteddTab = 1),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       alignment: Alignment.center,
//                       padding:
//                           EdgeInsets.symmetric(vertical: screenHeight * 0.018),
//                       decoration: BoxDecoration(
//                         color: selecteddTab == 1
//                             ? const Color(0xFF2C2C2E)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(12),
//                         gradient: selecteddTab == 1
//                             ? LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   const Color(0xFF00C853),
//                                   const Color(0xFF00C853).withOpacity(0.8),
//                                 ],
//                               )
//                             : null,
//                         boxShadow: selecteddTab == 1
//                             ? [
//                                 BoxShadow(
//                                   color:
//                                       const Color(0xFF00C853).withOpacity(0.3),
//                                   spreadRadius: 1,
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ]
//                             : null,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.receipt_long,
//                             color: selecteddTab == 1 ? Colors.white : zBlack,
//                             size: 20,
//                           ),
//                           SizedBox(width: 8.h),
//                           Text(
//                             "Order",
//                             style: TextStyle(
//                               color: selecteddTab == 1 ? Colors.white : zBlack,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16,
//                               fontFamily: 'JetBrainsMono',
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           child: StreamBuilder<GetStockRecordEntity>(
//             stream: _streamController.stream,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError) {
//                 // return Center(child: Text("Error: ${snapshot.error}"));\
//                 log("Error: ${snapshot.error}");
//               }
//               if (!snapshot.hasData || snapshot.data?.response == null) {
//                 // return const Center(child: Text("No Data Available"));
//                 log("Error: ${snapshot.error}");
//               }

//               if (snapshot.data!.status == 1) {
//                 nfo = NFO(
//                   ohlc: snapshot.data!.response.first.ohlc,
//                   response: snapshot.data!.response.first,
//                 );
//               }

//               // ! MARKET
//               return snapshot.data!.status == 1
//                   ? selecteddTab == 0
//                       ? Padding(
//                           padding: EdgeInsets.all(screenWidth * 0.04),
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // SizedBox(height: screenHeight * 0.02),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 16),
//                                   margin:
//                                       const EdgeInsets.symmetric(vertical: 8),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(15),
//                                     color: Colors.white,
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text(
//                                         "Unit",
//                                       ).textStyleH4(),
//                                       ValueListenableBuilder<int>(
//                                         valueListenable: lotsNotifierMrk,
//                                         builder: (context, lots, child) {
//                                           return Row(
//                                             children: [
//                                               Material(
//                                                 color: Colors.transparent,
//                                                 child: InkWell(
//                                                   onTap: () => lots > 1
//                                                       ? lotsNotifierMrk.value--
//                                                       : null,
//                                                   borderRadius:
//                                                       BorderRadius.circular(30),
//                                                   child: Container(
//                                                     padding:
//                                                         const EdgeInsets.all(8),
//                                                     decoration: BoxDecoration(
//                                                       shape: BoxShape.circle,
//                                                       color: Colors.grey
//                                                           .withOpacity(0.2),
//                                                     ),
//                                                     child: Icon(
//                                                       Icons.remove,
//                                                       color: zBlack,
//                                                       size: screenWidth * 0.05,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Container(
//                                                 width: screenWidth * 0.20,
//                                                 margin:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 16),
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   color: Colors.grey
//                                                       .withOpacity(0.2),
//                                                 ),
//                                                 child: TextField(
//                                                   controller:
//                                                       _lotsMktController,
//                                                   textAlign: TextAlign.center,
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   inputFormatters: [
//                                                     FilteringTextInputFormatter
//                                                         .digitsOnly
//                                                   ],
//                                                   style: TextStyle(
//                                                     fontSize:
//                                                         screenWidth * 0.045,
//                                                     color: zBlack,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                   decoration:
//                                                       const InputDecoration(
//                                                     contentPadding:
//                                                         EdgeInsets.symmetric(
//                                                       vertical: 8,
//                                                       horizontal: 12,
//                                                     ),
//                                                     border: InputBorder.none,
//                                                     isDense: true,
//                                                   ),
//                                                   onChanged: (value) {
//                                                     if (value.isNotEmpty) {
//                                                       final newLots =
//                                                           int.tryParse(value) ??
//                                                               1;
//                                                       if (newLots > 0) {
//                                                         lotsNotifierMrk.value =
//                                                             newLots;
//                                                       }
//                                                     }
//                                                   },
//                                                 ),
//                                               ),
//                                               // Container(
//                                               //   width: screenWidth * 0.15,
//                                               //   margin:
//                                               //       const EdgeInsets.symmetric(
//                                               //           horizontal: 16),
//                                               //   padding:
//                                               //       const EdgeInsets.symmetric(
//                                               //           vertical: 8,
//                                               //           horizontal: 12),
//                                               //   decoration: BoxDecoration(
//                                               //     borderRadius:
//                                               //         BorderRadius.circular(12),
//                                               //     color: Colors.grey
//                                               //         .withOpacity(0.2),
//                                               //   ),
//                                               //   child: Text(
//                                               //     "$lots",
//                                               //     style: TextStyle(
//                                               //       fontSize: screenWidth * 0.045,
//                                               //       color: zBlack,
//                                               //       fontWeight: FontWeight.bold,
//                                               //     ),
//                                               //     textAlign: TextAlign.center,
//                                               //   ),
//                                               // ),
//                                               Material(
//                                                 color: Colors.transparent,
//                                                 child: InkWell(
//                                                   onTap: () =>
//                                                       lotsNotifierMrk.value++,
//                                                   borderRadius:
//                                                       BorderRadius.circular(30),
//                                                   child: Container(
//                                                     padding:
//                                                         const EdgeInsets.all(8),
//                                                     decoration: BoxDecoration(
//                                                       shape: BoxShape.circle,
//                                                       color: Colors.grey
//                                                           .withOpacity(0.2),
//                                                     ),
//                                                     child: Icon(
//                                                       Icons.add,
//                                                       color: zBlack,
//                                                       size: screenWidth * 0.05,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(height: screenHeight * 0.02),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     isSellClicked
//                                         ? SizedBox(
//                                             width: screenWidth / 2.5,
//                                             child: ElevatedButton(
//                                               onPressed: () {},
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor: greyColor,
//                                                 padding: EdgeInsets.symmetric(
//                                                   vertical: screenHeight * 0.02,
//                                                 ),
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                 ),
//                                               ),
//                                               child: const Text(
//                                                 'PROCESSING...',
//                                                 textAlign: TextAlign.center,
//                                               ).textStyleH1(),
//                                             ),
//                                           )
//                                         : Container(
//                                             width: screenWidth / 2.5,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                               gradient: const LinearGradient(
//                                                 begin: Alignment.topLeft,
//                                                 end: Alignment.bottomRight,
//                                                 colors: [
//                                                   Color(0xFFFF3B30),
//                                                   Color(0xFFFF3B30),
//                                                 ],
//                                               ),
//                                               // boxShadow: [
//                                               //   BoxShadow(
//                                               //     color: const Color(0xFFFF3B30)
//                                               //         .withOpacity(0.3),
//                                               //     spreadRadius: 1,
//                                               //     blurRadius: 8,
//                                               //     offset: const Offset(0, 4),
//                                               //   ),
//                                               // ],
//                                               border: Border.all(
//                                                 color:
//                                                     Colors.red.withOpacity(0.3),
//                                                 width: 1,
//                                               ),
//                                             ),
//                                             child: Material(
//                                               color: Colors.transparent,
//                                               child: InkWell(
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                                 onTap: () {
//                                                   saleStock(
//                                                     activity: 'sale-stock',
//                                                     context: context,
//                                                     symbolKey: widget.symbolKey,
//                                                     categoryName: 'NFO',
//                                                     stockPrice:
//                                                         '${ohlc.salePrice} * ${lotsNotifierMrk.value}',
//                                                     stockQty: lotsNotifierMrk
//                                                         .value
//                                                         .toString(),
//                                                   );
//                                                   // if (isMarketOpen) {

//                                                   // } else {
//                                                   //   showDialog(
//                                                   //     context: context,
//                                                   //     builder: (context) =>
//                                                   //         const WarningAlertBox(
//                                                   //       title: 'Warning',
//                                                   //       message:
//                                                   //           'Market Closed You Cant Sale Stocks!',
//                                                   //     ),
//                                                   //   );
//                                                   // }
//                                                 },
//                                                 child: Container(
//                                                   padding: EdgeInsets.symmetric(
//                                                       vertical:
//                                                           screenHeight * 0.02),
//                                                   child: Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           const Icon(Icons.sell,
//                                                               color:
//                                                                   Colors.white,
//                                                               size: 20),
//                                                           const SizedBox(
//                                                               width: 8),
//                                                           const Text(
//                                                             "SELL",
//                                                           ).textStyleH1W(),
//                                                         ],
//                                                       ),
//                                                       const SizedBox(height: 4),
//                                                       Text(
//                                                         "₹${formatDoubleNumber(ohlc.salePrice)}",
//                                                       ).textStyleH1W(),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                     SizedBox(width: screenWidth * 0.03),
//                                     isBuyClicked
//                                         ? SizedBox(
//                                             width: screenWidth / 2.5,
//                                             child: ElevatedButton(
//                                               onPressed: () {},
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor: greyColor,
//                                                 padding: EdgeInsets.symmetric(
//                                                   vertical: screenHeight * 0.02,
//                                                 ),
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                 ),
//                                               ),
//                                               child: const Text(
//                                                 'PROCESSING...',
//                                                 textAlign: TextAlign.center,
//                                               ).textStyleH1(),
//                                             ),
//                                           )
//                                         : Container(
//                                             width: screenWidth / 2.5,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                               gradient: const LinearGradient(
//                                                 begin: Alignment.topLeft,
//                                                 end: Alignment.bottomRight,
//                                                 colors: [
//                                                   Color(0xFF34C759),
//                                                   Color(0xFF34C759),
//                                                 ],
//                                               ),
//                                               // boxShadow: [
//                                               //   BoxShadow(
//                                               //     color: const Color(0xFF34C759)
//                                               //         .withOpacity(0.3),
//                                               //     spreadRadius: 1,
//                                               //     blurRadius: 8,
//                                               //     offset: const Offset(0, 4),
//                                               //   ),
//                                               // ],
//                                               border: Border.all(
//                                                 color: Colors.green
//                                                     .withOpacity(0.3),
//                                                 width: 1,
//                                               ),
//                                             ),
//                                             child: Material(
//                                               color: Colors.transparent,
//                                               child: InkWell(
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                                 onTap: () {
//                                                   buyStock(
//                                                     context: context,
//                                                     activity: 'buy-stock',
//                                                     symbolKey: widget.symbolKey,
//                                                     categoryName: 'NFO',
//                                                     stockPrice:
//                                                         '${ohlc.buyPrice} * ${lotsNotifierMrk.value}',
//                                                     stockQty: lotsNotifierMrk
//                                                         .value
//                                                         .toString(),
//                                                   );
//                                                   // if (isMarketOpen) {

//                                                   // } else {
//                                                   //   showDialog(
//                                                   //     context: context,
//                                                   //     builder: (context) =>
//                                                   //         const WarningAlertBox(
//                                                   //       title: 'Warning',
//                                                   //       message:
//                                                   //           'Market Closed You Cant Buy Stocks!',
//                                                   //     ),
//                                                   //   );
//                                                   // }
//                                                 },
//                                                 child: Container(
//                                                   padding: EdgeInsets.symmetric(
//                                                       vertical:
//                                                           screenHeight * 0.02),
//                                                   child: Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           const Icon(
//                                                               Icons
//                                                                   .shopping_cart,
//                                                               color:
//                                                                   Colors.white,
//                                                               size: 20),
//                                                           const SizedBox(
//                                                               width: 8),
//                                                           const Text(
//                                                             "BUY",
//                                                           ).textStyleH1W(),
//                                                         ],
//                                                       ),
//                                                       const SizedBox(height: 4),
//                                                       Text(
//                                                         "₹${formatDoubleNumber(ohlc.buyPrice)}",
//                                                       ).textStyleH1W(),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                   ],
//                                 ),
//                                 SizedBox(height: screenHeight * 0.03),
//                                 Container(
//                                   margin:
//                                       EdgeInsets.only(top: 10.w, bottom: 10.w),
//                                   // padding: EdgeInsets.all(10.r),
//                                   // width: double.infinity,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20.r),
//                                     color: Colors.white,
//                                     // boxShadow: [
//                                     //   BoxShadow(
//                                     //     color: Colors.black.withOpacity(0.1),
//                                     //     blurRadius: 10,
//                                     //     offset: const Offset(0, 5),
//                                     //   ),
//                                     // ],
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Container(
//                                               height: screenHeight * 0.08,
//                                               width: screenWidth * 0.28,
//                                               decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   color: Colors.white.blink(
//                                                       baseValue: ohlc.lastPrice,
//                                                       compValue:
//                                                           ohlc.salePrice)),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   const Text(
//                                                     'Bid',
//                                                   ).textStyleH2(),
//                                                   SizedBox(height: 4.h),
//                                                   Text(
//                                                     ohlc.salePrice.toString(),
//                                                   ).textStyleH1(),
//                                                 ],
//                                               ),
//                                             ),
//                                             // _buildInfoBox(
//                                             //     "Bid\n${ohlc.lastPrice}",
//                                             //     screenWidth,
//                                             //     screenHeight),

//                                             Container(
//                                               height: screenHeight * 0.08,
//                                               width: screenWidth * 0.28,
//                                               decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   color: Colors.white.blink(
//                                                       baseValue: ohlc.lastPrice,
//                                                       compValue:
//                                                           ohlc.buyPrice)),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   const Text(
//                                                     'Ask',
//                                                   ).textStyleH2(),
//                                                   SizedBox(height: 4.h),
//                                                   Text(
//                                                     ohlc.buyPrice.toString(),
//                                                   ).textStyleH1(),
//                                                 ],
//                                               ),
//                                             ),

//                                             // _buildInfoBox(
//                                             //     "Ask\n${ohlc.buyPrice}",
//                                             //     screenWidth,
//                                             //     screenHeight),
//                                             _buildInfoBox(
//                                                 "Last\n${ohlc.lastPrice}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             _buildInfoBox("Open\n${ohlc.open}",
//                                                 screenWidth, screenHeight),
//                                             _buildInfoBox(
//                                                 "Close\n${ohlc.close}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             _buildInfoBox(
//                                                 "Atp\n${record.averageTradePrice}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             _buildInfoBox("High\n${ohlc.high}",
//                                                 screenWidth, screenHeight),
//                                             _buildInfoBox("Low\n${ohlc.low}",
//                                                 screenWidth, screenHeight),
//                                             _buildInfoBox(
//                                                 "Volume\n${ohlc.volume}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             _buildInfoBox(
//                                                 "Upper ckt\n${record.upperCKT}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             _buildInfoBox(
//                                                 "Lower ckt\n${record.lowerCKT}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             Container(
//                                               height: screenHeight * 0.08,
//                                               width: screenWidth * 0.28,
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     'Change',
//                                                     style: TextStyle(
//                                                       color: record.change
//                                                               .toString()
//                                                               .contains('-')
//                                                           ? Colors.red
//                                                           : Colors.green,
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 4.h),
//                                                   Text(
//                                                     record.change.toString(),
//                                                     style: TextStyle(
//                                                       color: record.change
//                                                               .toString()
//                                                               .contains('-')
//                                                           ? Colors.red
//                                                           : Colors.green,
//                                                       fontSize: 15,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontFamily:
//                                                           'JetBrainsMono',
//                                                       letterSpacing: 0.5,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             // _buildInfoBox(
//                                             //     "Change\n${record.change}",
//                                             //     screenWidth,
//                                             //     screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             _buildInfoBox(
//                                                 "Last Buy\n${record.lastBuy.price}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             _buildInfoBox(
//                                                 "Last Sell\n${record.lastSell.price}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             _buildInfoBox(
//                                                 "LotSize\n${record.lotSize}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             // _buildInfoBox("Buyer\nN/A",
//                                             //     screenWidth, screenHeight),
//                                             // _buildInfoBox("Seller\nN/A",
//                                             //     screenWidth, screenHeight),
//                                             _buildInfoBox(
//                                                 "Open Interest\n${record.openInterest}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         )
//                       //! LIMIT
//                       : SingleChildScrollView(
//                           child: Padding(
//                             padding: EdgeInsets.all(screenWidth * 0.04),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // SizedBox(height: screenHeight * 0.02),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 16),
//                                   margin:
//                                       const EdgeInsets.symmetric(vertical: 8),
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(15),
//                                       color: kWhiteColor),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "Unit",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: screenWidth * 0.045,
//                                           color: zBlack,
//                                           letterSpacing: 0.5,
//                                         ),
//                                       ),
//                                       ValueListenableBuilder<int>(
//                                         valueListenable: lotsNotifierLmt,
//                                         builder: (context, lots, child) {
//                                           return Row(
//                                             children: [
//                                               Material(
//                                                 color: Colors.transparent,
//                                                 child: InkWell(
//                                                   onTap: () => lots > 1
//                                                       ? lotsNotifierLmt.value--
//                                                       : null,
//                                                   borderRadius:
//                                                       BorderRadius.circular(30),
//                                                   child: Container(
//                                                     padding:
//                                                         const EdgeInsets.all(8),
//                                                     decoration: BoxDecoration(
//                                                       shape: BoxShape.circle,
//                                                       color: Colors.grey
//                                                           .withOpacity(0.2),
//                                                     ),
//                                                     child: Icon(
//                                                       Icons.remove,
//                                                       color: zBlack,
//                                                       size: screenWidth * 0.05,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Container(
//                                                 width: screenWidth * 0.20,
//                                                 margin:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 16),
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   color: Colors.grey
//                                                       .withOpacity(0.2),
//                                                 ),
//                                                 child: TextField(
//                                                   controller:
//                                                       _lotsOdrController,
//                                                   textAlign: TextAlign.center,
//                                                   inputFormatters: [
//                                                     FilteringTextInputFormatter
//                                                         .digitsOnly
//                                                   ],
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   style: TextStyle(
//                                                     fontSize:
//                                                         screenWidth * 0.045,
//                                                     color: zBlack,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                   decoration:
//                                                       const InputDecoration(
//                                                     contentPadding:
//                                                         EdgeInsets.symmetric(
//                                                       vertical: 8,
//                                                       horizontal: 12,
//                                                     ),
//                                                     border: InputBorder.none,
//                                                     isDense: true,
//                                                   ),
//                                                   onChanged: (value) {
//                                                     if (value.isNotEmpty) {
//                                                       final newLots =
//                                                           int.tryParse(value) ??
//                                                               1;
//                                                       if (newLots > 0) {
//                                                         lotsNotifierLmt.value =
//                                                             newLots;
//                                                       }
//                                                     }
//                                                   },
//                                                 ),
//                                               ),
//                                               // Container(
//                                               //   width: screenWidth * 0.15,
//                                               //   margin:
//                                               //       const EdgeInsets.symmetric(
//                                               //           horizontal: 16),
//                                               //   padding:
//                                               //       const EdgeInsets.symmetric(
//                                               //           vertical: 8,
//                                               //           horizontal: 12),
//                                               //   decoration: BoxDecoration(
//                                               //     borderRadius:
//                                               //         BorderRadius.circular(12),
//                                               //     color: Colors.grey
//                                               //         .withOpacity(0.2),
//                                               //   ),
//                                               //   child: Text(
//                                               //     "$lots",
//                                               //     style: TextStyle(
//                                               //       fontSize: screenWidth * 0.045,
//                                               //       color: zBlack,
//                                               //       fontWeight: FontWeight.bold,
//                                               //     ),
//                                               //     textAlign: TextAlign.center,
//                                               //   ),
//                                               // ),
//                                               Material(
//                                                 color: Colors.transparent,
//                                                 child: InkWell(
//                                                   onTap: () =>
//                                                       lotsNotifierLmt.value++,
//                                                   borderRadius:
//                                                       BorderRadius.circular(30),
//                                                   child: Container(
//                                                     padding:
//                                                         const EdgeInsets.all(8),
//                                                     decoration: BoxDecoration(
//                                                       shape: BoxShape.circle,
//                                                       color: Colors.grey
//                                                           .withOpacity(0.2),
//                                                     ),
//                                                     child: Icon(
//                                                       Icons.add,
//                                                       color: zBlack,
//                                                       size: screenWidth * 0.05,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // Divider(
//                                 //   indent: 3,
//                                 //   endIndent: 3,
//                                 //   height: screenHeight * 0.03,
//                                 //   color: Colors.white,
//                                 // ),
//                                 Container(
//                                   width: screenWidth * 0.9,
//                                   margin:
//                                       const EdgeInsets.symmetric(vertical: 8),
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(15),
//                                       color: kWhiteColor),
//                                   child: TextFormField(
//                                     controller: _usernameController,
//                                     style: TextStyle(
//                                       color: zBlack,
//                                       fontSize: screenWidth * 0.04,
//                                       fontWeight: FontWeight.w500,
//                                       letterSpacing: 0.5,
//                                     ),
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly
//                                     ],
//                                     decoration: InputDecoration(
//                                       labelText: "Price",
//                                       labelStyle: TextStyle(
//                                         color: Colors.grey[400],
//                                         fontSize: screenWidth * 0.04,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                       prefixIcon: Icon(
//                                         Icons.price_change_outlined,
//                                         color: zBlack,
//                                         size: screenWidth * 0.06,
//                                       ),
//                                       floatingLabelStyle: TextStyle(
//                                         color: const Color(0xFF00C853),
//                                         fontSize: screenWidth * 0.035,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                         horizontal: 20,
//                                         vertical: 16,
//                                       ),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(15),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                       enabledBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(15),
//                                         borderSide: BorderSide(
//                                           color: Colors.grey.withOpacity(0.2),
//                                           width: 1,
//                                         ),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(15),
//                                         borderSide: const BorderSide(
//                                           color: Color(0xFF00C853),
//                                           width: 2,
//                                         ),
//                                       ),
//                                       filled: true,
//                                       fillColor: kWhiteColor,
//                                     ),
//                                     keyboardType: TextInputType.number,
//                                     cursorColor: const Color(0xFF00C853),
//                                   ),
//                                 ),
//                                 SizedBox(height: screenHeight * 0.02),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     isSellClicked
//                                         ? const CircularProgressIndicator
//                                             .adaptive()
//                                         : Container(
//                                             width: screenWidth / 2.5,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                               gradient: LinearGradient(
//                                                 begin: Alignment.topLeft,
//                                                 end: Alignment.bottomRight,
//                                                 colors: [
//                                                   const Color(0xFFFF3B30)
//                                                       .withOpacity(0.8),
//                                                   const Color(0xFFFF3B30)
//                                                       .withOpacity(0.6),
//                                                 ],
//                                               ),
//                                               // boxShadow: [
//                                               //   BoxShadow(
//                                               //     color: const Color(0xFFFF3B30)
//                                               //         .withOpacity(0.3),
//                                               //     spreadRadius: 1,
//                                               //     blurRadius: 8,
//                                               //     offset: const Offset(0, 4),
//                                               //   ),
//                                               // ],
//                                               border: Border.all(
//                                                 color:
//                                                     Colors.red.withOpacity(0.3),
//                                                 width: 1,
//                                               ),
//                                             ),
//                                             child: Material(
//                                               color: Colors.transparent,
//                                               child: InkWell(
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                                 onTap: () {
//                                                   if (double.parse(
//                                                               _usernameController
//                                                                   .text) >
//                                                           double.parse(
//                                                               ohlc.salePrice) ||
//                                                       double.parse(
//                                                               _usernameController
//                                                                   .text) <
//                                                           double.parse(
//                                                               ohlc.buyPrice)) {
//                                                     saleStock(
//                                                       context: context,
//                                                       activity:
//                                                           'sale-stock-order',
//                                                       symbolKey:
//                                                           widget.symbolKey,
//                                                       categoryName: 'NFO',
//                                                       stockPrice:
//                                                           '${_usernameController.text} * ${lotsNotifierLmt.value}',
//                                                       stockQty: lotsNotifierLmt
//                                                           .value
//                                                           .toString(),
//                                                     );
//                                                   } else {
//                                                     waringToast(context,
//                                                         'You Cant Sale Stock Your Price is not in Range!');
//                                                   }
//                                                   // if (isMarketOpen) {

//                                                   // } else {
//                                                   //   showDialog(
//                                                   //     context: context,
//                                                   //     builder: (context) =>
//                                                   //         const WarningAlertBox(
//                                                   //       title: 'Warning',
//                                                   //       message:
//                                                   //           'Market Closed You Cant Sale Stocks!',
//                                                   //     ),
//                                                   //   );
//                                                   // }
//                                                 },
//                                                 child: Container(
//                                                   padding: EdgeInsets.symmetric(
//                                                       vertical:
//                                                           screenHeight * 0.02),
//                                                   child: Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           const Icon(Icons.sell,
//                                                               color:
//                                                                   Colors.white,
//                                                               size: 20),
//                                                           const SizedBox(
//                                                               width: 8),
//                                                           Text(
//                                                             "SELL",
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize:
//                                                                   screenWidth *
//                                                                       0.04,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                               fontFamily:
//                                                                   'JetBrainsMono',
//                                                               letterSpacing:
//                                                                   0.5,
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       const SizedBox(height: 4),
//                                                       Text(
//                                                         (() {
//                                                           final double price =
//                                                               double.tryParse(
//                                                                       _usernameController
//                                                                           .text) ??
//                                                                   0.0;
//                                                           // final int lots =
//                                                           //     lotsNotifierLmt
//                                                           //         .value;
//                                                           // final double total =
//                                                           //     price * lots;
//                                                           return price
//                                                               .toStringAsFixed(
//                                                                   2);
//                                                         })(),
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize:
//                                                               screenWidth *
//                                                                   0.045,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontFamily:
//                                                               'JetBrainsMono',
//                                                           letterSpacing: 0.5,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                     SizedBox(width: screenWidth * 0.03),
//                                     isBuyClicked
//                                         ? const CircularProgressIndicator
//                                             .adaptive()
//                                         : Container(
//                                             width: screenWidth / 2.5,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                               gradient: LinearGradient(
//                                                 begin: Alignment.topLeft,
//                                                 end: Alignment.bottomRight,
//                                                 colors: [
//                                                   const Color(0xFF34C759)
//                                                       .withOpacity(0.8),
//                                                   const Color(0xFF34C759)
//                                                       .withOpacity(0.6),
//                                                 ],
//                                               ),
//                                               // boxShadow: [
//                                               //   BoxShadow(
//                                               //     color: const Color(0xFF34C759)
//                                               //         .withOpacity(0.3),
//                                               //     spreadRadius: 1,
//                                               //     blurRadius: 8,
//                                               //     offset: const Offset(0, 4),
//                                               //   ),
//                                               // ],
//                                               border: Border.all(
//                                                 color: Colors.green
//                                                     .withOpacity(0.3),
//                                                 width: 1,
//                                               ),
//                                             ),
//                                             child: Material(
//                                               color: Colors.transparent,
//                                               child: InkWell(
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                                 onTap: () {
//                                                   if (double.parse(
//                                                               _usernameController
//                                                                   .text) >
//                                                           double.parse(ohlc
//                                                               .salePrice
//                                                               .toString()) ||
//                                                       double.parse(
//                                                               _usernameController
//                                                                   .text) <
//                                                           double.parse(ohlc
//                                                               .buyPrice
//                                                               .toString())) {
//                                                     buyStock(
//                                                       context: context,
//                                                       activity:
//                                                           'buy-stock-order',
//                                                       symbolKey:
//                                                           widget.symbolKey,
//                                                       categoryName: 'NFO',
//                                                       stockPrice:
//                                                           '${_usernameController.text} * ${lotsNotifierLmt.value}',
//                                                       stockQty: lotsNotifierLmt
//                                                           .value
//                                                           .toString(),
//                                                     );
//                                                   } else {
//                                                     waringToast(context,
//                                                         'You Cant Buy Stock Your Price is not in Range!');
//                                                   }
//                                                   // if (isMarketOpen) {

//                                                   // } else {
//                                                   //   showDialog(
//                                                   //     context: context,
//                                                   //     builder: (context) =>
//                                                   //         const WarningAlertBox(
//                                                   //       title: 'Warning',
//                                                   //       message:
//                                                   //           'Market Closed You Cant Buy Stocks!',
//                                                   //     ),
//                                                   //   );
//                                                   // }
//                                                 },
//                                                 child: Container(
//                                                   padding: EdgeInsets.symmetric(
//                                                       vertical:
//                                                           screenHeight * 0.02),
//                                                   child: Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           const Icon(
//                                                               Icons
//                                                                   .shopping_cart,
//                                                               color:
//                                                                   Colors.white,
//                                                               size: 20),
//                                                           const SizedBox(
//                                                               width: 8),
//                                                           Text(
//                                                             "BUY",
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize:
//                                                                   screenWidth *
//                                                                       0.04,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                               fontFamily:
//                                                                   'JetBrainsMono',
//                                                               letterSpacing:
//                                                                   0.5,
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       const SizedBox(height: 4),
//                                                       Text(
//                                                         (() {
//                                                           final double price =
//                                                               double.tryParse(
//                                                                       _usernameController
//                                                                           .text) ??
//                                                                   0.0;
//                                                           // final int lots =
//                                                           //     lotsNotifierLmt
//                                                           //         .value;
//                                                           // final double total =
//                                                           //     price * lots;
//                                                           return price
//                                                               .toStringAsFixed(
//                                                                   2);
//                                                         })(),
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize:
//                                                               screenWidth *
//                                                                   0.045,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontFamily:
//                                                               'JetBrainsMono',
//                                                           letterSpacing: 0.5,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                   ],
//                                 ),
//                                 SizedBox(height: screenHeight * 0.03),
//                                 Container(
//                                   margin:
//                                       EdgeInsets.only(top: 10.w, bottom: 10.w),
//                                   // padding: EdgeInsets.all(10.r),
//                                   // width: double.infinity,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20.r),
//                                     color: Colors.white,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         blurRadius: 10,
//                                         offset: const Offset(0, 5),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Container(
//                                               height: 60,
//                                               margin:
//                                                   EdgeInsets.only(right: 4.w),
//                                               width: screenWidth * 0.25,
//                                               decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   color: Colors.white.blink(
//                                                       baseValue: ohlc.lastPrice,
//                                                       compValue:
//                                                           ohlc.salePrice)),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     'Bid',
//                                                     style: TextStyle(
//                                                       color: zBlack,
//                                                       fontSize:
//                                                           screenWidth * 0.03,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 4.h),
//                                                   Text(
//                                                     ohlc.salePrice.toString(),
//                                                     style: TextStyle(
//                                                       color: zBlack,
//                                                       fontSize:
//                                                           screenWidth * 0.035,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontFamily:
//                                                           'JetBrainsMono',
//                                                       letterSpacing: 0.5,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             // _buildInfoBox(
//                                             //     "Bid\n${ohlc.lastPrice}",
//                                             //     screenWidth,
//                                             //     screenHeight),

//                                             Container(
//                                               height: 60,
//                                               // margin: EdgeInsets.only(right: 4.w),
//                                               width: screenWidth * 0.25,
//                                               decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   color: Colors.white.blink(
//                                                       baseValue: ohlc.lastPrice,
//                                                       compValue:
//                                                           ohlc.buyPrice)),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     'Ask',
//                                                     style: TextStyle(
//                                                       color: zBlack,
//                                                       fontSize:
//                                                           screenWidth * 0.03,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 4.h),
//                                                   Text(
//                                                     ohlc.buyPrice.toString(),
//                                                     style: TextStyle(
//                                                       color: zBlack,
//                                                       fontSize:
//                                                           screenWidth * 0.035,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontFamily:
//                                                           'JetBrainsMono',
//                                                       letterSpacing: 0.5,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),

//                                             // _buildInfoBox(
//                                             //     "Bid\n${ohlc.lastPrice}",
//                                             //     screenWidth,
//                                             //     screenHeight),
//                                             // _buildInfoBox(
//                                             //     "Ask\n${ohlc.lastPrice}",
//                                             //     screenWidth,
//                                             //     screenHeight),
//                                             _buildInfoBox(
//                                                 "Last\n${ohlc.lastPrice}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             _buildInfoBox("Open\n${ohlc.open}",
//                                                 screenWidth, screenHeight),
//                                             _buildInfoBox(
//                                                 "Close\n${ohlc.close}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             _buildInfoBox(
//                                                 "Atp\n${record.averageTradePrice}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             _buildInfoBox("High\n${ohlc.high}",
//                                                 screenWidth, screenHeight),
//                                             _buildInfoBox("Low\n${ohlc.low}",
//                                                 screenWidth, screenHeight),
//                                             _buildInfoBox(
//                                                 "Volume\n${ohlc.volume}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             _buildInfoBox(
//                                                 "Upper ckt\n${ohlc.open}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             _buildInfoBox(
//                                                 "Lower ckt\n${ohlc.close}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             Container(
//                                               height: 60,
//                                               width: screenWidth * 0.28,
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                                 color: Colors.white
//                                                     .valueColor(record.change),
//                                               ),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     'Change',
//                                                     style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize:
//                                                           screenWidth * 0.03,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 4.h),
//                                                   Text(
//                                                     record.change.toString(),
//                                                     style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize:
//                                                           screenWidth * 0.035,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontFamily:
//                                                           'JetBrainsMono',
//                                                       letterSpacing: 0.5,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             // _buildInfoBox(
//                                             //     "Change\n${record.change}",
//                                             //     screenWidth,
//                                             //     screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             _buildInfoBox(
//                                                 "Last Buy\n${record.lastBuy.price}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             _buildInfoBox(
//                                                 "Last Sell\n${record.lastSell.price}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                             _buildInfoBox(
//                                                 "LotSize\n${record.lotSize}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: screenHeight * 0.03),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             // _buildInfoBox("Buyer\nN/A",
//                                             //     screenWidth, screenHeight),
//                                             // _buildInfoBox("Seller\nN/A",
//                                             //     screenWidth, screenHeight),
//                                             _buildInfoBox(
//                                                 "Open Interest\n${record.openInterest}",
//                                                 screenWidth,
//                                                 screenHeight),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         )
//                   : Center(
//                       child: Text(
//                         snapshot.data!.message.toString(),
//                         style: const TextStyle(
//                           color: zBlack,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoBox(String text, double screenWidth, double screenHeight) {
//     final List<String> parts = text.split('\n');
//     final String label = parts[0];
//     final String value = parts.length > 1 ? parts[1] : '';

//     return Container(
//       height: screenHeight * 0.08,
//       width: screenWidth * 0.28,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             label,
//           ).textStyleH2(),
//           SizedBox(height: 4.h),
//           Text(
//             value,
//           ).textStyleH1(),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(
//       String label, String value, double screenWidth, double screenHeight) {
//     return Container(
//       height: 40,
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8), color: Colors.white),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }
