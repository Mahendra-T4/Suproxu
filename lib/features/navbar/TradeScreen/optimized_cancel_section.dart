// // Optimized Cancel Order Section for tradeActive.dart
// // Replace the existing cancel order section with this code

// // REPLACE THIS SECTION IN YOUR tradeActive.dart:
// /*
// activeTradeEntity.record![index].tradeMethod == 1
//     ? CancelOrderSale(
//         refresh: () => _tradeBloc.add(
//             ActiveStockTradeEvent(activity: 'active-stock')),
//         params: CancelOrderParams(
//             status: activeTradeEntity.status!,
//             symbolKey: activeTradeEntity.record![index].symbolKey.toString(),
//             dataRelatedTo: activeTradeEntity.record![index].dataRelatedTo.toString(),
//             stockPrice: activeTradeEntity.record![index].stockPrice,
//             tradeMethod: activeTradeEntity.record![index].tradeMethod.toString(),
//             availableQty: activeTradeEntity.record![index].availableQty))
//     : CancelOrderBuy(
//         refresh: () {
//           _tradeBloc.add(ActiveStockTradeEvent(activity: 'active-stock'));
//           activeTradeEntity.record!.removeAt(index);
//         },
//         params: CancelOrderParams(
//             status: activeTradeEntity.status!,
//             symbolKey: activeTradeEntity.record![index].symbolKey.toString(),
//             dataRelatedTo: activeTradeEntity.record![index].dataRelatedTo.toString(),
//             stockPrice: activeTradeEntity.record![index].stockPrice,
//             tradeMethod: activeTradeEntity.record![index].tradeMethod.toString(),
//             availableQty: activeTradeEntity.record![index].availableQty))
// */

// // WITH THIS OPTIMIZED VERSION:

// activeTradeEntity.record![index].tradeMethod == 1
//     ? CancelOrderSale(
//         refresh: () {
//           // IMMEDIATE UI UPDATE FIRST
//           setState(() {
//             activeTradeEntity.record!.removeAt(index);
//           });
//           // BACKGROUND REFRESH
//           _tradeBloc.add(ActiveStockTradeEvent(activity: 'active-stock'));
//         },
//         params: CancelOrderParams(
//             status: activeTradeEntity.status!,
//             symbolKey: activeTradeEntity.record![index].symbolKey.toString(),
//             dataRelatedTo: activeTradeEntity.record![index].dataRelatedTo.toString(),
//             stockPrice: activeTradeEntity.record![index].stockPrice,
//             tradeMethod: activeTradeEntity.record![index].tradeMethod.toString(),
//             availableQty: activeTradeEntity.record![index].availableQty))
//     : CancelOrderBuy(
//         refresh: () {
//           // IMMEDIATE UI UPDATE FIRST
//           setState(() {
//             activeTradeEntity.record!.removeAt(index);
//           });
//           // BACKGROUND REFRESH
//           _tradeBloc.add(ActiveStockTradeEvent(activity: 'active-stock'));
//         },
//         params: CancelOrderParams(
//             status: activeTradeEntity.status!,
//             symbolKey: activeTradeEntity.record![index].symbolKey.toString(),
//             dataRelatedTo: activeTradeEntity.record![index].dataRelatedTo.toString(),
//             stockPrice: activeTradeEntity.record![index].stockPrice,
//             tradeMethod: activeTradeEntity.record![index].tradeMethod.toString(),
//             availableQty: activeTradeEntity.record![index].availableQty))

// // KEY CHANGES:
// // 1. Both refresh callbacks now use setState() FIRST for immediate UI update
// // 2. API calls moved to background (after UI update)
// // 3. Consistent behavior for both Sale and Buy buttons
// // 4. Eliminates the 1-second delay by prioritizing UI responsiveness

// // ADDITIONAL OPTIMIZATION:
// // Consider adding loading states to the cancel order widgets themselves
// // to provide even better user feedback during processing