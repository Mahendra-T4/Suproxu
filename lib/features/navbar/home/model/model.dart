// class GetStockRecordEntity {
//   final int status;
//   final List<ResponseGetRecord> response;
//   final String message;

//   GetStockRecordEntity({
//     required this.status,
//     required this.response,
//     required this.message,
//   });

//   factory GetStockRecordEntity.fromJson(Map<String, dynamic> json) {
//     return GetStockRecordEntity(
//       status: json['status'] as int? ?? 0,
//       response: (json['response'] as List<dynamic>?)
//               ?.map((e) => ResponseGetRecord.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       message: json['message'] as String? ?? '',
//     );
//   }
// }

// class ResponseGetRecord {
//   final String symbolKey;
//   final double watchlist;
//   final String receivedSymbol;
//   final String symbol;
//   final String symbolName;
//   final String category;
//   final String expiryDate;
//   final String currentTime;
//   final double change;
//   final double openInterest;
//   final double upperCKT;
//   final double lowerCKT;
//   final double averageTradePrice;
//   final LastBuy lastBuy;
//   final LastSell lastSell;
//   final double lotSize;
//   final OhlcGetRecord ohlc;

//   ResponseGetRecord({
//     required this.symbolKey,
//     required this.watchlist,
//     required this.receivedSymbol,
//     required this.symbol,
//     required this.symbolName,
//     required this.category,
//     required this.expiryDate,
//     required this.currentTime,
//     required this.change,
//     required this.openInterest,
//     required this.upperCKT,
//     required this.lowerCKT,
//     required this.averageTradePrice,
//     required this.lastBuy,
//     required this.lastSell,
//     required this.lotSize,
//     required this.ohlc,
//   });

//   factory ResponseGetRecord.fromJson(Map<String, dynamic> json) {
//     return ResponseGetRecord(
//       symbolKey: json['symbolKey'] as String? ?? '',
//       watchlist: (json['watchlist'] as num?)?.toDouble() ?? 0.0,
//       receivedSymbol: json['receivedSymbol'] as String? ?? '',
//       symbol: json['symbol'] as String? ?? '',
//       symbolName: json['symbolName'] as String? ?? '',
//       category: json['category'] as String? ?? '',
//       expiryDate: json['expiryDate'] as String? ?? '',
//       currentTime: json['current_time'] as String? ?? '',
//       change: (json['change'] as num?)?.toDouble() ?? 0.0,
//       openInterest: (json['openInterest'] as num?)?.toDouble() ?? 0.0,
//       upperCKT: (json['upperCKT'] as num?)?.toDouble() ?? 0.0,
//       lowerCKT: (json['lowerCKT'] as num?)?.toDouble() ?? 0.0,
//       averageTradePrice: (json['averageTradePrice'] as num?)?.toDouble() ?? 0.0,
//       lastBuy: LastBuy.fromJson(json['lastBuy'] as Map<String, dynamic>? ?? {}),
//       lastSell: LastSell.fromJson(json['lastSell'] as Map<String, dynamic>? ?? {}),
//       lotSize: (json['lotSize'] as num?)?.toDouble() ?? 0.0,
//       ohlc: OhlcGetRecord.fromJson(json['ohlc'] as Map<String, dynamic>? ?? {}),
//     );
//   }
// }

// class LastBuy {
//   final double price;
//   final double quantity;
//   final double orders;

//   LastBuy({
//     required this.price,
//     required this.quantity,
//     required this.orders,
//   });

//   factory LastBuy.fromJson(Map<String, dynamic> json) {
//     return LastBuy(
//       price: (json['price'] as num?)?.toDouble() ?? 0.0,
//       quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
//       orders: (json['orders'] as num?)?.toDouble() ?? 0.0,
//     );
//   }
// }

// class LastSell {
//   final double price;
//   final double quantity;
//   final double orders;

//   LastSell({
//     required this.price,
//     required this.quantity,
//     required this.orders,
//   });

//   factory LastSell.fromJson(Map<String, dynamic> json) {
//     return LastSell(
//       price: (json['price'] as num?)?.toDouble() ?? 0.0,
//       quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
//       orders: (json['orders'] as num?)?.toDouble() ?? 0.0,
//     );
//   }
// }

// class OhlcGetRecord {
//   final double high;
//   final double low;
//   final double close;
//   final double open;
//   final double volume;
//   final double salePrice;
//   final double buyPrice;
//   final double lastPrice;

//   OhlcGetRecord({
//     required this.high,
//     required this.low,
//     required this.close,
//     required this.open,
//     required this.volume,
//     required this.salePrice,
//     required this.buyPrice,
//     required this.lastPrice,
//   });

//   factory OhlcGetRecord.fromJson(Map<String, dynamic> json) {
//     return OhlcGetRecord(
//       high: (json['high'] as num?)?.toDouble() ?? 0.0,
//       low: (json['low'] as num?)?.toDouble() ?? 0.0,
//       close: (json['close'] as num?)?.toDouble() ?? 0.0,
//       open: (json['open'] as num?)?.toDouble() ?? 0.0,
//       volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
//       salePrice: (json['sale_price'] as num?)?.toDouble() ?? 0.0,
//       buyPrice: (json['buy_price'] as num?)?.toDouble() ?? 0.0,
//       lastPrice: (json['last_price'] as num?)?.toDouble() ?? 0.0,
//     );
//   }
// }