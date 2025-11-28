// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/extensions/color_ext.dart';
// import 'package:trading_app/core/service/connectivity/connectivity_service.dart';
// import 'package:trading_app/core/service/page/not_connected.dart';
// import 'package:trading_app/features/navbar/home/nse/nseSymbolScreen.dart';
// import 'package:trading_app/features/navbar/wishlist/model/nse_wishlist_entity.dart';
// import 'package:trading_app/features/navbar/wishlist/repositories/wishlist_repo.dart';

// class NseWatchlist extends StatefulWidget {
//   const NseWatchlist({super.key});

//   @override
//   State<NseWatchlist> createState() => _NseWatchlistState();
// }

// class _NseWatchlistState extends State<NseWatchlist> {
//   final StreamController<List<NSEWatchlist>> _streamController =
//       StreamController<List<NSEWatchlist>>();
//   List<String> removingItems = [];

//   final StreamController<DateTime> timeStreamer = StreamController<DateTime>();
//   late Timer _timer;

//   @override
//   List<NSEWatchlist> records = [];
//   @override
//   List<NSEWatchlist> filteredRecords = [];
//   @override
//   TextEditingController searchController = TextEditingController();
//   @override
//   bool isMarketOpen = true; // This should be fetched from your backend
//   bool isSearch = false;

//   final _searchDebouncer = Debouncer(milliseconds: 300);
//   final FocusNode _searchFocusNode = FocusNode();
//   bool _showClearButton = false;
//   String _lastQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
//       _fetchData();
//       _checkMarketStatus();
//     });
//     _checkMarketStatus();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     try {
//       final nseData = await WishlistRepository.fatchWishlistForNSE();
//       if (!_streamController.isClosed) {
//         setState(() {
//           records = nseData.nseWishlist ?? [];
//           // Initially set filteredRecords to all records
//           filteredRecords = records;
//         });
//         _streamController.add(records);
//       }
//     } catch (error) {
//       if (!_streamController.isClosed) {
//         _streamController.addError("Error fetching data: $error");
//       }
//     }
//   }

//   _checkMarketStatus() {
//     final now = DateTime.now();
//     if (!timeStreamer.isClosed) {}
//     final isMarketClosingTime = DateTime(now.year, now.month, now.day, 15, 30);
//     setState(() {
//       isMarketOpen = now.isBefore(isMarketClosingTime);
//     });
//   }

//   List<NSEWatchlist> _filterRecords(String query) {
//     if (query.isEmpty) return records;

//     query = query.toLowerCase();
//     return records.where((record) {
//       final symbolName = record.symbolName?.toLowerCase() ?? '';
//       final ohlc = record.ohlc;
//       final lastPrice = ohlc?.lastPrice?.toString().toLowerCase() ?? '';
//       final high = ohlc?.high?.toString().toLowerCase() ?? '';
//       final low = ohlc?.low?.toString().toLowerCase() ?? '';

//       // Calculate price change for percentage search
//       final priceChange = (ohlc?.lastPrice ?? 0) - (ohlc?.open ?? 0);
//       final priceChangePercent = ohlc?.open != 0
//           ? ((priceChange / (ohlc?.open ?? 1)) * 100).toString().toLowerCase()
//           : '0';

//       return symbolName.contains(query.toLowerCase()) ||
//           lastPrice.contains(query.toLowerCase()) ||
//           high.contains(query.toLowerCase()) ||
//           low.contains(query.toLowerCase()) ||
//           priceChangePercent.contains(query.toLowerCase());
//     }).toList();
//   }

//   // void _onSearchChanged(String query) {
//   //   setState(() {
//   //     filteredRecords = _filterRecords(query.toLowerCase());
//   //   });
//   // }

//   @override
//   void dispose() {
//     _searchDebouncer.dispose();
//     _searchFocusNode.dispose();
//     _streamController.close();
//     searchController.dispose();
//     super.dispose();
//   }

//   String _formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     final formatter = NumberFormat('#,##,##0.00');
//     return formatter.format(number);
//   }

//   Color _getPriceChangeColor(double? change) {
//     if (change == null) return Colors.grey;
//     return change >= 0 ? const Color(0xFF00C853) : const Color(0xFFFF3D00);
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     final now = DateTime.now();
//     final toDate = DateTime.now().day;
//     final timeString = DateFormat('HH:mm:ss').format(now);
//     final todayDate = DateFormat('dd MMM').format(now);

//     return  Scaffold(
//             backgroundColor: scaffoldBGColor,
//             appBar: AppBar(
//               backgroundColor: appBarColor,
//               elevation: 0,
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'NSE WatchList',
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
//                       // IconButton(
//                       //     onPressed: () {
//                       //       setState(() {
//                       //         isSearch = !isSearch;
//                       //       });
//                       //     },
//                       //     icon: Container(
//                       //       height: 30,
//                       //       width: 30,
//                       //       decoration: const BoxDecoration(
//                       //           color: Colors.white, shape: BoxShape.circle),
//                       //       child: const Icon(
//                       //         Icons.search,
//                       //         color: Colors.black,
//                       //       ),
//                       //     ))
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             body: Column(
//               children: [
//                 if (isSearch) _buildSearchBar(),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Expanded(
//                   child: StreamBuilder<List<NSEWatchlist>>(
//                     stream: _streamController.stream,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(
//                           child: CircularProgressIndicator(
//                             color: Color(0xFF00C853),
//                           ),
//                         );
//                       } else if (snapshot.hasError) {
//                         log("Error: ${snapshot.error}");
//                         return const Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.error_outline,
//                                 color: Color(0xFFFF3D00),
//                                 size: 48,
//                               ),
//                               SizedBox(height: 16),
//                               Text(
//                                 "Ops! something went wrong",
//                                 style: TextStyle(color: Colors.white70),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                       // else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       //   return const Center(
//                       //     child: Text(
//                       //       "No data available",
//                       //       style: TextStyle(color: Colors.white70),
//                       //     ),
//                       //   );
//                       // }

//                       final displayRecords =
//                           isSearch ? filteredRecords : records;

//                       return displayRecords.isNotEmpty
//                           ? ListView.builder(
//                               itemCount: displayRecords.length,
//                               itemBuilder: (context, index) {
//                                 var record = displayRecords[index];
//                                 final ohlc = displayRecords[index].ohlc;

//                                 // Parse prices as double
//                                 final buyPrice = double.tryParse(
//                                         ohlc?.buyPrice?.toString() ?? '0') ??
//                                     0.0;
//                                 final salePrice = double.tryParse(
//                                         ohlc?.salePrice?.toString() ?? '0') ??
//                                     0.0;

//                                 // Calculate price change
//                                 final priceChange = buyPrice - salePrice;
//                                 final priceChangePercent = buyPrice != 0
//                                     ? (priceChange / buyPrice) * 100
//                                     : 0.0;

//                                 bool isHovered = false;

//                                 return GestureDetector(
//                                   onTap: () {
//                                     if (record.symbolName != null) {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => NseSymbols(
//                                             symbol: record.symbolName!,
//                                             index: index,
//                                             symbolKey:
//                                                 record.symbolKey.toString(),
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                   },
//                                   child: Container(
//                                     margin: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 4,
//                                     ),
//                                     padding: const EdgeInsets.all(16),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFF2C2C2E),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Stack(
//                                       children: [
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Expanded(
//                                                   flex: 3,
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         displayRecords[index]
//                                                                 .symbolName
//                                                                 ?.toString() ??
//                                                             'N/A',
//                                                         style: const TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                       ),
//                                                       const SizedBox(height: 4),
//                                                       Text(
//                                                         displayRecords[index]
//                                                                 .currentTime
//                                                                 ?.toString() ??
//                                                             todayDate,
//                                                         style: const TextStyle(
//                                                           color: Colors.grey,
//                                                           fontSize: 12,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Column(
//                                                   children: [
//                                                     Container(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               3),
//                                                       decoration: BoxDecoration(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(4),
//                                                           color: Colors.white.blink(
//                                                               baseValue:
//                                                                   ohlc?.open,
//                                                               compValue: ohlc
//                                                                   ?.lastPrice)),
//                                                       child: Text(
//                                                         '₹${_formatNumber(ohlc?.lastPrice)}',
//                                                         style: const TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     const Text(
//                                                       '',
//                                                       style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 12,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(
//                                               height: 8.h,
//                                             ),
//                                             Row(
//                                               spacing: 5,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     const Text(
//                                                       ' H : ',
//                                                       style: TextStyle(
//                                                           fontSize: 13,
//                                                           fontWeight:
//                                                               FontWeight.w400,
//                                                           color: Colors.white),
//                                                     ),
//                                                     Container(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               3),
//                                                       decoration: BoxDecoration(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(4),
//                                                         color: Colors.green
//                                                             .withOpacity(.2),
//                                                       ),
//                                                       child: Text(
//                                                         '₹${_formatNumber(ohlc?.high)}',
//                                                         style: const TextStyle(
//                                                           color: Colors.green,
//                                                           fontSize: 14,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     const Text(
//                                                       ' L : ',
//                                                       style: TextStyle(
//                                                           fontSize: 13,
//                                                           fontWeight:
//                                                               FontWeight.w400,
//                                                           color: Colors.white),
//                                                     ),
//                                                     Container(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               3),
//                                                       decoration: BoxDecoration(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(4),
//                                                         color:
//                                                             _getPriceChangeColor(
//                                                                     -priceChange)
//                                                                 .withOpacity(
//                                                                     .1),
//                                                       ),
//                                                       child: Text(
//                                                         '₹${_formatNumber(ohlc?.low)}',
//                                                         style: TextStyle(
//                                                           color:
//                                                               _getPriceChangeColor(
//                                                                   -priceChange),
//                                                           fontSize: 14,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 const SizedBox(
//                                                   width: 8,
//                                                 ),
//                                                 IconButton(
//                                                   onPressed: () async {
//                                                     final removedItem =
//                                                         displayRecords[index];
//                                                     final removedIndex = index;
//                                                     final symbolKey =
//                                                         removedItem.symbolKey
//                                                             .toString();

//                                                     // Add to loading state
//                                                     setState(() {
//                                                       displayRecords
//                                                           .removeAt(index);
//                                                       removingItems
//                                                           .add(symbolKey);
//                                                     });

//                                                     try {
//                                                       await WishlistRepository
//                                                           .removeWatchListSymbols(
//                                                         category: 'NSE',
//                                                         symbolKey: symbolKey,
//                                                       );
//                                                     } catch (error) {
//                                                       setState(() {
//                                                         displayRecords.insert(
//                                                             removedIndex,
//                                                             removedItem);
//                                                       });
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                         SnackBar(
//                                                           content: Text(
//                                                               'Failed to remove item: $error'),
//                                                           backgroundColor:
//                                                               Colors.red,
//                                                         ),
//                                                       );
//                                                     } finally {
//                                                       setState(() {
//                                                         removingItems
//                                                             .remove(symbolKey);
//                                                       });
//                                                     }
//                                                   },
//                                                   icon: removingItems.contains(
//                                                           displayRecords[index]
//                                                               .symbolKey
//                                                               .toString())
//                                                       ? const CircularProgressIndicator(
//                                                           color: Colors.white,
//                                                           strokeWidth: 2,
//                                                         )
//                                                       : Image.asset(
//                                                           Assets
//                                                               .assetsImagesSupertradeRomoveSymbol,
//                                                           scale: 17,
//                                                           color: Colors.white,
//                                                         ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             )
//                           : Padding(
//                               padding: EdgeInsets.only(
//                                   top: MediaQuery.sizeOf(context).width * .15),
//                               child: Center(
//                                 child: Text('Empty Watchlist',
//                                     style: TextStyle(
//                                         fontSize: 14.sp, color: Colors.white)),
//                               ),
//                             );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
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
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 16.sp,
//         ),
//         onChanged: (query) {
//           _searchDebouncer.run(() {
//             if (_lastQuery != query) {
//               setState(() {
//                 _lastQuery = query;
//                 _showClearButton = query.isNotEmpty;
//                 filteredRecords = _filterRecords(query.toLowerCase());
//               });
//             }
//           });
//         },
//         decoration: InputDecoration(
//           hintText: 'Search by symbol or price...',
//           hintStyle: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 14.sp,
//           ),
//           prefixIcon: Icon(
//             Icons.search,
//             color: Colors.grey[400],
//             size: 20.r,
//           ),
//           suffixIcon: _showClearButton
//               ? IconButton(
//                   icon: Icon(
//                     Icons.clear,
//                     color: Colors.grey[400],
//                     size: 20.r,
//                   ),
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
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 16.w,
//             vertical: 12.h,
//           ),
//         ),
//       ),
//     );
//   }

//   void _clearSearch() {
//     searchController.clear();
//     setState(() {
//       _showClearButton = false;
//       _lastQuery = '';
//       filteredRecords = records;
//     });
//     _searchFocusNode.unfocus();
//   }

//   Color contColor(dynamic open, dynamic last) {
//     final value = open - last;
//     if (value >= 0) {
//       return Colors.green;
//     } else {
//       return Colors.red;
//     }
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
