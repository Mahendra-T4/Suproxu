// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/extensions/color_blinker.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/features/navbar/home/mcx/page/mcx_symbol.dart';
// import 'package:trading_app/features/navbar/home/mcx/page/mcx_home.dart';
// import 'package:trading_app/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';
// import 'package:trading_app/features/navbar/wishlist/websocket/mcx_wishlist_websocket.dart';
// import 'package:trading_app/features/navbar/wishlist/model/sorting_param.dart';
// import 'package:trading_app/features/navbar/wishlist/widgets/search_widget.dart';

// class McxStockWishlist extends StatefulWidget {
//   const McxStockWishlist({super.key});
//   static const String routeName = '/mcx-stock-wishlist';

//   @override
//   State<McxStockWishlist> createState() => _McxStockWishlistState();
// }

// class _McxStockWishlistState extends State<McxStockWishlist> {
//   late final MCXWishlistWebSocketService socket;
//   MCXWishlistEntity mcxWishlist = MCXWishlistEntity();
//   String? errorMessage;
//   List<MCXWatchlist> _localWatchlist = [];
//   Set<String> removingItems = {};
//   bool _disposed = false;

//   void _safeSetState(VoidCallback fn) {
//     if (!_disposed && mounted) {
//       setState(fn);
//     }
//   }

//   String _formatNumber(dynamic v) {
//     if (v == null) return '0.00';
//     if (v is double) return v.toStringAsFixed(2);
//     if (v is int) return v.toString();
//     return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
//   }

//   @override
//   void initState() {
//     super.initState();
//     socket = MCXWishlistWebSocketService(
//       onDataReceived: (data) {
//         if (!mounted) return;
//         Future.microtask(() {
//           if (!mounted) return;
//           setState(() {
//             mcxWishlist = data;
//             _localWatchlist = List.from(mcxWishlist.mcxWatchlist ?? []);
//           });
//         });
//       },
//       keyword: '',
//       onError: (error) {
//         if (!mounted) return;
//         Future.microtask(() {
//           if (!mounted) return;
//           setState(() {
//             errorMessage = error;
//           });
//         });
//       },
//       onConnected: () {
//         debugPrint('MCX Wishlist WebSocket Connected Successfully');
//         if (!mounted) return;
//         Future.microtask(() {
//           if (!mounted) return;
//           setState(() {
//             errorMessage = null;
//           });
//         });
//       },
//       onDisconnected: () {
//         debugPrint('MCX Wishlist WebSocket Disconnected');
//       },
//     );

//     // Schedule connection for next frame
//     Future.microtask(() {
//       if (!mounted) return;
//       socket.connect();
//     });
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
//     socket.connect();
//     super.activate();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kWhiteColor,
//       body: Column(
//         children: [
//           SearchWidget(
//             hint: 'Search & Add',
//             isReadOnly: true,
//             onTap: () {
//               GoRouter.of(context).pushNamed(McxHome.routeName);
//             },
//           ),
//           Builder(
//             builder: (context) {
//               if (errorMessage != null) {
//                 return Expanded(
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height - 200,
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Error: $errorMessage',
//                               style: const TextStyle(color: Colors.red),
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 16),
//                             ElevatedButton(
//                               onPressed: () {
//                                 setState(() {
//                                   errorMessage = null;
//                                 });
//                                 socket.connect();
//                               },
//                               child: const Text('Retry Connection'),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }

//               if (mcxWishlist.mcxWatchlist == null) {
//                 return const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(height: 16),
//                       Text('Loading watchlist...'),
//                     ],
//                   ),
//                 );
//               }

//               if (mcxWishlist.mcxWatchlist!.isEmpty) {
//                 return Expanded(
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.bookmark_border,
//                             size: 48, color: Colors.grey[400]),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'Your watchlist is empty',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ElevatedButton(
//                           onPressed: () {
//                             GoRouter.of(context).pushNamed(McxHome.routeName);
//                           },
//                           child: const Text('Add Symbols'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }

//               return Expanded(
//                 child: ReorderableListView.builder(
//                   itemCount: _localWatchlist.length,
//                   onReorder: (oldIndex, newIndex) {
//                     setState(() {
//                       if (newIndex > oldIndex) newIndex--;
//                       final item = _localWatchlist.removeAt(oldIndex);
//                       _localWatchlist.insert(newIndex, item);
//                       log('Reordered List: ${_localWatchlist.first.symbolName}');
//                     });

//                     String symbolKeys =
//                         _localWatchlist.map((e) => e.symbolKey ?? '').join(',');
//                     String orderNumbers = List.generate(
//                             _localWatchlist.length, (i) => (i + 1).toString())
//                         .join(',');

//                     WishlistRepository.symbolSorting(
//                       param: SortListParam(
//                           symbolKey: symbolKeys, symbolOrder: orderNumbers),
//                     );
//                   },
//                   buildDefaultDragHandles: true,
//                   itemBuilder: (context, index) {
//                     final item = _localWatchlist[index];
//                     return GestureDetector(
//                       key: ValueKey(item.symbolKey),
//                       onTap: () {
//                         if (item.symbol != null) {
//                           GoRouter.of(context).pushNamed(
//                             MCXSymbolRecordPage.routeName,
//                             extra: MCXSymbolParams(
//                               symbol: item.symbol.toString(),
//                               index: index,
//                               symbolKey: item.symbolKey.toString(),
//                             ),
//                           );
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
//                                       Text(item.symbolName ?? '').textStyleH1(),
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
//                                           assetId: item.symbolKey.toString(),
//                                           text:
//                                               "₹${_formatNumber(item.ohlc!.salePrice)}",
//                                           compareValue: item.ohlc!.lastPrice,
//                                           currentValue: item.ohlc!.salePrice,
//                                         ),
//                                         SizedBox(width: 10.w),
//                                         BlinkingPriceText(
//                                           assetId: item.symbolName.toString(),
//                                           text:
//                                               "₹${_formatNumber(item.ohlc!.buyPrice)}",
//                                           compareValue: item.ohlc!.lastPrice,
//                                           currentValue: item.ohlc!.buyPrice,
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
//                                   children: [
//                                     Text(item.expiryDate ?? '').textStyleH2(),
//                                   ],
//                                 ),
//                                 IconButton(
//                                   onPressed: () async {
//                                     final symbolKey = item.symbolKey.toString();

//                                     if (!mounted) return;
//                                     setState(() {
//                                       removingItems.add(symbolKey);
//                                     });

//                                     try {
//                                       final success = await WishlistRepository
//                                           .removeWatchListSymbols(
//                                         category: 'MCX',
//                                         symbolKey: symbolKey,
//                                       );

//                                       if (success && mounted) {
//                                         setState(() {
//                                           _localWatchlist.removeAt(index);
//                                           mcxWishlist.mcxWatchlist!
//                                               .removeAt(index);
//                                         });
//                                       } else if (mounted) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           const SnackBar(
//                                             content: Text(
//                                                 'Failed to remove item. Please try again.'),
//                                             backgroundColor: Colors.red,
//                                           ),
//                                         );
//                                       }
//                                     } catch (error) {
//                                       if (mounted) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           SnackBar(
//                                             content: Text(
//                                                 'Error removing item: $error'),
//                                             backgroundColor: Colors.red,
//                                           ),
//                                         );
//                                       }
//                                     } finally {
//                                       if (mounted) {
//                                         setState(() {
//                                           removingItems.remove(symbolKey);
//                                         });
//                                       }
//                                     }
//                                   },
//                                   icon: removingItems
//                                           .contains(item.symbolKey.toString())
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
//                                         ),
//                                 )
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(
//                                       "Chg: ",
//                                       style: TextStyle(
//                                         color:
//                                             item.change.toString().contains('-')
//                                                 ? Colors.red
//                                                 : const Color(0xFF00C853),
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                     Text(
//                                       _formatNumber(item.change ?? 0.0),
//                                       style: TextStyle(
//                                         color:
//                                             item.change.toString().contains('-')
//                                                 ? Colors.red
//                                                 : Colors.green,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text("LTP: ").textStyleH3(),
//                                     Text(_formatNumber(item.ohlc!.lastPrice))
//                                         .textStyleH3(),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text("H: ").textStyleH3(),
//                                     Text(_formatNumber(item.ohlc!.high))
//                                         .textStyleH3(),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text("L: ").textStyleH3(),
//                                     Text(_formatNumber(item.ohlc!.low))
//                                         .textStyleH3(),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Divider(
//                               thickness: 1,
//                               color: Colors.grey.shade800,
//                             )
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
