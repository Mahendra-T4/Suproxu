// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/extensions/color_blinker.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/core/service/Auth/user_validation.dart';
// import 'package:trading_app/features/navbar/home/mcx/McxSymbolsScreen.dart';
// import 'package:trading_app/features/navbar/home/mcx/page/mcx_home.dart';
// import 'package:trading_app/features/navbar/home/mcx/page/mcx_symbol.dart';
// import 'package:trading_app/features/navbar/home/nse-future/page/nse_future.dart';
// import 'package:trading_app/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';
// import 'package:trading_app/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/model/sorting_param.dart';
// import 'package:trading_app/features/navbar/wishlist/model/wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';
// import 'package:trading_app/features/navbar/wishlist/websocket/mcx_wishlist_websocket.dart';
// import 'package:trading_app/features/navbar/wishlist/websocket/nfo_watchlist_ws.dart';
// import 'package:trading_app/features/navbar/wishlist/widgets/search_widget.dart';
// import 'package:trading_app/features/navbar/wishlist/wishlist.dart';

// abstract class WishListHelper extends State<WishList> {
//   late final MCXWishlistWebSocketService mcxSocket;
//   MCXWishlistEntity mcxWishlist = MCXWishlistEntity();
//   String? errorMessage;
//   Timer? _timer;
//   bool _disposed = false;
//   final Set<String> removingItems = {};
//   // List<MCXWatchlist> _localWatchlist = [];

//   late final NFOWatchListWebSocketService nfoSocket;
//   NFOWishlistEntity nfoWishlist = NFOWishlistEntity();
//   TextEditingController searchController = TextEditingController();
//   bool isMarketOpen = true; // This should be fetched from your backend
//   bool isSearch = false;

//   List<String> removingNfoItems = [];
//   List<NFOWatchList> _localNfoWatchlist = [];
//   List<NFOWatchList> _reorderedNfoCopy = [];

//   Future<void> _removeNfoItem(NFOWatchList record, int index) async {
//     final symbolKey = record.symbolKey.toString();
//     if (!mounted || _disposed) return;

//     _safeSetState(() {
//       removingNfoItems.add(symbolKey);
//     });

//     try {
//       final success = await WishlistRepository.removeWatchListSymbols(
//         category: 'NFO',
//         symbolKey: symbolKey,
//       );

//       if (success && mounted && !_disposed) {
//         _safeSetState(() {
//           _localNfoWatchlist.removeAt(index);
//           nfoWishlist.nfoWatchlist?.removeAt(index);
//         });
//       }
//     } catch (error) {
//       log(error.toString());
//       if (mounted && !_disposed) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error removing item: $error'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted && !_disposed) {
//         _safeSetState(() {
//           removingNfoItems.remove(symbolKey);
//         });
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeMcxWebSocket();
//     _initializeNfoSocket();
//     AuthService().checkUserValidation();
//     _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (_disposed || !mounted) {
//         timer.cancel();
//         return;
//       }
//       AuthService().checkUserValidation();
//     });
//   }

//   void _initializeMcxWebSocket() {
//     mcxSocket = MCXWishlistWebSocketService(
//       onDataReceived: (data) {
//         _safeSetState(() {
//           mcxWishlist = data;
//         });
//       },
//       keyword: '',
//       onError: (error) {
//         _safeSetState(() {
//           errorMessage = error;
//         });
//       },
//       onConnected: () {
//         debugPrint('MCX Wishlist WebSocket Connected');
//       },
//       onDisconnected: () {
//         debugPrint('MCX Wishlist WebSocket Disconnected');
//         if (!_disposed && mounted) {
//           Future.microtask(() => mcxSocket.connect());
//         }
//       },
//     );

//     Future.microtask(() {
//       if (!_disposed) {
//         mcxSocket.connect();
//       }
//     });
//   }

//   _initializeNfoSocket() {
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
//           Future.microtask(() => nfoSocket.connect());
//         }
//       },
//     );

//     // Only connect once
//     Future.microtask(() {
//       if (!_disposed && mounted) {
//         nfoSocket.connect();
//       }
//     });
//   }

//   void _safeSetState(VoidCallback fn) {
//     if (!_disposed && mounted) {
//       setState(fn);
//     }
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     _timer?.cancel();
//     try {
//       mcxSocket.disconnect();
//       nfoSocket.disconnect();
//     } catch (e) {
//       debugPrint('Error disconnecting sockets: $e');
//     }
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   void deactivate() {
//     mcxSocket.disconnect();
//     nfoSocket.disconnect();
//     super.deactivate();
//   }

//   @override
//   void activate() {
//     if (!_disposed) {
//       mcxSocket.connect();
//       nfoSocket.connect();
//     }
//     super.activate();
//   }

//   String _formatNumber(dynamic v) {
//     if (v == null) return '0.00';
//     if (v is double) return v.toStringAsFixed(2);
//     if (v is int) return v.toString();
//     return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
//   }

//   Widget get mcxWidget => Container(
//         color: Colors.white,
//         child: Column(
//           children: [
//             SearchWidget(
//               hint: 'Search & Add',
//               isReadOnly: true,
//               onTap: () => context.pushNamed(McxHome.routeName),
//             ),
//             mcxWishlist.status != 1
//                 ? _buildLoadingState()
//                 : Expanded(
//                     child: errorMessage != null
//                         ? _buildErrorState()
//                         : (mcxWishlist.mcxWatchlist == null ||
//                                 mcxWishlist.mcxWatchlist!.isEmpty)
//                             ? _buildEmptyState()
//                             : _buildListView(),
//                   ),
//           ],
//         ),
//       );

//   Widget get nfoWidget => Column(
//         children: [
//           SearchWidget(
//             hint: 'Search & Add',
//             isReadOnly: true,
//             onTap: () {
//               context.pushNamed(NseFuture.routeName);
//             },
//           ),
//           Expanded(child: Builder(builder: (context) {
//             // Show loading state
//             final data = nfoWishlist;
//             if (data.nfoWatchlist == null) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }

//             // Show empty state
//             if (data.nfoWatchlist!.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.bookmark_border,
//                         size: 48, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Your watchlist is empty',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         context.pushNamed(NseFuture.routeName);
//                       },
//                       child: const Text('Add Symbols'),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return ReorderableListView.builder(
//               itemCount: data.nfoWatchlist!.length,
//               onReorder: (oldIndex, newIndex) {
//                 if (!mounted) return;
//                 _safeSetState(() {
//                   if (newIndex > oldIndex) newIndex--;
//                   final item = _localNfoWatchlist.removeAt(oldIndex);
//                   _localNfoWatchlist.insert(newIndex, item);
//                   // Copy reordered data
//                   _reorderedNfoCopy = List.from(_localNfoWatchlist);

//                   log(
//                       name: 'Reordered List: ',
//                       _localNfoWatchlist.first.symbolName.toString());
//                 });

//                 // Create comma-separated string for symbolKey
//                 String symbolKeys = _localNfoWatchlist
//                     .map((e) => e.symbolKey.toString())
//                     .join(',');

//                 // Create array format string for symbolOrder
//                 String orderNumbers = List.generate(
//                         _localNfoWatchlist.length, (i) => (i + 1).toString())
//                     .join(',');

//                 WishlistRepository.symbolSorting(
//                     param: SortListParam(
//                         symbolKey: symbolKeys, symbolOrder: orderNumbers));
//               },
//               buildDefaultDragHandles: true,
//               itemBuilder: (context, index) {
//                 var record = data.nfoWatchlist![index];
//                 // Remove unused variable
//                 //  final item = data.mcxWatchlist![index];

//                 return Container(
//                   key: ValueKey(record.symbolKey),
//                   child: GestureDetector(
//                     onTap: () {
//                       if (record.symbol != null) {
//                         GoRouter.of(context).pushNamed(
//                             NseFutureSymbolPage.routeName,
//                             extra: SymbolScreenParams(
//                                 symbol: record.symbol.toString(),
//                                 index: index,
//                                 symbolKey: record.symbolKey.toString()));
//                       }
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 10),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 flex: 3,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       record.symbolName
//                                           .toString()
//                                           .toUpperCase(),
//                                     ).textStyleH1(),
//                                     // SizedBox(height: 4.h),
//                                   ],
//                                 ),
//                               ),
//                               Column(
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       BlinkingPriceText(
//                                         assetId: data
//                                             .nfoWatchlist![index].symbolKey
//                                             .toString(),
//                                         text:
//                                             "₹${_formatNumber(data.nfoWatchlist![index].ohlc!.salePrice)}",
//                                         compareValue: double.parse(data
//                                             .nfoWatchlist![index]
//                                             .ohlc!
//                                             .lastPrice
//                                             .toString()),
//                                         currentValue: double.parse(data
//                                             .nfoWatchlist![index]
//                                             .ohlc!
//                                             .salePrice
//                                             .toString()),
//                                       ),
//                                       SizedBox(width: 20.w),
//                                       BlinkingPriceText(
//                                         assetId: data
//                                             .nfoWatchlist![index].symbol
//                                             .toString(),
//                                         text:
//                                             "₹${_formatNumber(data.nfoWatchlist![index].ohlc!.buyPrice)}",
//                                         compareValue: double.parse(data
//                                             .nfoWatchlist![index]
//                                             .ohlc!
//                                             .lastPrice
//                                             .toString()),
//                                         currentValue: double.parse(data
//                                             .nfoWatchlist![index].ohlc!.buyPrice
//                                             .toString()),
//                                       ),
//                                       SizedBox(
//                                         height: 5.w,
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 spacing: 5,
//                                 children: [
//                                   Text(
//                                     record.expiryDate ?? '',
//                                   ).textStyleH2(),
//                                 ],
//                               ),
//                               IconButton(
//                                 onPressed: () => _removeNfoItem(record, index),
//                                 icon: removingNfoItems.contains(data
//                                         .nfoWatchlist![index].symbolKey
//                                         .toString())
//                                     ? const SizedBox(
//                                         width: 24,
//                                         height: 24,
//                                         child: CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2,
//                                         ),
//                                       )
//                                     : SvgPicture.asset(
//                                         Assets
//                                             .assetsImagesSupertradeRemoveWishlistIcon,
//                                         height: 35,
//                                       ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             // spacing: MediaQuery.sizeOf(context).width * .08,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text("Chg: ",
//                                       style: TextStyle(
//                                           color: data
//                                                   .nfoWatchlist![index].change
//                                                   .toString()
//                                                   .contains('-')
//                                               ? Colors.red
//                                               : const Color(0xFF00C853),
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w700)),
//                                   Text(_formatNumber(record.change ?? 0.0),
//                                       style: TextStyle(
//                                           color: data
//                                                   .nfoWatchlist![index].change
//                                                   .toString()
//                                                   .contains('-')
//                                               ? Colors.red
//                                               : const Color(0xFF00C853),
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w700)),
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   const Text(
//                                     "LTP: ",
//                                   ).textStyleH3(),
//                                   Text(
//                                     _formatNumber(record.ohlc!.lastPrice),
//                                   ).textStyleH3(),
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   const Text(
//                                     "H: ",
//                                   ).textStyleH3(),
//                                   Text(
//                                     _formatNumber(record.ohlc!.high),
//                                   ).textStyleH3(),
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   const Text(
//                                     "L: ",
//                                   ).textStyleH3(),
//                                   Text(
//                                     _formatNumber(record.ohlc!.low),
//                                   ).textStyleH3(),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Divider(
//                             thickness: 1.5,
//                             color: Colors.grey.shade800,
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }))
//         ],
//       );

//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 48, color: Colors.red),
//           const SizedBox(height: 16),
//           Text(
//             errorMessage ?? 'An error occurred',
//             style: const TextStyle(color: Colors.red),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               if (!mounted) return;
//               setState(() => errorMessage = null);
//               mcxSocket.connect();
//             },
//             child: const Text('Retry Connection'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.bookmark_border, size: 48, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           const Text(
//             'Your watchlist is empty',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           ElevatedButton(
//             onPressed: () => context.pushNamed(McxHome.routeName),
//             child: const Text('Add Symbols'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Loading watchlist...'),
//         ],
//       ),
//     );
//   }

//   Widget _buildListView() {
//     return ListView.builder(
//       itemCount: mcxWishlist.mcxWatchlist?.length,
//       // onReorder: (oldIndex, newIndex) {
//       //   _safeSetState(() {
//       //     if (newIndex > oldIndex) newIndex--;
//       //     final item = _localWatchlist.removeAt(oldIndex);
//       //     _localWatchlist.insert(newIndex, item);
//       //   });

//       //   // Update server-side order
//       //   final symbolKeys =
//       //       _localWatchlist.map((e) => e.symbolKey ?? '').join(',');
//       //   final orderNumbers =
//       //       List.generate(_localWatchlist.length, (i) => (i + 1).toString())
//       //           .join(',');

//       //   WishlistRepository.symbolSorting(
//       //     param: SortListParam(
//       //       symbolKey: symbolKeys,
//       //       symbolOrder: orderNumbers,
//       //     ),
//       //   );
//       // },
//       itemBuilder: (context, index) {
//         final item = mcxWishlist.mcxWatchlist![index];
//         return GestureDetector(
//           key: ValueKey(item.symbolKey),
//           onTap: () {
//             if (item.symbol != null) {
//               context.pushNamed(
//                 MCXSymbolRecordPage.routeName,
//                 extra: MCXSymbolParams(
//                   symbol: item.symbol.toString(),
//                   index: index,
//                   symbolKey: item.symbolKey.toString(),
//                 ),
//               );
//             }
//           },
//           child: _buildListItem(item, index),
//         );
//       },
//     );
//   }

//   Widget _buildListItem(MCXWatchlist item, int index) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           _buildItemHeader(item),
//           _buildItemControls(item, index),
//           _buildItemFooter(item),
//           Divider(thickness: 1, color: Colors.grey.shade800),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemHeader(MCXWatchlist item) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           flex: 3,
//           child: Text(item.symbolName ?? '').textStyleH1(),
//         ),
//         Row(
//           children: [
//             BlinkingPriceText(
//               assetId: item.symbolKey.toString(),
//               text: "₹${_formatNumber(item.ohlc!.salePrice)}",
//               compareValue: item.ohlc!.lastPrice,
//               currentValue: item.ohlc!.salePrice,
//             ),
//             SizedBox(width: 10.w),
//             BlinkingPriceText(
//               assetId: item.symbolName.toString(),
//               text: "₹${_formatNumber(item.ohlc!.buyPrice)}",
//               compareValue: item.ohlc!.lastPrice,
//               currentValue: item.ohlc!.buyPrice,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildItemControls(MCXWatchlist item, int index) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(item.expiryDate ?? '').textStyleH2(),
//         IconButton(
//           onPressed: () => _removeItem(item, index),
//           icon: removingItems.contains(item.symbolKey.toString())
//               ? const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 )
//               : SvgPicture.asset(
//                   Assets.assetsImagesSupertradeRemoveWishlistIcon,
//                   height: 35,
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildItemFooter(MCXWatchlist item) {
//     final isNegative = item.change.toString().contains('-');
//     final changeColor = isNegative ? Colors.red : Colors.green;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text(
//               "Chg: ",
//               style: TextStyle(
//                 color: changeColor,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             Text(
//               _formatNumber(item.change ?? 0.0),
//               style: TextStyle(
//                 color: changeColor,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             const Text("LTP: ").textStyleH3(),
//             Text(_formatNumber(item.ohlc!.lastPrice)).textStyleH3(),
//           ],
//         ),
//         Row(
//           children: [
//             const Text("H: ").textStyleH3(),
//             Text(_formatNumber(item.ohlc!.high)).textStyleH3(),
//           ],
//         ),
//         Row(
//           children: [
//             const Text("L: ").textStyleH3(),
//             Text(_formatNumber(item.ohlc!.low)).textStyleH3(),
//           ],
//         ),
//       ],
//     );
//   }

//   Future<void> _removeItem(MCXWatchlist item, int index) async {
//     final symbolKey = item.symbolKey.toString();
//     if (!mounted || _disposed) return;

//     _safeSetState(() => removingItems.add(symbolKey));

//     try {
//       final success = await WishlistRepository.removeWatchListSymbols(
//         category: 'MCX',
//         symbolKey: symbolKey,
//       );

//       if (success && mounted && !_disposed) {
//         _safeSetState(() {
//           mcxWishlist.mcxWatchlist?.removeAt(index);
//         });
//       }
//     } catch (error) {
//       if (mounted && !_disposed) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error removing item: $error'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted && !_disposed) {
//         _safeSetState(() => removingItems.remove(symbolKey));
//       }
//     }
//   }
// }
