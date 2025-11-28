// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trading_app/features/navbar/home/mcx/mcx_list_item.dart';
// import 'package:trading_app/features/navbar/home/providers/mcx_stock_list_provider.dart';

// class MCXStockListPanel extends ConsumerWidget {
//   const MCXStockListPanel({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final mcxState = ref.watch(mcxDataProvider);

//     if (!mcxState.isConnected) {
//       return const Center(
//         child: Text('Connecting to server...'),
//       );
//     }

//     final stocks = mcxState.data?.response ?? [];

//     return ListView.builder(
//       itemCount: stocks.length,
//       itemBuilder: (context, index) {
//         final item = stocks[index];
//         return MCXListItem(
//           key: ValueKey(item.symbolKey),
//           item: item,
//           index: index,
//           onRefresh: () => ref.read(mcxDataProvider.notifier).reconnect(),
//         );
//       },
//     );
//   }
// }
