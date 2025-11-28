import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';

class NSEWishlistEntity {
  final int? status;
  final List<NSEWatchlist>? nseWishlist;
  final String? message;

  NSEWishlistEntity({
    this.status,
    this.nseWishlist = const [], // Default to empty list
    this.message = '', // Default to empty string
  });

  factory NSEWishlistEntity.fromJson(Map<String, dynamic> json) {
    return NSEWishlistEntity(
      status: json['status'] as int? ?? 0,
      nseWishlist: json['response'] != null
          ? (json['response'] as List<dynamic>)
              .map((v) => NSEWatchlist.fromJson(v as Map<String, dynamic>))
              .toList()
          : const [],
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['response'] = nseWishlist!.map((v) => v.toJson()).toList();
    data['message'] = message;
    return data;
  }

  // copyWith method
  NSEWishlistEntity copyWith({
    int? status,
    List<NSEWatchlist>? nseWishlist,
    String? message,
  }) {
    return NSEWishlistEntity(
      status: status ?? this.status,
      nseWishlist: nseWishlist ?? this.nseWishlist,
      message: message ?? this.message,
    );
  }
}

class NSEWatchlist {
  final String? symbolKey;
  final String? receivedSymbol;
  final String? symbol;
  final String? symbolName;
  final String? category;
  final String? expiryDate;
  final String? currentTime;
  final double? change;
  final Ohlc? ohlc; // Nullable since it can be absent
  final LastSale? lastSale;
  final LastBuy? lastBuy;

  NSEWatchlist( {
    this.symbolKey,
    this.receivedSymbol,
    this.symbol,
    this.symbolName,
    this.category,
    this.expiryDate,
    this.currentTime,
    this.change,
    this.ohlc,
    this.lastSale, this.lastBuy,
  });

  factory NSEWatchlist.fromJson(Map<String, dynamic> json) {
    return NSEWatchlist(
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
  NSEWatchlist copyWith({
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
    return NSEWatchlist(
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
