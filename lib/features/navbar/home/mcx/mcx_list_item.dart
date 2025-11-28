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
// import 'package:trading_app/features/navbar/home/mcx/mcx_symbol.dart';
// import 'package:trading_app/features/navbar/home/model/mcx_entity.dart';
// import 'package:trading_app/features/navbar/home/providers/mcx_stock_list_provider.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';

// class MCXStockListPanel extends ConsumerStatefulWidget {
//   const MCXStockListPanel({super.key});

//   static const routeName = '/mcx-stock-list-panel';

//   @override
//   ConsumerState<MCXStockListPanel> createState() => _MCXStockListPanelState();
// }

// class _MCXStockListPanelState extends ConsumerState<MCXStockListPanel> {
//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     return NumberFormat('#,##,##0.00').format(number);
//   }

//   Timer? _debounceTimer;

//   @override
//   void initState() {
//     super.initState();
//     AuthService().checkUserValidation();
//   }

//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     super.dispose();
//   }

//   final TextEditingController searchController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     final mcxWishlistState = ref.watch(mcxDataProvider);

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: kWhiteColor,
//         body: Column(
//           children: [
//             const SizedBox(
//               height: 10,
//             ),
//             _buildSearchBar(context, ref),
//             mcxWishlistState.when(
//               data: (data) {
//                 return Expanded(
//                   child: ListView.builder(
//                     itemCount: data.status == 1 ? data.response!.length : 0,
//                     itemBuilder: (context, index) => GestureDetector(
//                       onTap: () {
//                         if (data.response![index].symbol != null) {
//                           GoRouter.of(context).pushNamed(
//                             MCXSymbolRecordPage.routeName,
//                             extra: MCXSymbolParams(
//                               symbol: data.response![index].symbol.toString(),
//                               index: index,
//                               symbolKey:
//                                   data.response![index].symbolKey.toString(),
//                               // params: null,
//                             ),
//                           );
//                         }
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: kWhiteColor,
//                           // borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 SizedBox(
//                                   width: MediaQuery.sizeOf(context).width / 4,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         data.response![index].symbolName ?? '',
//                                       ).textStyleH1(),
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
//                                           assetId:
//                                               data.response![index].symbolKey,
//                                           text:
//                                               "₹${_formatNumber(data.response![index].ohlc!.salePrice)}",
//                                           compareValue: data
//                                               .response![index].ohlc!.lastPrice,
//                                           currentValue: data
//                                               .response![index].ohlc!.salePrice,
//                                         ),
//                                         SizedBox(width: 10.w),
//                                         BlinkingPriceText(
//                                           assetId:
//                                               data.response![index].symbolName,
//                                           text:
//                                               "₹${_formatNumber(data.response![index].ohlc!.buyPrice)}",
//                                           compareValue: data
//                                               .response![index].ohlc!.lastPrice,
//                                           currentValue: data
//                                               .response![index].ohlc!.buyPrice,
//                                         ),
//                                         const SizedBox(width: 5),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       data.response![index].expiryDate ?? '',
//                                     ).textStyleH2(),
//                                   ],
//                                 ),
//                                 GestureDetector(
//                                   onTap: () async {
//                                     final success =
//                                         await WishlistRepository.addToWishlist(
//                                       category: 'MCX',
//                                       symbolKey: data.response![index].symbolKey
//                                           .toString(),
//                                       context: context,
//                                     );

//                                     if (success && context.mounted) {
//                                       // Trigger a refresh of the WebSocket data
//                                       ref.invalidate(mcxAllStocksProvider);
//                                     }
//                                   },
//                                   child: data.response![index].watchlist == 1
//                                       ? Image.asset(
//                                           Assets
//                                               .assetsImagesSupertradeRomoveWishlist,
//                                           scale: 19,
//                                           color: Colors.deepPurpleAccent)
//                                       : Image.asset(
//                                           Assets
//                                               .assetsImagesSuperTradeAddWishlist,
//                                           scale: 19,
//                                           color: Colors.grey[800]),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 6),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(
//                                       "Chg: ",
//                                       style: TextStyle(
//                                         color: data.response![index].change
//                                                 .toString()
//                                                 .contains('-')
//                                             ? Colors.red
//                                             : Colors.green,
//                                         fontSize: 11.5,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       _formatNumber(
//                                           data.response![index].change),
//                                       style: TextStyle(
//                                         color: data.response![index].change
//                                                 .toString()
//                                                 .contains('-')
//                                             ? Colors.red
//                                             : Colors.green,
//                                         fontSize: 11.5,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text("LTP: ").textStyleH3(),
//                                     Text(
//                                       _formatNumber(data
//                                           .response![index].ohlc!.lastPrice),
//                                       style: const TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 11.5,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text("H: ").textStyleH3(),
//                                     Text(
//                                       _formatNumber(
//                                           data.response![index].ohlc!.high),
//                                       style: const TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 11.5,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       "L: ",
//                                       style: TextStyle(
//                                         color: zBlack,
//                                         fontSize: 11.5,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(_formatNumber(
//                                             data.response![index].ohlc!.low))
//                                         .textStyleH3(),
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
//                   ),
//                 );
//               },
//               error: (error, stackTrace) {
//                 return Text('Error: $error');
//               },
//               loading: () => const CircularProgressIndicator.adaptive(),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10.w),
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
//               onChanged: (query) {
//                 if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
//                 _debounceTimer = Timer(const Duration(milliseconds: 300), () {
//                   // ref.read(searchQueryProvider.notifier).state = query;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search MCX Stocks...',
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
// }
