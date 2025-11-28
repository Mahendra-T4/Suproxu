// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/extensions/color_blinker.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/core/service/Auth/user_validation.dart';
// import 'package:trading_app/features/navbar/home/mcx/McxSymbolsScreen.dart';
// import 'package:trading_app/features/navbar/home/nse-future/fnoSymbolScreen.dart' hide SymbolScreenParams;
// import 'package:trading_app/features/navbar/wishlist/model/sorting_param.dart';
// import 'package:trading_app/features/navbar/wishlist/model/wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/provider/nfo_watchlist_ws_provider.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';

// class NFOWatchListMain extends ConsumerStatefulWidget {
//   const NFOWatchListMain({super.key});
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _NFOWatchListMainState();
// }

// class _NFOWatchListMainState extends ConsumerState<NFOWatchListMain> {
//   TextEditingController searchController = TextEditingController();
//   bool isMarketOpen = true; // This should be fetched from your backend
//   bool isSearch = false;

//   List<String> removingItems = [];
//   List<NFOWatchList> _localWatchlist = [];
//   List<NFOWatchList> _reorderedCopy = [];

//   late Timer _timer;
//   @override
//   void initState() {
//     super.initState();

//     AuthService().checkUserValidation();
//     _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       AuthService().checkUserValidation();
//     });
//   }

//   // Remove unused methods

//   @override
//   void dispose() {
//     _timer.cancel(); // Cancel the timer
//     searchController.dispose();
//     super.dispose();
//   }

//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     final formatter = NumberFormat('#,##,##0.00');
//     return formatter.format(number);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final nfoWatchlist = ref.watch(nfoWatchlistWSProvider);
//     if (nfoWatchlist.message != null) {
//       return Expanded(
//         child: Center(
//           child: Text('Error: ${nfoWatchlist.message}'),
//         ),
//       );
//     }

//     // Show no data message if data is null or status is not 1
//     if (nfoWatchlist.nfoWishlistEntity == null ||
//         nfoWatchlist.nfoWishlistEntity!.status != 1) {
//       return const Expanded(
//         child: Center(
//           child: Text('No data available'),
//         ),
//       );
//     }

//     // Show no items message if watchlist is empty
//     if (nfoWatchlist.nfoWishlistEntity!.nfoWatchlist == null ||
//         nfoWatchlist.nfoWishlistEntity!.nfoWatchlist!.isEmpty) {
//       return const Expanded(
//         child: Center(
//           child: Text('Your watchlist is empty'),
//         ),
//       );
//     }

//     final data = nfoWatchlist.nfoWishlistEntity!;

//     return Expanded(
//       child: ReorderableListView.builder(
//           itemCount: data.nfoWatchlist!.length,
//           onReorder: (oldIndex, newIndex) {
//             setState(() {
//               if (newIndex > oldIndex) newIndex--;
//               final item = _localWatchlist.removeAt(oldIndex);
//               _localWatchlist.insert(newIndex, item);
//               // Copy reordered data
//               _reorderedCopy = List.from(_localWatchlist);

//               log(
//                   name: 'Reordered List: ',
//                   _localWatchlist.first.symbolName.toString());
//               // _reorderedCopy.map((element) => element);
//             });

//             // Create comma-separated string for symbolKey
//             String symbolKeys =
//                 _localWatchlist.map((e) => e.symbolKey.toString()).join(',');

//             // Create array format string for symbolOrder
//             String orderNumbers =
//                 List.generate(_localWatchlist.length, (i) => (i + 1).toString())
//                     .join(',');

//             WishlistRepository.symbolSorting(
//                 param: SortListParam(
//                     symbolKey: symbolKeys, symbolOrder: orderNumbers));
//           },
//           buildDefaultDragHandles: true,
//           itemBuilder: (context, index) {
//             var record = data.nfoWatchlist![index];
//             // Remove unused variable
//             //  final item = data.mcxWatchlist![index];

//             return Container(
//               key: ValueKey(record.symbolKey),
//               child: GestureDetector(
//                 onTap: () {
//                   if (record.symbol != null) {
//                     GoRouter.of(context).pushNamed(NFOSymbols.routeName,
//                         extra: SymbolScreenParams(
//                             symbol: record.symbol.toString(),
//                             index: index,
//                             symbolKey: record.symbolKey.toString()));
//                   }
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
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
//                                   record.symbolName.toString().toUpperCase(),
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
//                                     assetId: data.nfoWatchlist![index].symbolKey
//                                         .toString(),
//                                     text:
//                                         "₹${_formatNumber(data.nfoWatchlist![index].ohlc!.salePrice)}",
//                                     compareValue: double.parse(data
//                                         .nfoWatchlist![index].ohlc!.lastPrice
//                                         .toString()),
//                                     currentValue: double.parse(data
//                                         .nfoWatchlist![index].ohlc!.salePrice
//                                         .toString()),
//                                   ),
//                                   SizedBox(width: 20.w),
//                                   BlinkingPriceText(
//                                     assetId: data.nfoWatchlist![index].symbol
//                                         .toString(),
//                                     text:
//                                         "₹${_formatNumber(data.nfoWatchlist![index].ohlc!.buyPrice)}",
//                                     compareValue: double.parse(data
//                                         .nfoWatchlist![index].ohlc!.lastPrice
//                                         .toString()),
//                                     currentValue: double.parse(data
//                                         .nfoWatchlist![index].ohlc!.buyPrice
//                                         .toString()),
//                                   ),
//                                   SizedBox(
//                                     height: 5.w,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             spacing: 5,
//                             children: [
//                               Text(
//                                 record.expiryDate ?? '',
//                               ).textStyleH2(),
//                             ],
//                           ),
//                           IconButton(
//                             onPressed: () async {
//                               final symbolKey = record.symbolKey.toString();

//                               if (!mounted) return;

//                               // final scaffoldMessenger =
//                               //     ScaffoldMessenger.of(context);

//                               setState(() {
//                                 removingItems.add(symbolKey);
//                               });

//                               try {
//                                 final success = await WishlistRepository
//                                     .removeWatchListSymbols(
//                                   category: 'NFO',
//                                   symbolKey: symbolKey,
//                                 );

//                                 if (success) {
//                                   if (!mounted) return;
//                                   setState(() {
//                                     data.nfoWatchlist!.removeAt(index);
//                                     _localWatchlist.removeAt(index);
//                                   });
//                                 }
//                               } catch (error) {
//                                 log(error.toString());
//                               } finally {
//                                 if (!mounted) return;
//                                 setState(() {
//                                   removingItems.remove(symbolKey);
//                                 });
//                               }
//                             },
//                             icon: removingItems.contains(data
//                                     .nfoWatchlist![index].symbolKey
//                                     .toString())
//                                 ? const SizedBox(
//                                     width: 24,
//                                     height: 24,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : SvgPicture.asset(
//                                     Assets
//                                         .assetsImagesSupertradeRemoveWishlistIcon,
//                                     height: 35,
//                                     // color: Colors.black,
//                                   ),
//                           )
//                         ],
//                       ),
//                       Row(
//                         // spacing: MediaQuery.sizeOf(context).width * .08,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Text("Chg: ",
//                                   style: TextStyle(
//                                       color: data.nfoWatchlist![index].change
//                                               .toString()
//                                               .contains('-')
//                                           ? Colors.red
//                                           : const Color(0xFF00C853),
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w700)),
//                               Text(_formatNumber(record.change ?? 0.0),
//                                   style: TextStyle(
//                                       color: data.nfoWatchlist![index].change
//                                               .toString()
//                                               .contains('-')
//                                           ? Colors.red
//                                           : const Color(0xFF00C853),
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w700)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               const Text(
//                                 "LTP: ",
//                               ).textStyleH3(),
//                               Text(
//                                 _formatNumber(record.ohlc!.lastPrice),
//                               ).textStyleH3(),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               const Text(
//                                 "H: ",
//                               ).textStyleH3(),
//                               Text(
//                                 _formatNumber(record.ohlc!.high),
//                               ).textStyleH3(),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               const Text(
//                                 "L: ",
//                               ).textStyleH3(),
//                               Text(
//                                 _formatNumber(record.ohlc!.low),
//                               ).textStyleH3(),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Divider(
//                         thickness: 1.5,
//                         color: Colors.grey.shade800,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }),
//     );
//   }
// }
