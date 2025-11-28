// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:trading_app/features/navbar/home/model/nse_enity.dart';

// import 'package:trading_app/features/navbar/home/nse/nsePage.dart';
// import 'package:trading_app/features/navbar/home/repository/trade_repository.dart';

// abstract class NseUiBuilder extends State<Nsescreen> {
//   dynamic stockName;

//   final StreamController<List<RecordNSE>> streamController =
//       StreamController<List<RecordNSE>>();
//   // late Timer timer;
//   List<RecordNSE> records = [];
//   List<RecordNSE> filteredRecords = [];
//   TextEditingController searchController = TextEditingController();
//   bool isMarketOpen = true; // This should be fetched from your backend

//   @override
//   void initState() {
//     super.initState();
//     // stocksMapper();

//     fetchData();
//   }

//   Future<void> fetchData() async {
//     try {
//       final nseData = await TradeRepository().nseTradeDataLoader();
//       if (!streamController.isClosed) {
//         streamController.add(nseData.response ?? []);
//         setState(() {
//           records = nseData.response ?? [];
//           filteredRecords = filterRecords(searchController.text);
//         });
//       }
//     } catch (error) {
//       if (!streamController.isClosed) {
//         streamController.addError("Error fetching data: $error");
//       }
//     }
//   }

//   List<RecordNSE> filterRecords(String query) {
//     return records
//         .where((record) =>
//             record.symbolName?.toLowerCase().contains(query.toLowerCase()) ??
//             false)
//         .toList();
//   }

//   void onSearchChanged(String query) {
//     setState(() {
//       filteredRecords = filterRecords(query);
//     });
//   }

//   @override
//   void dispose() {
//     // timer.cancel();
//     streamController.close();
//     // searchController.dispose();
//     super.dispose();
//   }

//   String formatNumber(dynamic number) {
//     if (number == null) return 'N/A';
//     final formatter = NumberFormat('#,##,##0.00');
//     return formatter.format(number);
//   }

//   Color getPriceChangeColor(double? change) {
//     if (change == null) return Colors.grey;
//     return change >= 0 ? const Color(0xFF00C853) : const Color(0xFFFF3D00);
//   }
// }
