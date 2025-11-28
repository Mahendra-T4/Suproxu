// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/features/navbar/home/bloc/home_bloc.dart';
// import 'package:trading_app/features/navbar/home/model/nse_enity.dart';
// import 'package:trading_app/features/navbar/home/nse/nseSymbolScreen.dart';
// import 'package:trading_app/features/navbar/home/nse/nse_ui_builder.dart';
// import 'package:trading_app/features/navbar/home/repository/stock_repositorie.dart';
// import 'package:trading_app/features/navbar/home/repository/trade_repository.dart';
// import 'package:intl/intl.dart';

// class Nsescreen extends StatefulWidget {
//   const Nsescreen({super.key});

//   @override
//   State<Nsescreen> createState() => _NsescreenState();
// }

// class _NsescreenState extends NseUiBuilder {
//   final StreamController<List<RecordNSE>> _streamController =
//       StreamController<List<RecordNSE>>();

//   final StreamController<DateTime> timeStreamer = StreamController<DateTime>();
//   // late Timer _timer;
//   List<RecordNSE> records = [];
//   List<RecordNSE> filteredRecords = [];
//   TextEditingController searchController = TextEditingController();
//   bool isMarketOpen = true; // This should be fetched from your backend
//   bool isSearch = false;
//   @override
//   void initState() {
//     super.initState();
//     // _timer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchData());
//     _fetchData();
//     _checkMarketStatus();
//   }

//   Future<void> _fetchData() async {
//     try {
//       final nseData = await TradeRepository().nseTradeDataLoader();
//       if (!_streamController.isClosed) {
//         _streamController.add(nseData.response ?? []);
//         setState(() {
//           records = nseData.response ?? [];
//           filteredRecords = _filterRecords(searchController.text);
//         });
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

//   List<RecordNSE> _filterRecords(String query) {
//     return records
//         .where((record) =>
//             record.symbol?.toLowerCase().contains(query.toLowerCase()) ?? false)
//         .toList();
//   }

//   void _onSearchChanged(String query) {
//     setState(() {
//       filteredRecords = _filterRecords(query);
//     });
//   }

//   @override
//   void dispose() {
//     // _timer.cancel();
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

//     return Scaffold(
//       backgroundColor: const Color(0xFF1C1C1E),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2C2C2E),
//         elevation: 0,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'NSE Market',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Row(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: isMarketOpen
//                         ? const Color(0xFF00C853)
//                         : const Color(0xFFFF3D00),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     isMarketOpen ? 'OPEN' : 'CLOSED',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                     onPressed: () {
//                       setState(() {
//                         isSearch = !isSearch;
//                       });
//                     },
//                     icon: Container(
//                       height: 30,
//                       width: 30,
//                       decoration: const BoxDecoration(
//                           color: Colors.white, shape: BoxShape.circle),
//                       child: const Icon(
//                         Icons.search,
//                         color: Colors.black,
//                       ),
//                     ))
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           if (isSearch)
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: TextField(
//                 controller: searchController,
//                 onChanged: _onSearchChanged,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   hintText: 'Search symbols...',
//                   hintStyle: const TextStyle(color: Colors.grey),
//                   prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                   filled: true,
//                   fillColor: const Color(0xFF2C2C2E),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//           const SizedBox(
//             height: 10,
//           ),
//           Expanded(
//             child: StreamBuilder<List<RecordNSE>>(
//               stream: _streamController.stream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       color: Color(0xFF00C853),
//                     ),
//                   );
//                 } else if (snapshot.hasError) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.error_outline,
//                           color: Color(0xFFFF3D00),
//                           size: 48,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           "Error: ${snapshot.error}",
//                           style: const TextStyle(color: Colors.white70),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   );
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       "No data available",
//                       style: TextStyle(color: Colors.white70),
//                     ),
//                   );
//                 }

//                 filteredRecords = snapshot.data!;

//                 return ListView.builder(
//                   itemCount: filteredRecords.length,
//                   itemBuilder: (context, index) {
//                     var record = filteredRecords[index];
//                     final ohlc = record.ohlcNSE;

//                     // Parse prices as double
//                     final buyPrice =
//                         double.tryParse(ohlc?.buyPrice?.toString() ?? '0') ??
//                             0.0;
//                     final salePrice =
//                         double.tryParse(ohlc?.salePrice?.toString() ?? '0') ??
//                             0.0;

//                     // Calculate price change
//                     final priceChange = buyPrice - salePrice;
//                     final priceChangePercent =
//                         buyPrice != 0 ? (priceChange / buyPrice) * 100 : 0.0;

//                     return GestureDetector(
//                       onTap: () {
//                         if (record.symbol != null) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => NseSymbols(
//                                 symbol: record.symbol!,
//                                 index: index,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 4,
//                         ),
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF2C2C2E),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         record.symbolName?.toString() ?? 'N/A',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         ohlc?.currentTime?.toString() ??
//                                             todayDate,
//                                         style: const TextStyle(
//                                           color: Colors.grey,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 Column(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(3),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                         color: contColor(
//                                                 ohlc!.open, ohlc.lastPrice)
//                                             .withOpacity(.1),
//                                       ),
//                                       child: Text(
//                                         '₹${_formatNumber(ohlc.lastPrice)}',
//                                         style: TextStyle(
//                                           color: contColor(
//                                               ohlc.open, ohlc.lastPrice),
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     const Text(
//                                       '',
//                                       style: const TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 // Expanded(
//                                 //   flex: 2,
//                                 //   child: Column(
//                                 //     crossAxisAlignment: CrossAxisAlignment.end,
//                                 //     children: [
//                                 //       Text(
//                                 //         '₹${_formatNumber(salePrice)}',
//                                 //         style: TextStyle(
//                                 //           color: _getPriceChangeColor(
//                                 //               -priceChange),
//                                 //           fontSize: 16,
//                                 //           fontWeight: FontWeight.bold,
//                                 //         ),
//                                 //       ),
//                                 //       const SizedBox(height: 4),
//                                 //       Container(
//                                 //         padding: const EdgeInsets.symmetric(
//                                 //           horizontal: 6,
//                                 //           vertical: 2,
//                                 //         ),
//                                 //         decoration: BoxDecoration(
//                                 //           color:
//                                 //               _getPriceChangeColor(-priceChange)
//                                 //                   .withOpacity(0.1),
//                                 //           borderRadius:
//                                 //               BorderRadius.circular(4),
//                                 //         ),
//                                 //         child: Text(
//                                 //           '${priceChange >= 0 ? '+' : ''}${_formatNumber(priceChange)}',
//                                 //           style: TextStyle(
//                                 //             color: _getPriceChangeColor(
//                                 //                 -priceChange),
//                                 //             fontSize: 12,
//                                 //           ),
//                                 //         ),
//                                 //       ),
//                                 //     ],
//                                 //   ),
//                                 // ),
//                                 // Expanded(
//                                 //   flex: 2,
//                                 //   child: Column(
//                                 //     crossAxisAlignment: CrossAxisAlignment.end,
//                                 //     children: [
//                                 //       Text(
//                                 //         '₹${_formatNumber(buyPrice)}',
//                                 //         style: TextStyle(
//                                 //           color:
//                                 //               _getPriceChangeColor(priceChange),
//                                 //           fontSize: 16,
//                                 //           fontWeight: FontWeight.bold,
//                                 //         ),
//                                 //       ),
//                                 //       const SizedBox(height: 4),
//                                 //       Container(
//                                 //         padding: const EdgeInsets.symmetric(
//                                 //           horizontal: 6,
//                                 //           vertical: 2,
//                                 //         ),
//                                 //         decoration: BoxDecoration(
//                                 //           color:
//                                 //               _getPriceChangeColor(priceChange)
//                                 //                   .withOpacity(0.1),
//                                 //           borderRadius:
//                                 //               BorderRadius.circular(4),
//                                 //         ),
//                                 //         child: Text(
//                                 //           '${priceChangePercent >= 0 ? '+' : ''}${_formatNumber(priceChangePercent)}%',
//                                 //           style: TextStyle(
//                                 //             color: _getPriceChangeColor(
//                                 //                 priceChange),
//                                 //             fontSize: 12,
//                                 //           ),
//                                 //         ),
//                                 //       ),
//                                 //     ],
//                                 //   ),
//                                 // ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: 8.h,
//                             ),
//                             Row(
//                               spacing: 5,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text(
//                                       ' H : ',
//                                       style: TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w400,
//                                           color: Colors.white),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.all(3),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                         color: Colors.green.withOpacity(.2),
//                                       ),
//                                       child: Text(
//                                         '₹${_formatNumber(ohlc.high)}',
//                                         style: const TextStyle(
//                                           color: Colors.green,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text(
//                                       ' L : ',
//                                       style: TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w400,
//                                           color: Colors.white),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.all(3),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                         color:
//                                             _getPriceChangeColor(-priceChange)
//                                                 .withOpacity(.1),
//                                       ),
//                                       child: Text(
//                                         '₹${_formatNumber(ohlc.low)}',
//                                         style: TextStyle(
//                                           color: _getPriceChangeColor(
//                                               -priceChange),
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
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
