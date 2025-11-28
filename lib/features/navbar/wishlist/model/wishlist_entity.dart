import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';

class NFOWishlistEntity {
  final int? status;
  final List<NFOWatchList>? nfoWatchlist;
  String? message;

  NFOWishlistEntity({
    this.status,
    this.nfoWatchlist = const [], // Default to empty list
    this.message = '', // Default to empty string
  });

  factory NFOWishlistEntity.fromJson(Map<String, dynamic> json) {
    return NFOWishlistEntity(
      status: json['status'] as int? ?? 0,
      nfoWatchlist: json['response'] != null
          ? (json['response'] as List<dynamic>)
              .map((v) => NFOWatchList.fromJson(v as Map<String, dynamic>))
              .toList()
          : const [],
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['response'] = nfoWatchlist!.map((v) => v.toJson()).toList();
    data['message'] = message;
    return data;
  }

  // copyWith method
  NFOWishlistEntity copyWith({
    int? status,
    List<NFOWatchList>? nfoWatchlist,
    String? message,
  }) {
    return NFOWishlistEntity(
      status: status ?? this.status,
      nfoWatchlist: nfoWatchlist ?? this.nfoWatchlist,
      message: message ?? this.message,
    );
  }
}

class NFOWatchList {
  final String? symbolKey;
  final String? receivedSymbol;
  final String? symbol;
  final String? symbolName;
  final String? category;
  final String? expiryDate;
  final String? currentTime;
  final double? change;
  final Ohlc? ohlc;
  final LastSale? lastSale;
  final LastBuy? lastBuy;

  NFOWatchList({
    this.symbolKey,
    this.receivedSymbol,
    this.symbol,
    this.symbolName,
    this.category,
    this.expiryDate,
    this.currentTime,
    this.change,
    this.ohlc,
    this.lastSale,
    this.lastBuy,
  });

  factory NFOWatchList.fromJson(Map<String, dynamic> json) {
    return NFOWatchList(
      symbolKey: json['symbolKey'] as String? ?? '',
      receivedSymbol: json['receivedSymbol'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      symbolName: json['symbolName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
      currentTime: json['current_time'] as String? ?? '',
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      ohlc: json['ohlc'] != null
          ? Ohlc.fromJson(json['ohlc'] as Map<String, dynamic>)
          : null,
      lastSale: json['lastSell'] != null
          ? LastSale.fromJson(json['lastSell'] as Map<String, dynamic>)
          : null,
      lastBuy: json['lastBuy'] != null
          ? LastBuy.fromJson(json['lastBuy'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['symbolKey'] = symbolKey;
    data['receivedSymbol'] = receivedSymbol;
    data['symbol'] = symbol;
    data['symbolName'] = symbolName;
    data['category'] = category;
    data['expiryDate'] = expiryDate;
    data['current_time'] = currentTime;
    data['change'] = change;
    if (ohlc != null) {
      data['ohlc'] = ohlc!.toJson();
    }
    return data;
  }

  // copyWith method
  NFOWatchList copyWith({
    String? symbolKey,
    String? receivedSymbol,
    String? symbol,
    String? symbolName,
    String? category,
    String? expiryDate,
    String? currentTime,
    double? change,
    Ohlc? ohlc, // Nullable to allow explicit null assignment
  }) {
    return NFOWatchList(
      symbolKey: symbolKey ?? this.symbolKey,
      receivedSymbol: receivedSymbol ?? this.receivedSymbol,
      symbol: symbol ?? this.symbol,
      symbolName: symbolName ?? this.symbolName,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      currentTime: currentTime ?? this.currentTime,
      change: change ?? this.change,
      ohlc: ohlc ?? this.ohlc,
    );
  }
}

class Ohlc {
  final double? high;
  final double? low;
  final double? close;
  final double? open;
  final int? lotSize;
  final int? volume;
  final double? salePrice;
  final double? buyPrice;
  final double? lastPrice;

  Ohlc({
    this.high,
    this.low,
    this.close,
    this.open,
    this.lotSize,
    this.volume,
    this.salePrice,
    this.buyPrice,
    this.lastPrice,
  });

  factory Ohlc.fromJson(Map<String, dynamic> json) {
    return Ohlc(
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      close: (json['close'] as num?)?.toDouble() ?? 0.0,
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      lotSize: json['lot_size'] as int? ?? 0,
      volume: json['volume'] as int? ?? 0,
      salePrice: (json['sale_price'] as num?)?.toDouble() ?? 0.0,
      buyPrice: (json['buy_price'] as num?)?.toDouble() ?? 0.0,
      lastPrice: (json['last_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['high'] = high;
    data['low'] = low;
    data['close'] = close;
    data['open'] = open;
    data['lot_size'] = lotSize;
    data['volume'] = volume;
    data['sale_price'] = salePrice;
    data['buy_price'] = buyPrice;
    data['last_price'] = lastPrice;
    return data;
  }

  // copyWith method
  Ohlc copyWith({
    double? high,
    double? low,
    double? close,
    double? open,
    int? lotSize,
    int? volume,
    double? salePrice,
    double? buyPrice,
    double? lastPrice,
  }) {
    return Ohlc(
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      open: open ?? this.open,
      lotSize: lotSize ?? this.lotSize,
      volume: volume ?? this.volume,
      salePrice: salePrice ?? this.salePrice,
      buyPrice: buyPrice ?? this.buyPrice,
      lastPrice: lastPrice ?? this.lastPrice,
    );
  }
}

class LastBuy {
  final dynamic price;
  final int? quantity;
  final int? orders;

  LastBuy({this.price, this.quantity, this.orders});
  factory LastBuy.fromJson(Map<String, dynamic> json) {
    return LastBuy(
      price: parseDouble(json['price']) ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
      orders: json['orders'] as int? ?? 0,
    );
  }
}

class LastSale {
  final dynamic price;
  final int? quantity;
  final int? orders;

  LastSale({this.price, this.quantity, this.orders});
  factory LastSale.fromJson(Map<String, dynamic> json) {
    return LastSale(
      price: parseDouble(json['price']) ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
      orders: json['orders'] as int? ?? 0,
    );
  }
}
