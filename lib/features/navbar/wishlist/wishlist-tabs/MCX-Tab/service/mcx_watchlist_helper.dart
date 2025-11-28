// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:async';
// import 'dart:developer' as developer;
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
// import 'package:trading_app/core/service/repositorie/global_respo.dart';
// import 'package:trading_app/features/navbar/home/mcx/mcx.dart';
// import 'package:trading_app/features/navbar/home/mcx/page/mcx_symbol.dart';
// import 'package:trading_app/features/navbar/home/model/stock_list_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/model/sorting_param.dart';
// import 'package:trading_app/features/navbar/wishlist/provider/mcx_wishlist_ws_provider.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';
// import 'package:trading_app/features/navbar/wishlist/widgets/search_widget.dart';

// class McxWatchlistHelper extends ConsumerStatefulWidget {
//   const McxWatchlistHelper({
//     super.key,
//   });

//   static const String routeName = '/mcx-wishlist-panel';

//   @override
//   ConsumerState<McxWatchlistHelper> createState() => _MCXWatchListState();
// }

// class _MCXWatchListState extends ConsumerState<McxWatchlistHelper>
//     with SingleTickerProviderStateMixin {
//   late Timer _timer;
//   late TabController _tabController;
//   late StockListEntity stockListEntity;
//   dynamic stockName;

//   final TextEditingController searchController = TextEditingController();
//   bool isSearch = false;

//   bool isMarketOpen = true;

//   final FocusNode _searchFocusNode = FocusNode();

//   List<String> removingItems = [];
//   dynamic tabList;

//   List<MCXWatchlist> _localWatchlist = [];
//   List<MCXWatchlist> _reorderedCopy = [];

//   initTabs() async {
//     stockListEntity = await GlobalRepository.stocksMapper();
//   }

//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     return NumberFormat('#,##,##0.00').format(number);
//   }

//   // void _checkMarketStatus() {
//   //   final now = DateTime.now();
//   //   final marketOpenTime = DateTime(now.year, now.month, now.day, 9, 15);
//   //   final marketCloseTime = DateTime(now.year, now.month, now.day, 23, 00);

//   //   // Make sure the system is not on Saturday or Sunday
//   //   final isWeekday =
//   //       now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;

//   //   final newMarketStatus = isWeekday &&
//   //       now.isAfter(marketOpenTime) &&
//   //       now.isBefore(marketCloseTime);

//   //   if (isMarketOpen != newMarketStatus) {

//   //     setState(() {
//   //       isMarketOpen = newMarketStatus;
//   //     });
//   //   }

//   //   print('Now: $now');
//   //   print('Market Open Time: $marketOpenTime');
//   //   print('Market Close Time: $marketCloseTime');
//   //   print('Market Status: $isMarketOpen');
//   // }

//   @override
//   void initState() {
//     super.initState();
//     initTabs();
//     _tabController = TabController(length: 5, vsync: this);

//     // // Start periodic polling every 3 seconds
//     _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       AuthService().checkUserValidation();
//     });

//     AuthService().checkUserValidation();

//     // _checkMarketStatus();

//     // Fetch initial data
//     // fetchData();
//   }

//   @override
//   void dispose() {
//     _timer.cancel();

//     _searchFocusNode.dispose();

//     _tabController.dispose();
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(mcxWishlistWSProvider);

//     if (state.errorMessage != null) {
//       return Expanded(
//         child: Center(
//           child: Text('Error: ${state.errorMessage}'),
//         ),
//       );
//     }

//     // Show no data message if data is null or status is not 1
//     if (state.data == null || state.data!.status != 1) {
//       return const Expanded(
//         child: Center(
//           child: Text('No data available'),
//         ),
//       );
//     }

//     // Show no items message if watchlist is empty
//     if (state.data!.mcxWatchlist == null || state.data!.mcxWatchlist!.isEmpty) {
//       return const Expanded(
//         child: Center(
//           child: Text('Your watchlist is empty'),
//         ),
//       );
//     }

//     final data = state.data!;

//     return Expanded(
//       child: ReorderableListView.builder(
//         itemCount: data.mcxWatchlist!.length,
//         onReorder: (oldIndex, newIndex) {
//           setState(() {
//             if (newIndex > oldIndex) newIndex--;
//             final item = _localWatchlist.removeAt(oldIndex);
//             _localWatchlist.insert(newIndex, item);
//             // Copy reordered data
//             _reorderedCopy = List.from(_localWatchlist);

//             log(
//                 name: 'Reordered List: ',
//                 _localWatchlist.first.symbolName.toString());
//             // _reorderedCopy.map((element) => element);
//           });

//           // Create comma-separated string for symbolKey
//           String symbolKeys =
//               _localWatchlist.map((e) => e.symbolKey.toString()).join(',');

//           // Create array format string for symbolOrder
//           String orderNumbers =
//               List.generate(_localWatchlist.length, (i) => (i + 1).toString())
//                   .join(',');

//           WishlistRepository.symbolSorting(
//               param: SortListParam(
//                   symbolKey: symbolKeys, symbolOrder: orderNumbers));
//         },
//         buildDefaultDragHandles: true,
//         itemBuilder: (context, index) {
//           final item = data.mcxWatchlist![index];
//           return GestureDetector(
//             key: ValueKey(item.symbolKey),
//             onTap: () {
//               if (item.symbol != null) {
//                 GoRouter.of(context).pushNamed(
//                   MCXSymbolRecordPage.routeName,
//                   extra: MCXSymbolParams(
//                     symbol: item.symbol.toString(),
//                     index: index,
//                     symbolKey: item.symbolKey.toString(),
//                   ),
//                 );
//               }
//             },
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         flex: 3,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(item.symbolName ?? '').textStyleH1(),
//                           ],
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               BlinkingPriceText(
//                                 assetId: item.symbolKey.toString(),
//                                 text: "₹${_formatNumber(item.ohlc!.salePrice)}",
//                                 compareValue: item.ohlc!.lastPrice,
//                                 currentValue: item.ohlc!.salePrice,
//                               ),
//                               SizedBox(width: 10.w),
//                               BlinkingPriceText(
//                                 assetId: item.symbolName.toString(),
//                                 text: "₹${_formatNumber(item.ohlc!.buyPrice)}",
//                                 compareValue: item.ohlc!.lastPrice,
//                                 currentValue: item.ohlc!.buyPrice,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         // spacing: 5,
//                         children: [
//                           Text(
//                             item.expiryDate ?? '',
//                           ).textStyleH2(),
//                         ],
//                       ),
//                       IconButton(
//                         onPressed: () async {
//                           final symbolKey = item.symbolKey.toString();

//                           // Start loading state
//                           if (!mounted) return;
//                           setState(() {
//                             removingItems.add(symbolKey);
//                           });

//                           try {
//                             final success =
//                                 await WishlistRepository.removeWatchListSymbols(
//                               category: 'MCX',
//                               symbolKey: symbolKey,
//                             );

//                             if (success && mounted) {
//                               setState(() {
//                                 data.mcxWatchlist!.removeAt(index);
//                               });
//                             } else if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                       'Failed to remove item. Please try again.'),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             }
//                           } catch (error) {
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Error removing item: $error'),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             }
//                           } finally {
//                             if (mounted) {
//                               setState(() {
//                                 removingItems.remove(symbolKey);
//                               });
//                             }
//                           }
//                         },
//                         icon: removingItems.contains(item.symbolKey.toString())
//                             ? const SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : SvgPicture.asset(
//                                 Assets.assetsImagesSupertradeRemoveWishlistIcon,
//                                 height: 35,
//                                 // color: Colors.black,
//                               ),
//                       )
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Text("Chg: ",
//                               style: TextStyle(
//                                   color: item.change.toString().contains('-')
//                                       ? Colors.red
//                                       : const Color(0xFF00C853),
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w700)),
//                           Text(_formatNumber(item.change ?? 0.0),
//                               style: TextStyle(
//                                   color: item.change.toString().contains('-')
//                                       ? Colors.red
//                                       : Colors.green,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w700)),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const Text(
//                             "LTP: ",
//                           ).textStyleH3(),
//                           Text(
//                             _formatNumber(item.ohlc!.lastPrice),
//                           ).textStyleH3(),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const Text(
//                             "H: ",
//                           ).textStyleH3(),
//                           Text(
//                             _formatNumber(item.ohlc!.high),
//                           ).textStyleH3(),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const Text(
//                             "L: ",
//                           ).textStyleH3(),
//                           Text(
//                             _formatNumber(item.ohlc!.low),
//                           ).textStyleH3(),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Divider(
//                     thickness: 1,
//                     color: Colors.grey.shade800,
//                   )
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Color contColor(dynamic open, dynamic last) {
//     final value = open - last;
//     if (value >= 0) {
//       return Colors.green;
//     } else {
//       return Colors.red;
//     }
//   }
// }
