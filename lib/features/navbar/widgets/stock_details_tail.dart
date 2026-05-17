// import 'package:flutter/material.dart';
// import 'package:suproxu/core/constants/color.dart';
// import 'package:suproxu/core/extensions/color_blinker.dart';
// import 'package:suproxu/core/extensions/textstyle.dart';
// import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';

// class StockDetailsTail extends StatefulWidget {
//   const StockDetailsTail({super.key});

//   @override
//   State<StockDetailsTail> createState() => _StockDetailsTailState();
// }

// class _StockDetailsTailState extends State<StockDetailsTail> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
//       decoration: BoxDecoration(
//         color: kWhiteColor,
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
//         Expanded(flex: 3, child: Text(item.symbolName ?? '').textStyleH1()),
//         Row(
//           children: [
//             BlinkingPriceText(
//               assetId: item.symbolKey.toString(),
//               text: "₹${_formatNumber(item.ohlc!.salePrice.toString())}",
//               compareValue: item.ohlc!.lastPrice,
//               currentValue: item.ohlc!.salePrice,
//             ),
//             SizedBox(width: 10.w),
//             BlinkingPriceText(
//               assetId: item.symbolName.toString(),
//               text: "₹${_formatNumber(item.ohlc!.buyPrice.toString())}",
//               compareValue: item.ohlc!.lastPrice,
//               currentValue: item.ohlc!.buyPrice,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildItemControls(MCXWatchlist item, int index) {
//     // final date = item.expiryDate?.substring(0, 10);
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
//               : Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.green, width: 2),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   width: 20,
//                   height: 20,
//                   child: Icon(Icons.check, size: 16, color: Colors.green),
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
//                 fontFamily: FontFamily.globalFontFamily,
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
// }
