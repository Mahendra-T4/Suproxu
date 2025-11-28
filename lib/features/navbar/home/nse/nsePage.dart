// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/extensions/color_ext.dart';
// import 'package:trading_app/core/responsive/responsive.dart';
// import 'package:trading_app/core/service/connectivity/connectivity_service.dart';
// import 'package:trading_app/core/service/page/not_connected.dart';
// import 'package:trading_app/features/navbar/home/model/nse_enity.dart';
// import 'package:trading_app/features/navbar/home/nse/nseSymbolScreen.dart';
// import 'package:trading_app/features/navbar/home/repository/trade_repository.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';

// class Nsescreen extends StatefulWidget {
//   const Nsescreen({super.key});

//   @override
//   State<Nsescreen> createState() => _NsescreenState();
// }

// class _NsescreenState extends State<Nsescreen> {
//   final StreamController<List<RecordNSE>> _streamController =
//       StreamController<List<RecordNSE>>.broadcast();
//   late Timer _dataTimer;
//   List<RecordNSE> records = [];
//   List<RecordNSE> filteredRecords = [];
//   TextEditingController searchController = TextEditingController();
//   bool isMarketOpen = true;
//   bool isSearch = false;

//   final _searchDebouncer = Debouncer(milliseconds: 300);
//   final FocusNode _searchFocusNode = FocusNode();
//   bool _showClearButton = false;
//   String _lastQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchData(); // Initial fetch
//     _dataTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
//       _fetchData();
//       _checkMarketStatus();
//     }); // Reduced frequency
//     _checkMarketStatus();
//   }

//   Future<void> _fetchData() async {
//     try {
//       final nseData = await TradeRepository().nseTradeDataLoader();
//       if (!_streamController.isClosed) {
//         final newRecords = nseData.response ?? [];
//         if (_recordsHaveChanged(newRecords)) {
//           records = newRecords;
//           if (_lastQuery.isEmpty) {
//             filteredRecords = records; // Update filtered only if no search
//           }
//           _streamController.add(records);
//         }
//       }
//     } catch (error) {
//       log("Error fetching data: $error");
//       // if (!_streamController.isClosed) {
//       //   _streamController.addError("Error fetching data: $error");
//       // }
//     }
//   }

//   bool _recordsHaveChanged(List<RecordNSE> newRecords) {
//     if (newRecords.length != records.length) return true;
//     for (int i = 0; i < newRecords.length; i++) {
//       if (newRecords[i].symbolKey != records[i].symbolKey ||
//           newRecords[i].ohlcNSE?.lastPrice != records[i].ohlcNSE?.lastPrice) {
//         return true; // Check key fields for changes
//       }
//     }
//     return false;
//   }

//   void _checkMarketStatus() {
//     final now = DateTime.now();
//     final marketOpenTime =
//         DateTime(now.year, now.month, now.day, 9, 15); // 9:15 AM
//     final marketCloseTime =
//         DateTime(now.year, now.month, now.day, 15, 30); // 3:30 PM

//     // Check if current time is within market hours
//     final newMarketStatus = now.isAfter(marketOpenTime) &&
//         now.isBefore(marketCloseTime) &&
//         now.weekday != DateTime.saturday &&
//         now.weekday != DateTime.sunday;

//     if (isMarketOpen != newMarketStatus) {
//       setState(() {
//         isMarketOpen = newMarketStatus;
//       });
//     }
//   }

//   List<RecordNSE> _filterRecords(String query) {
//     if (query.isEmpty) return records;
//     query = query.toLowerCase();
//     return records.where((record) {
//       final symbolName = record.symbolName?.toLowerCase() ?? '';
//       final ohlc = record.ohlcNSE;
//       final lastPrice = ohlc?.lastPrice?.toString().toLowerCase() ?? '';
//       final high = ohlc?.high?.toString().toLowerCase() ?? '';
//       final low = ohlc?.low?.toString().toLowerCase() ?? '';
//       final priceChange = (ohlc?.lastPrice ?? 0) - (ohlc?.open ?? 0);
//       final priceChangePercent = ohlc?.open != 0
//           ? ((priceChange / (ohlc?.open ?? 1)) * 100).toString().toLowerCase()
//           : '0';
//       return symbolName.contains(query) ||
//           lastPrice.contains(query) ||
//           high.contains(query) ||
//           low.contains(query) ||
//           priceChangePercent.contains(query);
//     }).toList();
//   }

//   @override
//   void dispose() {
//     _dataTimer.cancel(); // Cancel timer to prevent leaks
//     _streamController.close();
//     _searchDebouncer.dispose();
//     _searchFocusNode.dispose();
//     searchController.dispose();
//     super.dispose();
//   }

//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     return NumberFormat('#,##,##0.00').format(number);
//   }

//   Color _getPriceChangeColor(double? change) {
//     if (change == null) return Colors.grey;
//     return change >= 0 ? const Color(0xFF00C853) : const Color(0xFFFF3D00);
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     final now = DateTime.now();
//     final timeString = DateFormat('HH:mm:ss').format(now);
//     final todayDate = DateFormat('dd MMM').format(now);

//     return  Scaffold(
//             backgroundColor: const Color(0xFF1C1C1E),
//             appBar: AppBar(
//               backgroundColor: const Color(0xFF2C2C2E),
//               elevation: 0,
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'NSE Market',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: isMarketOpen
//                               ? const Color(0xFF00C853)
//                               : const Color(0xFFFF3D00),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           isMarketOpen ? 'OPEN' : 'CLOSED',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => setState(() => isSearch = !isSearch),
//                         icon: Container(
//                           height: 30,
//                           width: 30,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(Icons.search, color: Colors.black),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             body: Column(
//               children: [
//                 if (isSearch) _buildSearchBar(),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: StreamBuilder<List<RecordNSE>>(
//                     stream: _streamController.stream,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(
//                           child: CircularProgressIndicator(
//                             color: Color(0xFF00C853),
//                           ),
//                         );
//                       } else if (snapshot.hasError) {
//                         log(snapshot.error.toString());
//                         return Center(
//                           child: Text(
//                             snapshot.error.toString(),
//                             style: const TextStyle(color: Colors.white70),
//                           ),
//                         );
//                       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                         return const Center(
//                           child: Text(
//                             "No data available",
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                         );
//                       }

//                       final displayRecords =
//                           isSearch ? filteredRecords : snapshot.data;

//                       return displayRecords != null
//                           ? ListView.builder(
//                               itemCount: displayRecords.length,
//                               itemBuilder: (context, index) {
//                                 final record = displayRecords[index];
//                                 final ohlc = record.ohlcNSE;
//                                 final buyPrice = double.tryParse(
//                                         ohlc?.buyPrice?.toString() ?? '0') ??
//                                     0.0;
//                                 final salePrice = double.tryParse(
//                                         ohlc?.salePrice?.toString() ?? '0') ??
//                                     0.0;
//                                 final priceChange = buyPrice - salePrice;
//                                 final priceChangePercent = buyPrice != 0
//                                     ? (priceChange / buyPrice) * 100
//                                     : 0.0;

//                                 return _buildListItem(
//                                     record, index, snapshot.data!, todayDate);
//                               },
//                             )
//                           : Padding(
//                               padding: EdgeInsets.only(
//                                   top: MediaQuery.sizeOf(context).height / 3),
//                               child: const Center(
//                                 child: Text(
//                                   'NO Data Found',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//   }

//   Widget _buildListItem(RecordNSE record, int index,
//       List<RecordNSE> snapshotData, String todayDate) {
//     return GestureDetector(
//       onTap: () {
//         if (record.symbolName != null) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => NseSymbols(
//                 symbol: record.symbolName!,
//                 index: index,
//                 symbolKey: record.symbolKey.toString(),
//               ),
//             ),
//           );
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFF2C2C2E),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         record.symbolName?.toString() ?? 'N/A',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       // Text(
//                       //   record.currentTime?.toString() ?? todayDate,
//                       //   style:
//                       //       const TextStyle(color: Colors.grey, fontSize: 12),
//                       // ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(3),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(4),
//                            color: Colors.white.blink(
//                                                   baseValue: record.ohlcNSE?.lastPrice,
//                                                   compValue: data
//                                                       .response![index]
//                                                       .ohlc!
//                                                       .salePrice),
//                           color: colorBlinkExtension(
//                               baseValue: record.ohlcNSE?.lastPrice,
//                               compValue: record.ohlcNSE?.open)),
//                       child: Text(
//                         '₹${_formatNumber(record.ohlcNSE?.lastPrice)}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: Responsive.screenHeight(context) * 0.01),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(record.expiryDate ?? '',
//                     style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
//                 Row(
//                   children: [
//                     const Text(
//                       'LotSize : ',
//                       style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           color: Colors.white,
//                           fontSize: 14),
//                     ),
//                     Text(
//                       record.lotSize.toString(),
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           fontSize: 14),
//                     )
//                   ],
//                 )
//               ],
//             ),
//             SizedBox(height: 8.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     const Text(
//                       ' H : ',
//                       style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w400,
//                           color: Colors.white),
//                     ),
//                     Text(
//                       '₹${_formatNumber(record.ohlcNSE?.high)}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text(
//                       ' L : ',
//                       style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w400,
//                           color: Colors.white),
//                     ),
//                     Text(
//                       '₹${_formatNumber(record.ohlcNSE?.low)}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 InkWell(
//                   onTap: () async {
//                     setState(() {
//                       WishlistRepository.addToWishlist(
//                         category: 'NSE',
//                         symbolKey: record.symbolKey.toString(),
//                         context: context,
//                       );
//                       record.watchlist =
//                           record.watchlist == 1 ? 1 : 1; // Toggle locally
//                     });
//                   },
//                   child: record.watchlist == 1
//                       ? Image.asset(
//                           Assets.assetsImagesSupertradeRomoveWishlist,
//                           scale: 19,
//                           color: Colors.deepPurpleAccent,
//                         )
//                       : Image.asset(
//                           Assets.assetsImagesSuperTradeAddWishlist,
//                           scale: 19,
//                           color: Colors.white,
//                         ),
//                 ),
//               ],
//             ),
//             // Row(
//             //   children: [
//             //     const Text(
//             //       'LotSize : ',
//             //       style: TextStyle(
//             //           fontWeight: FontWeight.w400,
//             //           color: Colors.white,
//             //           fontSize: 13),
//             //     ),
//             //     Text(
//             //       record.lotSize.toString(),
//             //       style: const TextStyle(
//             //           fontWeight: FontWeight.bold,
//             //           color: Colors.white,
//             //           fontSize: 14),
//             //     )
//             //   ],
//             // )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C2C2E),
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: searchController,
//         focusNode: _searchFocusNode,
//         style: TextStyle(color: Colors.white, fontSize: 16.sp),
//         onChanged: (query) {
//           _searchDebouncer.run(() {
//             if (_lastQuery != query) {
//               setState(() {
//                 _lastQuery = query;
//                 _showClearButton = query.isNotEmpty;
//                 filteredRecords = _filterRecords(query);
//               });
//             }
//           });
//         },
//         decoration: InputDecoration(
//           hintText: 'Search by symbol or price...',
//           hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
//           prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20.r),
//           suffixIcon: _showClearButton
//               ? IconButton(
//                   icon: Icon(Icons.clear, color: Colors.grey[400], size: 20.r),
//                   onPressed: () {
//                     searchController.clear();
//                     setState(() {
//                       filteredRecords = records;
//                       _showClearButton = false;
//                     });
//                     _searchFocusNode.unfocus();
//                   },
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding:
//               EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//         ),
//       ),
//     );
//   }

//   Color contColor(dynamic open, dynamic last) {
//     final value = (open ?? 0) - (last ?? 0);
//     return value >= 0 ? Colors.green : Colors.red;
//   }
// }

// class Debouncer {
//   final int milliseconds;
//   Timer? _timer;

//   Debouncer({required this.milliseconds});

//   void run(VoidCallback action) {
//     _timer?.cancel();
//     _timer = Timer(Duration(milliseconds: milliseconds), action);
//   }

//   void dispose() {
//     _timer?.cancel();
//   }
// }
