// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/extensions/color_blinker.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/core/service/Auth/user_validation.dart';
// import 'package:trading_app/features/navbar/home/nse-future/fnoSymbolScreen.dart';
// import 'package:trading_app/features/navbar/home/nse-future/page/nse_future.dart';
// import 'package:trading_app/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';
// import 'package:trading_app/features/navbar/wishlist/model/sorting_param.dart';
// import 'package:trading_app/features/navbar/wishlist/model/wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';
// import 'package:trading_app/features/navbar/wishlist/websocket/nfo_watchlist_ws.dart';
// import 'package:trading_app/features/navbar/wishlist/widgets/search_widget.dart';

// import '../../../../home/nse-future/models/nfo_symbol_param.dart';

// class NseFutureStockWishlist extends StatefulWidget {
//   const NseFutureStockWishlist({super.key});

//   @override
//   State<NseFutureStockWishlist> createState() => _NseFutureStockWishlistState();
// }

// class _NseFutureStockWishlistState extends State<NseFutureStockWishlist> {
//   late final NFOWatchListWebSocketService nfoSocket;
//   NFOWishlistEntity nfoWishlist = NFOWishlistEntity();
//   TextEditingController searchController = TextEditingController();
//   bool isMarketOpen = true; // This should be fetched from your backend
//   bool isSearch = false;

//   List<String> removingNfoItems = [];
//   List<NFOWatchList> _localNfoWatchlist = [];
//   List<NFOWatchList> _reorderedNfoCopy = [];

//   late Timer _timer;
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       if (mounted) {
//         _initializeWebSocket();
//         _setupAuthCheck();
//       }
//     });
//   }

//   void _initializeWebSocket() {
//     if (_disposed) return;

//     nfoSocket = NFOWatchListWebSocketService(
//       onNFODataReceived: (data) {
//         _safeSetState(() {
//           nfoWishlist = data;
//           _localNfoWatchlist = List<NFOWatchList>.from(data.nfoWatchlist ?? []);
//         });
//       },
//       onError: (error) {
//         log('WebSocket Error: $error');
//         _safeSetState(() {
//           nfoWishlist = NFOWishlistEntity();
//           _localNfoWatchlist = [];
//         });
//       },
//       onConnected: () {
//         log('WebSocket Connected');
//       },
//       onDisconnected: () {
//         log('WebSocket Disconnected');
//         if (!_disposed && mounted) {
//           Future.delayed(const Duration(seconds: 1), () {
//             nfoSocket.connect();
//           });
//         }
//       },
//     );

//     if (!_disposed && mounted) {
//       nfoSocket.connect();
//     }
//   }

//   void _setupAuthCheck() {
//     AuthService().checkUserValidation();
//     _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (_disposed || !mounted) {
//         timer.cancel();
//         return;
//       }
//       AuthService().checkUserValidation();
//     });
//   }

//   // Remove unused methods

//   bool _disposed = false;

//   @override
//   void dispose() {
//     _disposed = true;
//     _timer.cancel(); // Cancel the timer
//     nfoSocket.disconnect();
//     searchController.dispose();
//     super.dispose();
//   }

//   void _safeSetState(VoidCallback fn) {
//     if (!_disposed && mounted) {
//       setState(fn);
//     }
//   }

//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     final formatter = NumberFormat('#,##,##0.00');
//     return formatter.format(number);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kWhiteColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             SearchWidget(
//               hint: 'Search & Add',
//               isReadOnly: true,
//               onTap: () {
//                 context.pushNamed(NseFuture.routeName);
//               },
//             ),
//             Expanded(child: Builder(builder: (context) {
//               // Show loading state
//               final data = nfoWishlist;
//               if (data.nfoWatchlist == null) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }

//               // Show empty state
//               if (data.nfoWatchlist!.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.bookmark_border,
//                           size: 48, color: Colors.grey[400]),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Your watchlist is empty',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       ElevatedButton(
//                         onPressed: () {
//                           context.pushNamed(NseFuture.routeName);
//                         },
//                         child: const Text('Add Symbols'),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return ReorderableListView.builder(
//                 itemCount: data.nfoWatchlist!.length,
//                 onReorder: (oldIndex, newIndex) {
//                   _safeSetState(() {
//                     if (newIndex > oldIndex) newIndex--;
//                     final item = _localNfoWatchlist.removeAt(oldIndex);
//                     _localNfoWatchlist.insert(newIndex, item);
//                     // Copy reordered data
//                     _reorderedNfoCopy = List.from(_localNfoWatchlist);

//                     log(
//                         name: 'Reordered List: ',
//                         _localNfoWatchlist.first.symbolName.toString());
//                   });

//                   // Create comma-separated string for symbolKey
//                   String symbolKeys = _localNfoWatchlist
//                       .map((e) => e.symbolKey.toString())
//                       .join(',');

//                   // Create array format string for symbolOrder
//                   String orderNumbers = List.generate(
//                           _localNfoWatchlist.length, (i) => (i + 1).toString())
//                       .join(',');

//                   WishlistRepository.symbolSorting(
//                       param: SortListParam(
//                           symbolKey: symbolKeys, symbolOrder: orderNumbers));
//                 },
//                 buildDefaultDragHandles: true,
//                 itemBuilder: (context, index) {
//                   var record = data.nfoWatchlist![index];
//                   // Remove unused variable
//                   //  final item = data.mcxWatchlist![index];

//                   return Container(
//                     key: ValueKey(record.symbolKey),
//                     child: GestureDetector(
//                       onTap: () {
//                         if (record.symbol != null) {
//                           GoRouter.of(context).pushNamed(
//                               NseFutureSymbolPage.routeName,
//                               extra: SymbolScreenParams(
//                                   symbol: record.symbol.toString(),
//                                   index: index,
//                                   symbolKey: record.symbolKey.toString()));
//                         }
//                       },
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         record.symbolName
//                                             .toString()
//                                             .toUpperCase(),
//                                       ).textStyleH1(),
//                                       // SizedBox(height: 4.h),
//                                     ],
//                                   ),
//                                 ),
//                                 Column(
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         BlinkingPriceText(
//                                           assetId: data
//                                               .nfoWatchlist![index].symbolKey
//                                               .toString(),
//                                           text:
//                                               "₹${_formatNumber(data.nfoWatchlist![index].ohlc!.salePrice)}",
//                                           compareValue: double.parse(data
//                                               .nfoWatchlist![index]
//                                               .ohlc!
//                                               .lastPrice
//                                               .toString()),
//                                           currentValue: double.parse(data
//                                               .nfoWatchlist![index]
//                                               .ohlc!
//                                               .salePrice
//                                               .toString()),
//                                         ),
//                                         SizedBox(width: 20.w),
//                                         BlinkingPriceText(
//                                           assetId: data
//                                               .nfoWatchlist![index].symbol
//                                               .toString(),
//                                           text:
//                                               "₹${_formatNumber(data.nfoWatchlist![index].ohlc!.buyPrice)}",
//                                           compareValue: double.parse(data
//                                               .nfoWatchlist![index]
//                                               .ohlc!
//                                               .lastPrice
//                                               .toString()),
//                                           currentValue: double.parse(data
//                                               .nfoWatchlist![index]
//                                               .ohlc!
//                                               .buyPrice
//                                               .toString()),
//                                         ),
//                                         SizedBox(
//                                           height: 5.w,
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   spacing: 5,
//                                   children: [
//                                     Text(
//                                       record.expiryDate ?? '',
//                                     ).textStyleH2(),
//                                   ],
//                                 ),
//                                 IconButton(
//                                   onPressed: () async {
//                                     final symbolKey =
//                                         record.symbolKey.toString();

//                                     if (!mounted) return;

//                                     // final scaffoldMessenger =
//                                     //     ScaffoldMessenger.of(context);

//                                     _safeSetState(() {
//                                       removingNfoItems.add(symbolKey);
//                                     });

//                                     try {
//                                       final success = await WishlistRepository
//                                           .removeWatchListSymbols(
//                                         category: 'NFO',
//                                         symbolKey: symbolKey,
//                                       );

//                                       if (success) {
//                                         _safeSetState(() {
//                                           data.nfoWatchlist!.removeAt(index);
//                                           _localNfoWatchlist.removeAt(index);
//                                         });
//                                       }
//                                     } catch (error) {
//                                       log(error.toString());
//                                     } finally {
//                                       _safeSetState(() {
//                                         removingNfoItems.remove(symbolKey);
//                                       });
//                                     }
//                                   },
//                                   icon: removingNfoItems.contains(data
//                                           .nfoWatchlist![index].symbolKey
//                                           .toString())
//                                       ? const SizedBox(
//                                           width: 24,
//                                           height: 24,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : SvgPicture.asset(
//                                           Assets
//                                               .assetsImagesSupertradeRemoveWishlistIcon,
//                                           height: 35,
//                                           // color: Colors.black,
//                                         ),
//                                 )
//                               ],
//                             ),
//                             Row(
//                               // spacing: MediaQuery.sizeOf(context).width * .08,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text("Chg: ",
//                                         style: TextStyle(
//                                             color: data
//                                                     .nfoWatchlist![index].change
//                                                     .toString()
//                                                     .contains('-')
//                                                 ? Colors.red
//                                                 : const Color(0xFF00C853),
//                                             fontSize: 11,
//                                             fontWeight: FontWeight.w700)),
//                                     Text(_formatNumber(record.change ?? 0.0),
//                                         style: TextStyle(
//                                             color: data
//                                                     .nfoWatchlist![index].change
//                                                     .toString()
//                                                     .contains('-')
//                                                 ? Colors.red
//                                                 : const Color(0xFF00C853),
//                                             fontSize: 11,
//                                             fontWeight: FontWeight.w700)),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       "LTP: ",
//                                     ).textStyleH3(),
//                                     Text(
//                                       _formatNumber(record.ohlc!.lastPrice),
//                                     ).textStyleH3(),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       "H: ",
//                                     ).textStyleH3(),
//                                     Text(
//                                       _formatNumber(record.ohlc!.high),
//                                     ).textStyleH3(),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       "L: ",
//                                     ).textStyleH3(),
//                                     Text(
//                                       _formatNumber(record.ohlc!.low),
//                                     ).textStyleH3(),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Divider(
//                               thickness: 1.5,
//                               color: Colors.grey.shade800,
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }))
//           ],
//         ),
//       ),
//     );
//   }
// }
