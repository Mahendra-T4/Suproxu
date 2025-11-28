// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
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
// import 'package:trading_app/features/navbar/home/nse-future/page/nse_future.dart';
// import 'package:trading_app/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';
// import 'package:trading_app/features/navbar/wishlist/model/sorting_param.dart';
// import 'package:trading_app/features/navbar/wishlist/model/wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';
// import 'package:trading_app/features/navbar/wishlist/websocket/nfo_watchlist_ws.dart';
// import 'package:trading_app/features/navbar/wishlist/widgets/search_widget.dart';

// import '../../../../home/nse-future/models/nfo_symbol_param.dart';
// import 'package:trading_app/features/navbar/home/nse-future/page/nse_future.dart';
// import 'package:trading_app/features/navbar/wishlist/widgets/search_widget.dart';

// class NfoWishlist2 extends StatefulWidget {
//   const NfoWishlist2({super.key});

//   @override
//   State<NfoWishlist2> createState() => _NfoWishlist2State();
// }

// class _NfoWishlist2State extends State<NfoWishlist2> {
//   late final NFOWatchListWebSocketService _socket;
//   NFOWishlistEntity nfoWishlist = NFOWishlistEntity();
//   String? errorMessage;
//   bool _disposed = false;
//   final List<String> removingNfoItems = [];
//   List<NFOWatchList> _localNfoWatchlist = [];
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _initializeNfoWebSocket();
//     _setupAuthTimer();
//   }

//   void _initializeNfoWebSocket() {
//     _socket = NFOWatchListWebSocketService(
//       onNFODataReceived: (data) {
//         setState(() {
//           nfoWishlist = data;
//           _localNfoWatchlist = List<NFOWatchList>.from(data.nfoWatchlist ?? []);
//           errorMessage = null;
//         });
//       },
//       onError: (error) {
//         log('WebSocket Error: $error');
//         setState(() {
//           errorMessage = error;
//         });
//       },
//       onConnected: () {
//         log('WebSocket Connected');
//         setState(() {
//           errorMessage = null;
//         });
//       },
//       onDisconnected: () {
//         log('WebSocket Disconnected');
//         if (!_disposed) {
//           Future.microtask(() => _socket.connect());
//         }
//       },
//     );

//     Future.microtask(() {
//       if (!_disposed) {
//         _socket.connect();
//       }
//     });
//   }

//   void _setupAuthTimer() {
//     AuthService().checkUserValidation();
//     _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (_disposed || !mounted) {
//         timer.cancel();
//         return;
//       }
//       AuthService().checkUserValidation();
//     });
//   }

//   // void _safeSetState(VoidCallback fn) {
//   //   if (!_disposed && mounted) {
//   //     setState(fn);
//   //   }
//   // }

//   @override
//   void dispose() {
//     _disposed = true;
//     _timer.cancel();
//     _socket.disconnect();
//     super.dispose();
//   }

//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     final formatter = NumberFormat('#,##,##0.00');
//     return formatter.format(number);
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
//             onTap: () => context.pushNamed(NseFuture.routeName),
//           ),
//           nfoWishlist.status != 1
//               ? _buildErrorState()
//               : Expanded(child: _buildListView()),
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
//               _socket.connect();
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
//             onPressed: () => context.pushNamed(NseFuture.routeName),
//             child: const Text('Add Symbols'),
//           ),
//         ],
//       ),
//     );
//   }

//   //  WishlistRepository.symbolSorting(
//   //         param: SortListParam(
//   //           symbolKey: symbolKeys,
//   //           symbolOrder: orderNumbers,
//   //         ),
//   //       );

//   Widget _buildListView() {
//     return ListView.builder(
//       itemCount: nfoWishlist.nfoWatchlist?.length,
//       itemBuilder: (context, index) {
//         final item = nfoWishlist.nfoWatchlist![index];
//         return GestureDetector(
//           key: ValueKey(item.symbolKey),
//           onTap: () {
//             if (item.symbol != null) {
//               context.pushNamed(
//                 NseFutureSymbolPage.routeName,
//                 extra: SymbolScreenParams(
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

//   Widget _buildListItem(NFOWatchList item, int index) {
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
//           Divider(thickness: 1.5, color: Colors.grey.shade800),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemHeader(NFOWatchList item) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           flex: 3,
//           child: Text(
//             item.symbolName.toString().toUpperCase(),
//           ).textStyleH1(),
//         ),
//         Row(
//           children: [
//             BlinkingPriceText(
//               assetId: item.symbolKey.toString(),
//               text: "₹${_formatNumber(item.ohlc!.salePrice)}",
//               compareValue: double.parse(item.ohlc!.lastPrice.toString()),
//               currentValue: double.parse(item.ohlc!.salePrice.toString()),
//             ),
//             SizedBox(width: 20.w),
//             BlinkingPriceText(
//               assetId: item.symbol.toString(),
//               text: "₹${_formatNumber(item.ohlc!.buyPrice)}",
//               compareValue: double.parse(item.ohlc!.lastPrice.toString()),
//               currentValue: double.parse(item.ohlc!.buyPrice.toString()),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildItemControls(NFOWatchList item, int index) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(item.expiryDate ?? '').textStyleH2(),
//         IconButton(
//           onPressed: () => _removeItem(item, index),
//           icon: removingNfoItems.contains(item.symbolKey.toString())
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

//   Widget _buildItemFooter(NFOWatchList item) {
//     final isNegative = item.change.toString().contains('-');
//     final changeColor = isNegative ? Colors.red : const Color(0xFF00C853);

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

//   Future<void> _removeItem(NFOWatchList item, int index) async {
//     final symbolKey = item.symbolKey.toString();
//     if (!mounted) return;

//     setState(() => removingNfoItems.add(symbolKey));

//     try {
//       final success = await WishlistRepository.removeWatchListSymbols(
//         category: 'NFO',
//         symbolKey: symbolKey,
//       );
//       if (!mounted) return;

//       if (success && !_disposed) {
//         setState(() {
//           _localNfoWatchlist.removeAt(index);
//           nfoWishlist.nfoWatchlist?.removeAt(index);
//         });
//       }
//     } catch (error) {
//       log(error.toString());
//     } finally {
//       if (!mounted) return;
//       setState(() => removingNfoItems.remove(symbolKey));
//     }
//   }
// }
