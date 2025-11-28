// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/constants/extensions/double_etx.dart';
// import 'package:trading_app/core/service/connectivity/connectivity_service.dart';
// import 'package:trading_app/core/service/page/not_connected.dart';
// import 'package:trading_app/features/navbar/home/model/get_stock_record_entity.dart';
// import 'package:trading_app/features/navbar/home/repository/buy_sale_repo.dart';
// import 'package:trading_app/features/navbar/home/repository/trade_repository.dart';
// import 'package:trading_app/features/navbar/profile/notification/notificationScreen.dart';

// class NseSymbols extends StatefulWidget {
//   final String symbol;
//   final int index;
//   final String symbolKey;

//   const NseSymbols(
//       {super.key,
//       required this.symbol,
//       required this.index,
//       required this.symbolKey});

//   @override
//   State<NseSymbols> createState() => _NseSymbolsState();
// }

// class _NseSymbolsState extends State<NseSymbols> {
//   final ValueNotifier<int> lotsNotifierMrk = ValueNotifier<int>(1);
//   final ValueNotifier<int> lotsNotierLmt = ValueNotifier<int>(1);
//   final TextEditingController _usernameController = TextEditingController();
//   final StreamController<GetStockRecordEntity> _streamController =
//       StreamController<GetStockRecordEntity>.broadcast();
//   int lots = 1;
//   int selecteddTab = 0;
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _fetchLiveData();
//     _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
//       _fetchLiveData();
//     });
//     log('NSE Symbol Key =>> ${widget.symbolKey}');
//   }

//   Future<void> _fetchLiveData() async {
//     try {
//       GetStockRecordEntity data =
//           await TradeRepository.getStockRecords(widget.symbolKey, 'NSE');
//       if (!_streamController.isClosed && mounted) {
//         _streamController.add(data);
//       }
//     } catch (e) {
//       print("Error fetching live data: $e");
//       if (!_streamController.isClosed && mounted) {
//         _streamController.addError(e);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
   
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//             backgroundColor: Colors.black,
//             appBar: AppBar(
//               backgroundColor: Colors.black,
//               leading: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//               ),
//               actions: [
//                 IconButton(
//                   icon: Image.asset(
//                     Assets.assetsImagesSupertradeNotification,
//                     scale: 20,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, NotificationScreen.routeName);
//                   },
//                 ),
//               ],
//               title: Text(
//                 widget.symbol,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   fontSize: screenWidth * 0.05,
//                 ),
//               ),
//             ),
//             body: SafeArea(
//               child: Column(
//                 children: [
//                   SizedBox(height: screenHeight * 0.02),
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       color: const Color(0xFF1C1C1E),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           spreadRadius: 1,
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => setState(() => selecteddTab = 0),
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 alignment: Alignment.center,
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: screenHeight * 0.018),
//                                 decoration: BoxDecoration(
//                                   color: selecteddTab == 0
//                                       ? const Color(0xFF2C2C2E)
//                                       : Colors.transparent,
//                                   borderRadius: BorderRadius.circular(12),
//                                   gradient: selecteddTab == 0
//                                       ? LinearGradient(
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                           colors: [
//                                             const Color(0xFF00C853),
//                                             const Color(0xFF00C853).withOpacity(0.8),
//                                           ],
//                                         )
//                                       : null,
//                                   boxShadow: selecteddTab == 0
//                                       ? [
//                                           BoxShadow(
//                                             color: const Color(0xFF00C853)
//                                                 .withOpacity(0.3),
//                                             spreadRadius: 1,
//                                             blurRadius: 8,
//                                             offset: const Offset(0, 2),
//                                           ),
//                                         ]
//                                       : null,
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.show_chart,
//                                       color: selecteddTab == 0
//                                           ? Colors.white
//                                           : Colors.grey,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       "Market",
//                                       style: TextStyle(
//                                         color: selecteddTab == 0
//                                             ? Colors.white
//                                             : Colors.grey,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16,
//                                         letterSpacing: 0.5,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => setState(() => selecteddTab = 1),
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 alignment: Alignment.center,
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: screenHeight * 0.018),
//                                 decoration: BoxDecoration(
//                                   color: selecteddTab == 1
//                                       ? const Color(0xFF2C2C2E)
//                                       : Colors.transparent,
//                                   borderRadius: BorderRadius.circular(12),
//                                   gradient: selecteddTab == 1
//                                       ? LinearGradient(
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                           colors: [
//                                             const Color(0xFF00C853),
//                                             const Color(0xFF00C853).withOpacity(0.8),
//                                           ],
//                                         )
//                                       : null,
//                                   boxShadow: selecteddTab == 1
//                                       ? [
//                                           BoxShadow(
//                                             color: const Color(0xFF00C853)
//                                                 .withOpacity(0.3),
//                                             spreadRadius: 1,
//                                             blurRadius: 8,
//                                             offset: const Offset(0, 2),
//                                           ),
//                                         ]
//                                       : null,
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.receipt_long,
//                                       color: selecteddTab == 1
//                                           ? Colors.white
//                                           : Colors.grey,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       "Order",
//                                       style: TextStyle(
//                                         color: selecteddTab == 1
//                                             ? Colors.white
//                                             : Colors.grey,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16,
//                                         letterSpacing: 0.5,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: StreamBuilder<GetStockRecordEntity>(
//                       stream: _streamController.stream,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//                         if (snapshot.hasError) {
//                           return Center(
//                               child: Text("Error: ${snapshot.error}",
//                                   style: const TextStyle(color: Colors.white)));
//                         }
//                         if (!snapshot.hasData ||
//                             snapshot.data?.response == null) {
//                           return const Center(
//                               child: Text("No Data Available",
//                                   style: TextStyle(color: Colors.white)));
//                         }

//                         final record = snapshot.data!.response!.first;
//                         OhlcGetRecord? ohlc = record.ohlc;

//                         return selecteddTab == 0
//                             ? marketCrudeoil(context, ohlc!, record,
//                                 screenWidth, screenHeight)
//                             : limitCrudeoil(context, ohlc!, record, screenWidth,
//                                 screenHeight);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//   }

//   Widget marketCrudeoil(BuildContext context, OhlcGetRecord ohlc,
//       ResponseGetRecord response, double screenWidth, double screenHeight) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // SizedBox(height: screenHeight * 0.02),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 gradient: const LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF2C2C2E),
//                     Color(0xFF1C1C1E),
//                   ],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     spreadRadius: 1,
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//                 border: Border.all(
//                   color: Colors.grey.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Lots",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: screenWidth * 0.045,
//                       color: Colors.white,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   ValueListenableBuilder<int>(
//                     valueListenable: lotsNotifierMrk,
//                     builder: (context, lots, child) {
//                       return Row(
//                         children: [
//                           Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () =>
//                                   lots > 1 ? lotsNotifierMrk.value-- : null,
//                               borderRadius: BorderRadius.circular(30),
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey.withOpacity(0.2),
//                                 ),
//                                 child: Icon(
//                                   Icons.remove,
//                                   color: Colors.white,
//                                   size: screenWidth * 0.05,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: screenWidth * 0.15,
//                             margin: const EdgeInsets.symmetric(horizontal: 16),
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 8, horizontal: 12),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: Colors.white.withOpacity(0.1),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.3),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Text(
//                               "$lots",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.045,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () => lotsNotifierMrk.value++,
//                               borderRadius: BorderRadius.circular(30),
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey.withOpacity(0.2),
//                                 ),
//                                 child: Icon(
//                                   Icons.add,
//                                   color: Colors.white,
//                                   size: screenWidth * 0.05,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.03),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           const Color(0xFFFF3B30).withOpacity(0.8),
//                           const Color(0xFFFF3B30).withOpacity(0.6),
//                         ],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFFFF3B30).withOpacity(0.3),
//                           spreadRadius: 1,
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(15),
//                         onTap: () {
//                           StockBuyAndSaleRepository.saleStock(
//                             context: context,
//                             symbolKey: widget.symbolKey,
//                             categoryName: 'NSE',
//                             stockPrice:
//                                 '${ohlc.lastPrice! * lotsNotifierMrk.value}',
//                             stockQty: lotsNotifierMrk.value.toString(),
//                           );
//                         },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                               vertical: screenHeight * 0.02),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Icon(Icons.sell,
//                                       color: Colors.white, size: 20),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     "SELL",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: screenWidth * 0.04,
//                                       fontWeight: FontWeight.w600,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "₹${formatDoubleNumber(ohlc.lastPrice! * lotsNotifierMrk.value)}",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: screenWidth * 0.045,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.03),
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           const Color(0xFF34C759).withOpacity(0.8),
//                           const Color(0xFF34C759).withOpacity(0.6),
//                         ],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF34C759).withOpacity(0.3),
//                           spreadRadius: 1,
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(15),
//                         onTap: () {
//                           StockBuyAndSaleRepository.buyStock(
//                             context: context,
//                             symbolKey: widget.symbolKey,
//                             categoryName: 'NSE',
//                             stockPrice:
//                                 '${ohlc.lastPrice! * lotsNotifierMrk.value}',
//                             stockQty: lotsNotifierMrk.value.toString(),
//                           );
//                         },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                               vertical: screenHeight * 0.02),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Icon(Icons.shopping_cart,
//                                       color: Colors.white, size: 20),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     "BUY",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: screenWidth * 0.04,
//                                       fontWeight: FontWeight.w600,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "₹${formatDoubleNumber(ohlc.lastPrice! * lotsNotifierMrk.value)}",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: screenWidth * 0.045,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.03),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox(
//                     "Bid\n${ohlc.lastPrice}", screenWidth, screenHeight),
//                 _buildInfoBox(
//                     "Ask\n${ohlc.lastPrice}", screenWidth, screenHeight),
//                 _buildInfoBox(
//                     "Last\n${ohlc.lastPrice}", screenWidth, screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("Open\n${ohlc.open}", screenWidth, screenHeight),
//                 _buildInfoBox(
//                     "Close\n${ohlc.close}", screenWidth, screenHeight),
//                 _buildInfoBox("Atp\n${response.averageTradePrice}", screenWidth,
//                     screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("High\n${ohlc.high}", screenWidth, screenHeight),
//                 _buildInfoBox("Low\n${ohlc.low}", screenWidth, screenHeight),
//                 _buildInfoBox(
//                     "Volume\n${ohlc.volume}", screenWidth, screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("Upper ckt\n${response.upperCKT}", screenWidth,
//                     screenHeight),
//                 _buildInfoBox("Lower ckt\n${response.lowerCKT}", screenWidth,
//                     screenHeight),
//                 _buildInfoBox(
//                     "Change\n${response.change}", screenWidth, screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("Buyer\nN/A", screenWidth, screenHeight),
//                 _buildInfoBox("Seller\nN/A", screenWidth, screenHeight),
//                 _buildInfoBox("Open Interest\n${response.openInterest}",
//                     screenWidth, screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("Last Buy\n ${response.lastBuy!.price}",
//                     screenWidth, screenHeight),
//                 _buildInfoBox("Last Sell\n ${response.lastSell!.price}",
//                     screenWidth, screenHeight),
//                 _buildInfoBox("Lot Size\n ${response.lotSize}", screenWidth,
//                     screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.03),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget limitCrudeoil(BuildContext context, OhlcGetRecord ohlc,
//       ResponseGetRecord response, double screenWidth, double screenHeight) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // SizedBox(height: screenHeight * 0.02),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 gradient: const LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF2C2C2E),
//                     Color(0xFF1C1C1E),
//                   ],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     spreadRadius: 1,
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//                 border: Border.all(
//                   color: Colors.grey.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Lots",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: screenWidth * 0.045,
//                       color: Colors.white,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   ValueListenableBuilder<int>(
//                     valueListenable: lotsNotierLmt,
//                     builder: (context, lots, child) {
//                       return Row(
//                         children: [
//                           Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () =>
//                                   lots > 1 ? lotsNotierLmt.value-- : null,
//                               borderRadius: BorderRadius.circular(30),
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey.withOpacity(0.2),
//                                 ),
//                                 child: Icon(
//                                   Icons.remove,
//                                   color: Colors.white,
//                                   size: screenWidth * 0.05,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: screenWidth * 0.15,
//                             margin: const EdgeInsets.symmetric(horizontal: 16),
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 8, horizontal: 12),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: Colors.white.withOpacity(0.1),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.3),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Text(
//                               "$lots",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.045,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () => lotsNotierLmt.value++,
//                               borderRadius: BorderRadius.circular(30),
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey.withOpacity(0.2),
//                                 ),
//                                 child: Icon(
//                                   Icons.add,
//                                   color: Colors.white,
//                                   size: screenWidth * 0.05,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             // Divider(
//             //   height: screenHeight * 0.04,
//             //   color: Colors.white,
//             //   thickness: 1,
//             // ),
//             Container(
//               width: screenWidth * 0.9,
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 gradient: const LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF2C2C2E),
//                     Color(0xFF1C1C1E),
//                   ],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     spreadRadius: 1,
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//                 border: Border.all(
//                   color: Colors.grey.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: TextFormField(
//                 controller: _usernameController,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: screenWidth * 0.04,
//                   fontWeight: FontWeight.w500,
//                   letterSpacing: 0.5,
//                 ),
//                 decoration: InputDecoration(
//                   labelText: "Price",
//                   labelStyle: TextStyle(
//                     color: Colors.grey[400],
//                     fontSize: screenWidth * 0.04,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   prefixIcon: Icon(
//                     Icons.price_change_outlined,
//                     color: Colors.grey[400],
//                     size: screenWidth * 0.06,
//                   ),
//                   floatingLabelStyle: TextStyle(
//                     color: const Color(0xFF00C853),
//                     fontSize: screenWidth * 0.035,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 16,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     borderSide: BorderSide.none,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     borderSide: BorderSide(
//                       color: Colors.grey.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     borderSide: const BorderSide(
//                       color: Color(0xFF00C853),
//                       width: 2,
//                     ),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey.withOpacity(0.1),
//                 ),
//                 keyboardType: TextInputType.number,
//                 cursorColor: const Color(0xFF00C853),
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.03),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           const Color(0xFFFF3B30).withOpacity(0.8),
//                           const Color(0xFFFF3B30).withOpacity(0.6),
//                         ],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFFFF3B30).withOpacity(0.3),
//                           spreadRadius: 1,
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(15),
//                         onTap: () {
//                           StockBuyAndSaleRepository.saleStock(
//                             context: context,
//                             symbolKey: widget.symbolKey,
//                             categoryName: 'NSE',
//                             stockPrice:
//                                 '${ohlc.lastPrice! * lotsNotierLmt.value}',
//                             stockQty: lotsNotierLmt.value.toString(),
//                           );
//                         },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                               vertical: screenHeight * 0.02),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Icon(Icons.sell,
//                                       color: Colors.white, size: 20),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     "SELL",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: screenWidth * 0.04,
//                                       fontWeight: FontWeight.w600,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "₹${formatDoubleNumber(ohlc.lastPrice! * lotsNotierLmt.value)}",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: screenWidth * 0.045,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.03),
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           const Color(0xFF34C759).withOpacity(0.8),
//                           const Color(0xFF34C759).withOpacity(0.6),
//                         ],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF34C759).withOpacity(0.3),
//                           spreadRadius: 1,
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(15),
//                         onTap: () {
//                           StockBuyAndSaleRepository.buyStock(
//                             context: context,
//                             symbolKey: widget.symbolKey,
//                             categoryName: 'NSE',
//                             stockPrice:
//                                 '${ohlc.lastPrice! * lotsNotierLmt.value}',
//                             stockQty: lotsNotierLmt.value.toString(),
//                           );
//                         },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                               vertical: screenHeight * 0.02),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Icon(Icons.shopping_cart,
//                                       color: Colors.white, size: 20),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     "BUY",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: screenWidth * 0.04,
//                                       fontWeight: FontWeight.w600,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "₹${formatDoubleNumber(ohlc.lastPrice! * lotsNotierLmt.value)}",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: screenWidth * 0.045,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.03),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox(
//                     "Bid\n${ohlc.lastPrice}", screenWidth, screenHeight),
//                 _buildInfoBox(
//                     "Ask\n${ohlc.lastPrice}", screenWidth, screenHeight),
//                 _buildInfoBox(
//                     "Last\n${ohlc.lastPrice}", screenWidth, screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("Open\n${ohlc.open}", screenWidth, screenHeight),
//                 _buildInfoBox(
//                     "Close\n${ohlc.close}", screenWidth, screenHeight),
//                 _buildInfoBox("Atp\n${response.averageTradePrice}", screenWidth,
//                     screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("High\n${ohlc.high}", screenWidth, screenHeight),
//                 _buildInfoBox("Low\n${ohlc.low}", screenWidth, screenHeight),
//                 _buildInfoBox(
//                     "Volume\n${ohlc.volume}", screenWidth, screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("Upper ckt\n${response.upperCKT}", screenWidth,
//                     screenHeight),
//                 _buildInfoBox("Lower ckt\n${response.lowerCKT}", screenWidth,
//                     screenHeight),
//                 _buildInfoBox(
//                     "Change\n${response.change}", screenWidth, screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("Buyer\nN/A", screenWidth, screenHeight),
//                 _buildInfoBox("Seller\nN/A", screenWidth, screenHeight),
//                 _buildInfoBox("Open Interest\n${response.openInterest}",
//                     screenWidth, screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(
//               height: 15.h,
//             ),
//             Wrap(
//               spacing: screenWidth * 0.03,
//               runSpacing: screenHeight * 0.02,
//               children: [
//                 _buildInfoBox("Last Buy\n${response.lastBuy!.price}",
//                     screenWidth, screenHeight),
//                 _buildInfoBox("Last Sell\n${response.lastSell!.price}",
//                     screenWidth, screenHeight),
//                 _buildInfoBox(
//                     "Lot Size\n${response.lotSize}", screenWidth, screenHeight),
//                 // _buildInfoBox("PREV\n N/A", screenWidth, screenHeight),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.03)
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoBox(String text, double screenWidth, double screenHeight) {
//     final List<String> parts = text.split('\n');
//     final String label = parts[0];
//     final String value = parts.length > 1 ? parts[1] : '';

//     return Container(
//       height: screenHeight * 0.08,
//       width: screenWidth * 0.28,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF2C2C2E),
//             Color(0xFF1C1C1E),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(
//           color: Colors.grey.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.grey[400],
//               fontSize: screenWidth * 0.032,
//               fontWeight: FontWeight.w500,
//               letterSpacing: 0.5,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: screenWidth * 0.035,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFullWidthInfo(String label, String value, double screenWidth,
//       double screenHeight, bool isGrey) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: screenHeight * 0.01),
//       child: Container(
//         height: screenHeight * 0.05,
//         width: screenWidth * 0.9,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: isGrey ? Colors.grey[200] : Colors.transparent,
//         ),
//         alignment: Alignment.center,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left: screenWidth * 0.03),
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: isGrey ? Colors.black : Colors.white,
//                   fontSize: screenWidth * 0.04,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(right: screenWidth * 0.03),
//               child: Text(
//                 value,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: isGrey ? Colors.black : Colors.white,
//                   fontSize: screenWidth * 0.04,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
