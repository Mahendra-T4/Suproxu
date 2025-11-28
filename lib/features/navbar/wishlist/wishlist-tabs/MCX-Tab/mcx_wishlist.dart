// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/extensions/textstyle.dart';
// import 'package:trading_app/features/navbar/home/mcx/mcx.dart';
// import 'package:trading_app/features/navbar/home/mcx/mcx_stock_list_panel.dart';
// import 'package:trading_app/features/navbar/home/mcx/page/mcx_home.dart';
// import 'package:trading_app/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';
// import 'package:trading_app/features/navbar/wishlist/widgets/search_widget.dart';
// import 'package:trading_app/features/navbar/wishlist/wishlist-tabs/MCX-Tab/service/mcx_watchlist_helper.dart';

// class MCXWishListPanel extends StatefulWidget {
//   const MCXWishListPanel({
//     super.key,
//   });

//   static const String routeName = '/mcx-wishlist-panel';

//   @override
//   State<MCXWishListPanel> createState() => _MCXWatchListState();
// }

// class _MCXWatchListState extends State<MCXWishListPanel>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();

//   List<MCXWatchlist> _localWatchlist = [];
//   List<String> removingItems = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 5, vsync: this);
//     _searchFocusNode.addListener(() {
//       if (!_searchFocusNode.hasFocus) {
//         setState(() => searchController.clear());
//       }
//     });

//     // Remove unnecessary timer
//     // AuthService().checkUserValidation(); // Call only when needed
//   }

//   @override
//   void dispose() {
//     _searchFocusNode.dispose();
//     _tabController.dispose();
//     searchController.dispose();
//     super.dispose();
//   }

//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     return NumberFormat('#,##,##0.00').format(number);
//   }

//   bool isMCX = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kWhiteColor,
//       body: Column(
//         children: [
//           SearchWidget(
//             hint: 'Search & Add',
//             isReadOnly: true,
//             onTap: () => context.pushNamed(McxHome.routeName),
//           ),
//           const McxWatchlistHelper()
//           // state.data!.status == 1
//           //     ? Expanded(
//           //         child: _localWatchlist.isEmpty
//           //             ? const Center(child: Text('Your wishlist is empty'))
//           //             : ReorderableListView.builder(
//           //                 itemCount: _localWatchlist.length,
//           //                 onReorder: (oldIndex, newIndex) async {
//           //                   setState(() {
//           //                     if (newIndex > oldIndex) newIndex--;
//           //                     final item = _localWatchlist.removeAt(oldIndex);
//           //                     _localWatchlist.insert(newIndex, item);
//           //                   });

//           //                   final symbolKeys = _localWatchlist
//           //                       .map((e) => e.symbolKey.toString())
//           //                       .join(',');
//           //                   final orderNumbers = List.generate(
//           //                       _localWatchlist.length,
//           //                       (i) => (i + 1).toString()).join(',');

//           //                   await WishlistRepository.symbolSorting(
//           //                     param: SortListParam(
//           //                       symbolKey: symbolKeys,
//           //                       symbolOrder: orderNumbers,
//           //                     ),
//           //                   );
//           //                 },
//           //                 buildDefaultDragHandles: true,
//           //                 itemBuilder: (context, index) {
//           //                   final item = _localWatchlist[index];
//           //                   final isRemoving =
//           //                       removingItems.contains(item.symbolKey);

//           //                   return GestureDetector(
//           //                     key: ValueKey(item.symbolKey),
//           //                     onTap: () {
//           //                       if (item.symbol != null) {
//           //                         context.pushNamed(
//           //                           MCXSymbolRecordPage.routeName,
//           //                           extra: MCXSymbolParams(
//           //                             symbol: item.symbol.toString(),
//           //                             index: index,
//           //                             symbolKey: item.symbolKey.toString(),
//           //                           ),
//           //                         );
//           //                       }
//           //                     },
//           //                     child: Container(
//           //                       margin: const EdgeInsets.symmetric(
//           //                           horizontal: 10, vertical: 4),
//           //                       decoration: BoxDecoration(
//           //                         color: Colors.white,
//           //                         borderRadius: BorderRadius.circular(12),
//           //                         boxShadow: [
//           //                           BoxShadow(
//           //                             color: Colors.grey.withOpacity(0.1),
//           //                             blurRadius: 4,
//           //                             offset: const Offset(0, 2),
//           //                           ),
//           //                         ],
//           //                       ),
//           //                       child: Column(
//           //                         children: [
//           //                           Padding(
//           //                             padding: const EdgeInsets.all(12),
//           //                             child: Row(
//           //                               mainAxisAlignment:
//           //                                   MainAxisAlignment.spaceBetween,
//           //                               children: [
//           //                                 Expanded(
//           //                                   flex: 3,
//           //                                   child: Text(
//           //                                     item.symbolName ?? '',
//           //                                     style: const TextStyle(
//           //                                         fontWeight: FontWeight.bold),
//           //                                     overflow: TextOverflow.ellipsis,
//           //                                   ),
//           //                                 ),
//           //                                 Row(
//           //                                   children: [
//           //                                     BlinkingPriceText(
//           //                                       assetId:
//           //                                           item.symbolKey.toString(),
//           //                                       text:
//           //                                           "₹${_formatNumber(item.ohlc?.salePrice)}",
//           //                                       compareValue:
//           //                                           item.ohlc?.lastPrice,
//           //                                       currentValue:
//           //                                           item.ohlc?.salePrice,
//           //                                     ),
//           //                                     SizedBox(width: 10.w),
//           //                                     BlinkingPriceText(
//           //                                       assetId:
//           //                                           item.symbolName.toString(),
//           //                                       text:
//           //                                           "₹${_formatNumber(item.ohlc?.buyPrice)}",
//           //                                       compareValue:
//           //                                           item.ohlc?.lastPrice,
//           //                                       currentValue:
//           //                                           item.ohlc?.buyPrice,
//           //                                     ),
//           //                                   ],
//           //                                 ),
//           //                               ],
//           //                             ),
//           //                           ),
//           //                           Padding(
//           //                             padding: const EdgeInsets.symmetric(
//           //                                 horizontal: 12),
//           //                             child: Row(
//           //                               mainAxisAlignment:
//           //                                   MainAxisAlignment.spaceBetween,
//           //                               children: [
//           //                                 Text(item.expiryDate ?? '',
//           //                                     style: const TextStyle(
//           //                                         fontSize: 12)),
//           //                                 IconButton(
//           //                                   onPressed: isRemoving
//           //                                       ? null
//           //                                       : () =>
//           //                                           _removeItem(item, index),
//           //                                   icon: isRemoving
//           //                                       ? const SizedBox(
//           //                                           width: 20,
//           //                                           height: 20,
//           //                                           child:
//           //                                               CircularProgressIndicator(
//           //                                                   strokeWidth: 2),
//           //                                         )
//           //                                       : SvgPicture.asset(
//           //                                           Assets
//           //                                               .assetsImagesSupertradeRemoveWishlistIcon,
//           //                                           height: 28,
//           //                                         ),
//           //                                 ),
//           //                               ],
//           //                             ),
//           //                           ),
//           //                           Padding(
//           //                             padding: const EdgeInsets.symmetric(
//           //                                 horizontal: 12, vertical: 8),
//           //                             child: Row(
//           //                               mainAxisAlignment:
//           //                                   MainAxisAlignment.spaceBetween,
//           //                               children: [
//           //                                 _buildChangeRow(item.change),
//           //                                 _buildLTPRow(item.ohlc?.lastPrice),
//           //                                 _buildHighRow(item.ohlc?.high),
//           //                                 _buildLowRow(item.ohlc?.low),
//           //                               ],
//           //                             ),
//           //                           ),
//           //                           const Divider(height: 1, thickness: 1),
//           //                         ],
//           //                       ),
//           //                     ),
//           //                   );
//           //                 },
//           //               ),
//           //       )
//           //     : Text(state.data!.message.toString()),
//         ],
//       ),
//     );
//   }

//   Widget _buildChangeRow(dynamic change) {
//     final isNegative = change.toString().contains('-');
//     return Row(
//       children: [
//         Text("Chg: ",
//             style: TextStyle(
//                 color: isNegative ? Colors.red : Colors.green,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700)),
//         Text(_formatNumber(change),
//             style: TextStyle(
//                 color: isNegative ? Colors.red : Colors.green,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700)),
//       ],
//     );
//   }

//   Widget _buildLTPRow(dynamic value) => _buildLabelValue("LTP", value);
//   Widget _buildHighRow(dynamic value) => _buildLabelValue("H", value);
//   Widget _buildLowRow(dynamic value) => _buildLabelValue("L", value);

//   Widget _buildLabelValue(String label, dynamic value) {
//     return Row(
//       children: [
//         Text("$label: ").textStyleH3(),
//         Text(_formatNumber(value)).textStyleH3(),
//       ],
//     );
//   }

//   Future<void> _removeItem(MCXWatchlist item, int index) async {
//     final symbolKey = item.symbolKey.toString();
//     setState(() => removingItems.add(symbolKey));

//     try {
//       final success = await WishlistRepository.removeWatchListSymbols(
//         category: 'MCX',
//         symbolKey: symbolKey,
//       );

//       if (success && mounted) {
//         setState(() {
//           _localWatchlist.removeAt(index);
//           removingItems.remove(symbolKey);
//         });
//       } else {
//         _showSnackBar('Failed to remove item');
//       }
//     } catch (e) {
//       _showSnackBar('Error: $e');
//     } finally {
//       if (mounted) {
//         setState(() => removingItems.remove(symbolKey));
//       }
//     }
//   }

//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message), backgroundColor: Colors.red),
//       );
//     }
//   }
// }
