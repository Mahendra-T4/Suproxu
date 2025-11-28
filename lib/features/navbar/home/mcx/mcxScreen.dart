// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:async';
// import 'dart:developer' as developer;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/extensions/color_blinker.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/core/service/repositorie/global_respo.dart';
// import 'package:trading_app/features/navbar/home/mcx/McxSymbolsScreen.dart';

// import 'package:trading_app/features/navbar/home/model/stock_list_entity.dart';
// import 'package:trading_app/features/navbar/home/providers/mcx_provider.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';

// class Mcxscreen extends ConsumerStatefulWidget {
//   Mcxscreen({
//     Key? key,
//   }) : super(key: key);

//   static const String routeName = '/mcx-screen';

//   @override
//   ConsumerState<Mcxscreen> createState() => _McxscreenState();
// }

// class _McxscreenState extends ConsumerState<Mcxscreen>
//     with SingleTickerProviderStateMixin {
//   late Timer _dataTimer;
//   late TabController _tabController;
//   late StockListEntity stockListEntity;

//   TextEditingController searchController = TextEditingController();
//   bool isMarketOpen = true;
//   bool isSearch = false;

//   @override
//   void initState() {
//     _initializeTabs();
//     _tabController = TabController(
//         length: 5, vsync: this); // Adjust length dynamically if needed

//     _dataTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
//       // _fetchData();
//       _checkMarketStatus();
//     }); // Reduced frequency
//     // _fetchData(); // Initial fetch
//     _checkMarketStatus();
//     super.initState();
//   }

//   Future<void> _initializeTabs() async {
//     stockListEntity = await GlobalRepository.stocksMapper();
//     // Optionally update _tabController length based on stockListEntity if dynamic
//   }

//   void _checkMarketStatus() {
//     final now = DateTime.now();
//     final marketOpenTime = DateTime(now.year, now.month, now.day, 9, 15);
//     final marketCloseTime = DateTime(now.year, now.month, now.day, 23, 00);

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
//   void dispose() {
//     _dataTimer.cancel();

//     _tabController.dispose();

//     searchController.dispose();
//     super.dispose();
//   }

//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     return NumberFormat('#,##,##0.00').format(number);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mcxDataProvider = ref.watch(mcxProvider(searchController.text));
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: kWhiteColor,
//         // appBar: AppBar(
//         //   backgroundColor: kWhiteColor,
//         // title: const Text(
//         //   'Status',
//         //   style: TextStyle(
//         //       fontWeight: FontWeight.bold, fontSize: 16, color: zBlack),
//         // ),
//         // actions: [
//         //   Container(
//         //     margin: const EdgeInsets.only(right: 10),
//         //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//         //     decoration: BoxDecoration(
//         //       color: isMarketOpen
//         //           ? const Color(0xFF00C853)
//         //           : const Color(0xFFFF3D00),
//         //       borderRadius: BorderRadius.circular(4),
//         //     ),
//         //     child: Text(
//         //       isMarketOpen ? 'OPEN' : 'CLOSED',
//         //       style: const TextStyle(
//         //         color: Colors.white,
//         //         // fontSize: 12,
//         //         fontWeight: FontWeight.w500,
//         //       ),
//         //     ),
//         //   )
//         // ],
//         // ),
//         body: Column(
//           children: [
//             _buildSearchBar(),
//             const SizedBox(height: 10),
//             mcxDataProvider.when(
//               skipLoadingOnRefresh: true,
//               data: (data) => Expanded(
//                   child: data.status == 1
//                       ? ListView.builder(
//                           itemCount:
//                               data.status == 1 ? data.response!.length : 0,
//                           itemBuilder: (context, index) => GestureDetector(
//                             onTap: () {
//                               if (data.response![index].symbol != null) {
//                                 GoRouter.of(context).pushNamed(
//                                     Symbolscreen.routeName,
//                                     extra: SymbolScreenParams(
//                                         symbol: data.response![index].symbol
//                                             .toString(),
//                                         index: index,
//                                         symbolKey: data
//                                             .response![index].symbolKey
//                                             .toString()));
//                               }
//                             },
//                             child: Container(
//                               margin: const EdgeInsets.only(left: 10, right: 5),
//                               decoration: BoxDecoration(
//                                 color: kWhiteColor,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               // padding: const EdgeInsets.symmetric(horizontal: 12),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       SizedBox(
//                                         width:
//                                             MediaQuery.sizeOf(context).width /
//                                                 4,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               data.response![index]
//                                                       .symbolName ??
//                                                   '',
//                                             ).textStyleH1(),
//                                             // SizedBox(height: 4.h),
//                                           ],
//                                         ),
//                                       ),
//                                       Column(
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               BlinkingPriceText(
//                                                 assetId: data
//                                                     .response![index].symbolKey,
//                                                 text:
//                                                     "₹${_formatNumber(data.response![index].ohlc!.salePrice)}",
//                                                 compareValue: data
//                                                     .response![index]
//                                                     .ohlc!
//                                                     .lastPrice,
//                                                 currentValue: data
//                                                     .response![index]
//                                                     .ohlc!
//                                                     .salePrice,
//                                               ),
//                                               // Container(
//                                               //   padding: const EdgeInsets.all(2),
//                                               //   decoration: BoxDecoration(
//                                               //     borderRadius:
//                                               //         BorderRadius.circular(4),
//                                               //     color: Colors.white.blink(
//                                               //       baseValue: data.response![index]
//                                               //           .ohlc!.lastPrice,
//                                               //       compValue: data.response![index]
//                                               //           .ohlc!.salePrice,
//                                               //     ),
//                                               //   ),
//                                               //   child: Text(
//                                               //       "₹${_formatNumber(data.response![index].ohlc!.salePrice)}",
//                                               //       style: const TextStyle(
//                                               //         color: zBlack,
//                                               //         fontSize: 15,
//                                               //         fontFamily: 'JetBrainsMono',
//                                               //         fontWeight: FontWeight.w800,
//                                               //       )),
//                                               // ),
//                                               SizedBox(width: 10.w),
//                                               BlinkingPriceText(
//                                                 assetId: data.response![index]
//                                                     .symbolName,
//                                                 text:
//                                                     "₹${_formatNumber(data.response![index].ohlc!.buyPrice)}",
//                                                 compareValue: data
//                                                     .response![index]
//                                                     .ohlc!
//                                                     .lastPrice,
//                                                 currentValue: data
//                                                     .response![index]
//                                                     .ohlc!
//                                                     .buyPrice,
//                                               ),
//                                               // Container(
//                                               //   padding: const EdgeInsets.all(2),
//                                               //   decoration: BoxDecoration(
//                                               //     borderRadius:
//                                               //         BorderRadius.circular(4),
//                                               //     color: Colors.white.blink(
//                                               //         baseValue: data
//                                               //             .response![index]
//                                               //             .ohlc!
//                                               //             .lastPrice,
//                                               //         compValue: data
//                                               //             .response![index]
//                                               //             .ohlc!
//                                               //             .buyPrice),
//                                               //   ),
//                                               //   child: Text(
//                                               //       "₹${_formatNumber(data.response![index].ohlc!.buyPrice)}",
//                                               //       style: const TextStyle(
//                                               //         color: zBlack,
//                                               //         fontSize: 15,
//                                               //         fontFamily: 'JetBrainsMono',
//                                               //         fontWeight: FontWeight.w800,
//                                               //       )),
//                                               // ),
//                                               const SizedBox(
//                                                 width: 5,
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         spacing: 5,
//                                         children: [
//                                           Text(
//                                             data.response![index].expiryDate ??
//                                                 '',
//                                           ).textStyleH2(),
//                                         ],
//                                       ),
//                                       GestureDetector(
//                                         onTap: () async {
//                                           // Call the API and wait for response
//                                           final success =
//                                               await WishlistRepository
//                                                   .addToWishlist(
//                                             category: 'MCX',
//                                             symbolKey: data
//                                                 .response![index].symbolKey
//                                                 .toString(),
//                                             context: context,
//                                           );

//                                           // Only update state if API call was successful
//                                           if (success && mounted) {
//                                             setState(() {
//                                               data.response![index].watchlist =
//                                                   data.response![index]
//                                                               .watchlist ==
//                                                           1
//                                                       ? 0
//                                                       : 1;
//                                             });
//                                           }
//                                         },
//                                         child: data.response![index]
//                                                     .watchlist ==
//                                                 1
//                                             ? Image.asset(
//                                                 Assets
//                                                     .assetsImagesSupertradeRomoveWishlist,
//                                                 scale: 19,
//                                                 color: Colors.deepPurpleAccent)
//                                             : Image.asset(
//                                                 Assets
//                                                     .assetsImagesSuperTradeAddWishlist,
//                                                 scale: 19,
//                                                 color: Colors.grey[800]),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 6,
//                                   ),
//                                   // SizedBox(
//                                   //     height:
//                                   //         Responsive.screenHeight(context) * 0.02),
//                                   Row(
//                                     // spacing:
//                                     //     MediaQuery.sizeOf(context).width * .08,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Text("Chg: ",
//                                               style: TextStyle(
//                                                   color: data.response![index]
//                                                           .change
//                                                           .toString()
//                                                           .contains('-')
//                                                       ? Colors.red
//                                                       : Colors.green,
//                                                   fontSize: 11.5,
//                                                   fontWeight: FontWeight.bold)),
//                                           Text(
//                                               _formatNumber(
//                                                   data.response![index].change),
//                                               style: TextStyle(
//                                                   color: data.response![index]
//                                                           .change
//                                                           .toString()
//                                                           .contains('-')
//                                                       ? Colors.red
//                                                       : Colors.green,
//                                                   fontSize: 11.5,
//                                                   fontWeight: FontWeight.bold)),
//                                         ],
//                                       ),
//                                       Row(
//                                         children: [
//                                           const Text(
//                                             "LTP: ",
//                                           ).textStyleH3(),
//                                           Text(
//                                               _formatNumber(data
//                                                   .response![index]
//                                                   .ohlc!
//                                                   .lastPrice),
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 11.5,
//                                                   fontWeight: FontWeight.bold)),
//                                         ],
//                                       ),
//                                       Row(
//                                         children: [
//                                           const Text(
//                                             "H: ",
//                                           ).textStyleH3(),
//                                           Text(
//                                               _formatNumber(data
//                                                   .response![index].ohlc!.high),
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 11.5,
//                                                   fontWeight: FontWeight.bold)),
//                                         ],
//                                       ),
//                                       Row(
//                                         children: [
//                                           const Text("L: ",
//                                               style: TextStyle(
//                                                   color: zBlack,
//                                                   fontSize: 11.5,
//                                                   fontWeight: FontWeight.bold)),
//                                           Text(
//                                             _formatNumber(data
//                                                 .response![index].ohlc!.low),
//                                           ).textStyleH3(),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   Divider(
//                                     thickness: 1.5,
//                                     color: Colors.grey.shade800,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         )
//                       : Expanded(
//                           child: Center(
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 20),
//                               child: Text(
//                                 data.message.toString(),
//                                 style: const TextStyle(
//                                   color: zBlack,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                         )),
//               error: (error, stackTrace) {
//                 developer.log('Error fetching MCX data: $error',
//                     name: 'Mcxscreen', error: error, stackTrace: stackTrace);
//                 return const SizedBox.shrink();
//               },
//               loading: () => Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.sizeOf(context).height / 3,
//                   ),
//                   const Center(child: CircularProgressIndicator.adaptive()),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//     // : const NoInternetConnection();
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C2C2E).withOpacity(.9),
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: Row(
//         children: [
//           SizedBox(
//             // height: 45,
//             // width: 45,
//             child: IconButton(
//                 onPressed: () {
//                   context.pop();
//                 },
//                 icon: const Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.white,
//                 )),
//           ),
//           Expanded(
//             child: TextField(
//               controller: searchController,
//               // focusNode: _searchFocusNode,
//               style: TextStyle(color: Colors.white, fontSize: 16.sp),
//               onChanged: (query) {},
//               decoration: InputDecoration(
//                 hintText: 'Search by symbol or price...',
//                 hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
//                 prefixIcon:
//                     Icon(Icons.search, color: Colors.grey[400], size: 20.r),
//                 border: InputBorder.none,
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color contColor(dynamic open, dynamic last) {
//     final value = (open ?? 0) - (last ?? 0);
//     return value >= 0 ? Colors.green : Colors.red;
//   }
// }
