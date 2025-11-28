// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/extensions/color_blinker.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';

// import 'package:trading_app/features/navbar/home/mcx/page/mcx_home.dart';
// import 'package:trading_app/features/navbar/home/mcx/page/mcx_symbol.dart';
// import 'package:trading_app/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/model/sorting_param.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';
// import 'package:trading_app/features/navbar/wishlist/websocket/mcx_wishlist_websocket.dart';

// import 'package:trading_app/features/navbar/home/mcx/page/mcx_home.dart';
// import 'package:trading_app/features/navbar/home/nse-future/page/nse_future.dart';
// import 'package:trading_app/features/navbar/wishlist/widgets/search_widget.dart';

// class McxWishlist1 extends StatefulWidget {
//   const McxWishlist1({super.key});

//   @override
//   State<McxWishlist1> createState() => _McxWishlist1State();
// }

// class _McxWishlist1State extends State<McxWishlist1> {
//   late final MCXWishlistWebSocketService socket;
//   MCXWishlistEntity mcxWishlist = MCXWishlistEntity();
//   String? errorMessage;
//   bool _disposed = false;
//   final Set<String> removingItems = {};
//   // List<MCXWatchlist> _localWatchlist = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebSocket();
//   }

//   void _initializeWebSocket() {
//     socket = MCXWishlistWebSocketService(
//       onDataReceived: (data) {
//         if (!mounted) return;
//         setState(() {
//           mcxWishlist = data;
//         });
//       },
//       keyword: '',
//       onError: (error) {
//         if (!mounted) return;
//         setState(() {
//           errorMessage = error;
//         });
//       },
//       onConnected: () {
//         debugPrint('MCX Wishlist WebSocket Connected');
//       },
//       onDisconnected: () {
//         debugPrint('MCX Wishlist WebSocket Disconnected');
//         if (!_disposed) {
//           Future.microtask(() => socket.connect());
//         }
//       },
//     );

//     Future.microtask(() {
//       if (!_disposed) {
//         socket.connect();
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
//     try {
//       socket.disconnect();
//     } catch (e) {
//       debugPrint('Error disconnecting socket: $e');
//     }
//     super.dispose();
//   }

//   @override
//   void deactivate() {
//     socket.disconnect();

//     super.deactivate();
//   }

//   @override
//   void activate() {
//     if (!_disposed) {
//       socket.connect();
//     }
//     super.activate();
//   }

//   String _formatNumber(dynamic v) {
//     if (v == null) return '0.00';
//     if (v is double) return v.toStringAsFixed(2);
//     if (v is int) return v.toString();
//     return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: double.infinity,
//       color: Colors.white,
//       child: Column(
//         children: [
//           SearchWidget(
//             hint: 'Search & Add',
//             isReadOnly: true,
//             onTap: () => context.pushNamed(McxHome.routeName),
//           ),
//           mcxWishlist.status != 1
//               ? _buildLoadingState()
//               : Expanded(
//                   child: errorMessage != null
//                       ? _buildErrorState()
//                       : (mcxWishlist.mcxWatchlist == null ||
//                               mcxWishlist.mcxWatchlist!.isEmpty)
//                           ? _buildEmptyState()
//                           : _buildListView(),
//                 ),
//         ],
//       ),
//     );
//   }

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
//               setState(() => errorMessage = null);
//               socket.connect();
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
//     if (!mounted) return;

//     setState(() => removingItems.add(symbolKey));

//     try {
//       final success = await WishlistRepository.removeWatchListSymbols(
//         category: 'MCX',
//         symbolKey: symbolKey,
//       );

//       if (success && mounted && !_disposed) {
//         setState(() {
//           // _localWatchlist.removeAt(index);
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
//         setState(() => removingItems.remove(symbolKey));
//       }
//     }
//   }
// }
