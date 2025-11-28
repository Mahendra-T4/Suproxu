// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/extensions/color_blinker.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/core/service/Auth/user_validation.dart';
// import 'package:trading_app/features/navbar/home/mcx/McxSymbolsScreen.dart';
// import 'package:trading_app/features/navbar/home/nse-future/fnoSymbolScreen.dart' hide SymbolScreenParams;
// import 'package:trading_app/features/navbar/home/providers/nfo_ws_provider.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';

// class NFOWebSocketHandler extends ConsumerStatefulWidget {
//   const NFOWebSocketHandler({super.key});
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _NFOWebSocketHandlerState();
// }

// class _NFOWebSocketHandlerState extends ConsumerState<NFOWebSocketHandler> {
//   late Timer _dataTimer;

//   TextEditingController searchController = TextEditingController();
//   bool isMarketOpen = true;
//   bool isSearch = false;

//   // final FocusNode _searchFocusNode = FocusNode();

//   // Track loading state for wishlist button per item
//   Set<int> loadingWishlistIndexes = {};

//   @override
//   void initState() {
//     _dataTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
//       AuthService().checkUserValidation();
//     }); // Reduced frequency

//     AuthService().checkUserValidation();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _dataTimer.cancel(); // Cancel timer to prevent leaks

//     searchController.dispose();
//     super.dispose();
//   }

//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     return NumberFormat('#,##,##0.00').format(number);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final nfoWebSocket = ref.watch(nfoWSProvider(searchController.text));
//     if (nfoWebSocket.isLoading) {
//       return const Expanded(child: Center(child: CircularProgressIndicator()));
//     }
//     if (nfoWebSocket.errorMessage != null) {
//       return Expanded(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.red, size: 48),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Text(nfoWebSocket.errorMessage!),
//               ),
//               const SizedBox(height: 16),
//               // ElevatedButton(
//               //   onPressed: () {
//               //     ref
//               //         .read(nfoWSProvider(searchController.text).notifier)
//               //         .initializeNFOWebSocket();
//               //     // ref
//               //     //     .read(nfoWSProvider(searchController.text).notifier)
//               //     //     .reconnect();
//               //   },
//               //   child: const Text('Retry Connection'),
//               // ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (nfoWebSocket.nfoData.status != 1) {
//       return Expanded(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.info_outline, color: Colors.blue, size: 48),
//               const SizedBox(height: 16),
//               Text(nfoWebSocket.nfoData.message.toString()),
//               if (!nfoWebSocket.isConnected) ...[
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     ref
//                         .read(nfoWSProvider(searchController.text).notifier)
//                         .reconnect();
//                   },
//                   child: const Text('Reconnect'),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       );
//     }
//     final data = nfoWebSocket.nfoData;
//     return data.status == 1
//         ? Expanded(
//             child: ListView.builder(
//               itemCount: data.response?.length,
//               itemBuilder: (context, index) => GestureDetector(
//                 onTap: () {
//                   if (data.response![index].symbol != null) {
//                     GoRouter.of(context).pushNamed(
//                       NFOSymbols.routeName,
//                       extra: SymbolScreenParams(
//                         symbol: data.response![index].symbol!,
//                         index: index,
//                         symbolKey: data.response![index].symbolKey.toString(),
//                       ),
//                     );
//                   }
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(left: 10, right: 5),
//                   // padding: const EdgeInsets.symmetric(vertical: 8),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             flex: 3,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   data.response![index].symbolName
//                                       .toString()
//                                       .toUpperCase(),
//                                 ).textStyleH1(),
//                                 // SizedBox(height: 4.h),
//                               ],
//                             ),
//                           ),
//                           Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   BlinkingPriceText(
//                                     assetId: data.response![index].symbolKey
//                                         .toString(),
//                                     text:
//                                         "₹${_formatNumber(data.response![index].ohlcNSE!.salePrice)}",
//                                     compareValue: double.parse(
//                                       data.response![index].ohlcNSE!.lastPrice
//                                           .toString(),
//                                     ),
//                                     currentValue: double.parse(
//                                       data.response![index].ohlcNSE!.salePrice
//                                           .toString(),
//                                     ),
//                                   ),
//                                   // Container(
//                                   //   padding: const EdgeInsets.all(2),
//                                   //   decoration: BoxDecoration(
//                                   //     borderRadius:
//                                   //         BorderRadius.circular(4),
//                                   //     color: Colors.white.blink(
//                                   //         baseValue: data
//                                   //             .response![index]
//                                   //             .ohlcNSE!
//                                   //             .lastPrice,
//                                   //         compValue: data
//                                   //             .response![index]
//                                   //             .ohlcNSE!
//                                   //             .salePrice),
//                                   //   ),
//                                   //   child: Text(
//                                   //       "₹${_formatNumber(data.response![index].ohlcNSE!.salePrice)}",
//                                   //       style: const TextStyle(
//                                   //           color: zBlack,
//                                   //           fontSize: 15,
//                                   //           fontFamily:
//                                   //               'JetBrainsMono',
//                                   //           fontWeight:
//                                   //               FontWeight.w800)),
//                                   // ),
//                                   SizedBox(width: 20.w),
//                                   BlinkingPriceText(
//                                     assetId:
//                                         data.response![index].symbol.toString(),
//                                     text:
//                                         "₹${_formatNumber(data.response![index].ohlcNSE!.buyPrice)}",
//                                     compareValue: double.parse(
//                                       data.response![index].ohlcNSE!.lastPrice
//                                           .toString(),
//                                     ),
//                                     currentValue: double.parse(
//                                       data.response![index].ohlcNSE!.buyPrice
//                                           .toString(),
//                                     ),
//                                   ),
//                                   // Container(
//                                   //   padding: const EdgeInsets.all(2),
//                                   //   decoration: BoxDecoration(
//                                   //     borderRadius:
//                                   //         BorderRadius.circular(4),
//                                   //      color: Colors.white.blink(
//                                   //         baseValue: data
//                                   //             .response![index]
//                                   //             .ohlcNSE!
//                                   //             .lastPrice,
//                                   //         compValue: data
//                                   //             .response![index]
//                                   //             .ohlcNSE!
//                                   //             .salePrice),
//                                   //   ),
//                                   //   child: Text(
//                                   //       "₹${_formatNumber(data.response![index].ohlcNSE!.buyPrice)}",
//                                   //       style: const TextStyle(
//                                   //           color: zBlack,
//                                   //           fontSize: 15,
//                                   //           fontFamily:
//                                   //               'JetBrainsMono',
//                                   //           fontWeight:
//                                   //               FontWeight.w800)),
//                                   // ),
//                                   SizedBox(width: 5.w),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             spacing: 5,
//                             children: [
//                               Text(
//                                 data.response![index].expiryDate ?? '',
//                               ).textStyleH3(),
//                             ],
//                           ),
//                           InkWell(
//                             onTap: () async {
//                               // Call the API and wait for response
//                               final success =
//                                   await WishlistRepository.addToWishlist(
//                                 category: 'NFO',
//                                 symbolKey:
//                                     data.response![index].symbolKey.toString(),
//                                 context: context,
//                               );

//                               // Only update state if API call was successful
//                               if (success && mounted) {
//                                 setState(() {
//                                   data.response![index].watchlist =
//                                       data.response![index].watchlist == 1
//                                           ? 0
//                                           : 1;
//                                 });
//                               }
//                             },
//                             child: data.response![index].watchlist == 1
//                                 ? Image.asset(
//                                     Assets.assetsImagesSupertradeRomoveWishlist,
//                                     scale: 19,
//                                     color: Colors.deepPurpleAccent,
//                                   )
//                                 : Image.asset(
//                                     Assets.assetsImagesSuperTradeAddWishlist,
//                                     scale: 19,
//                                     color: Colors.black,
//                                   ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 5.h),
//                       Row(
//                         //  spacing:
//                         //   MediaQuery.sizeOf(context).width * .08,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 "Chg: ",
//                                 style: TextStyle(
//                                   color: data.response![index].change
//                                           .toString()
//                                           .contains('-')
//                                       ? Colors.red
//                                       : Colors.green,
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 _formatNumber(
//                                   data.response![index].change ?? 0.0,
//                                 ),
//                                 style: TextStyle(
//                                   color: data.response![index].change
//                                           .toString()
//                                           .contains('-')
//                                       ? Colors.red
//                                       : Colors.green,
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               const Text(
//                                 "LTP: ",
//                                 style: TextStyle(
//                                   color: zBlack,
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 _formatNumber(
//                                   data.response![index].ohlcNSE!.lastPrice,
//                                 ),
//                                 style: const TextStyle(
//                                   color: zBlack,
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               const Text(
//                                 "H: ",
//                                 style: TextStyle(
//                                   color: zBlack,
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 _formatNumber(
//                                   data.response![index].ohlcNSE!.high,
//                                 ),
//                                 style: const TextStyle(
//                                   color: zBlack,
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               const Text(
//                                 "L: ",
//                                 style: TextStyle(
//                                   color: zBlack,
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 _formatNumber(
//                                   data.response![index].ohlcNSE!.low,
//                                 ),
//                                 style: const TextStyle(
//                                   color: zBlack,
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Divider(thickness: 1.5, color: Colors.grey.shade800),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           )
//         : Expanded(child: Center(child: Text(data.message.toString())));
//   }
// }
