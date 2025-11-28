// import 'package:flutter/material.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/extensions/color_blinker.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/features/navbar/home/model/mcx_entity.dart';
// import 'package:trading_app/features/navbar/home/mcx/page/mcx_symbol.dart';
// import 'package:go_router/go_router.dart';

// class MCXListItem extends StatelessWidget {
//   final MCXDataEntity data;
//   final int index;
//   final VoidCallback onWishlistChanged;

//   const MCXListItem({
//     super.key,
//     required this.data,
//     required this.index,
//     required this.onWishlistChanged,
//   });

//   String _formatNumber(dynamic v) {
//     if (v == null) return '0.00';
//     if (v is double) return v.toStringAsFixed(2);
//     if (v is int) return v.toString();
//     return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final itemData = data.response![index];
//     return GestureDetector(
//       onTap: () {
//         if (itemData.symbol != null) {
//           context.pushNamed(
//             MCXSymbolRecordPage.routeName,
//             extra: MCXSymbolParams(
//               symbol: itemData.symbol.toString(),
//               index: index,
//               symbolKey: itemData.symbolKey.toString(),
//             ),
//           );
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         color: Colors.white,
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(
//                   width: MediaQuery.sizeOf(context).width / 4,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(itemData.symbolName ?? '').textStyleH1(),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         BlinkingPriceText(
//                           assetId: itemData.symbolKey,
//                           text: "₹${_formatNumber(itemData.ohlc?.salePrice)}",
//                           compareValue: itemData.ohlc?.lastPrice ?? 0.0,
//                           currentValue: itemData.ohlc?.salePrice ?? 0.0,
//                         ),
//                         const SizedBox(width: 8),
//                         BlinkingPriceText(
//                           assetId: itemData.symbolName,
//                           text: "₹${_formatNumber(itemData.ohlc?.buyPrice)}",
//                           compareValue: itemData.ohlc?.lastPrice ?? 0.0,
//                           currentValue: itemData.ohlc?.buyPrice ?? 0.0,
//                         ),
//                         const SizedBox(width: 8),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(itemData.expiryDate ?? ''),
//                   ],
//                 ),
//                 GestureDetector(
//                   onTap: onWishlistChanged,
//                   child: itemData.watchlist == 1
//                       ? Image.asset(Assets.assetsImagesSupertradeRomoveWishlist,
//                           scale: 19, color: Colors.deepPurpleAccent)
//                       : Image.asset(Assets.assetsImagesSuperTradeAddWishlist,
//                           scale: 19, color: Colors.grey[800]),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       "Chg: ",
//                       style: TextStyle(
//                         color: itemData.change.toString().contains('-')
//                             ? Colors.red
//                             : Colors.green,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       _formatNumber(itemData.change),
//                       style: TextStyle(
//                         color: itemData.change.toString().contains('-')
//                             ? Colors.red
//                             : Colors.green,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text("LTP: "),
//                     Text(
//                       _formatNumber(itemData.ohlc?.lastPrice),
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text("H: "),
//                     Text(
//                       _formatNumber(itemData.ohlc?.high),
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text("L: "),
//                     Text(
//                       _formatNumber(itemData.ohlc?.low),
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             Divider(thickness: 1.5, color: Colors.grey.shade800),
//           ],
//         ),
//       ),
//     );
//   }
// }
