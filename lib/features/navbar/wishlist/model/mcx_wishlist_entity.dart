import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';

class MCXWishlistEntity {
  final int? status;
  final List<MCXWatchlist>? mcxWatchlist;
  String? message;

  MCXWishlistEntity({this.status, this.mcxWatchlist, this.message = ''});

  factory MCXWishlistEntity.fromJson(Map<String, dynamic> json) {
    return MCXWishlistEntity(
      status: json['status'] as int? ?? 0,
      mcxWatchlist: json['response'] != null
          ? (json['response'] as List<dynamic>)
                .map((v) => MCXWatchlist.fromJson(v as Map<String, dynamic>))
                .toList()
          : [],
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['response'] = mcxWatchlist!.map((v) => v.toJson()).toList();
    data['message'] = message;
    return data;
  }

  // copyWith method
  MCXWishlistEntity copyWith({
    int? status,
    List<MCXWatchlist>? mcxWatchlist,
    String? message,
  }) {
    return MCXWishlistEntity(
      status: status ?? this.status,
      mcxWatchlist: mcxWatchlist ?? this.mcxWatchlist,
      message: message ?? this.message,
    );
  }
}

class MCXWatchlist {
  final String? symbolKey;
  final String? receivedSymbol;
  final String? symbol;
  final String? symbolName;
  final String? category;
  final String? expiryDate;
  final String? currentTime;
  final dynamic change;
  final Ohlc? ohlc;
  final LastSale? lastSale;
  final LastBuy? lastBuy;

  MCXWatchlist(
    this.lastSale,
    this.lastBuy, {
    this.symbolKey,
    this.receivedSymbol,
    this.symbol,
    this.symbolName,
    this.category,
    this.expiryDate,
    this.currentTime,
    this.change,
    this.ohlc,
  });

  factory MCXWatchlist.fromJson(Map<String, dynamic> json) {
    return MCXWatchlist(
      json['lastSell'] != null
          ? LastSale.fromJson(json['lastSell'] as Map<String, dynamic>)
          : null,
      json['lastBuy'] != null
          ? LastBuy.fromJson(json['lastBuy'] as Map<String, dynamic>)
          : null,
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
}

class Ohlc {
  final dynamic high;
  final dynamic low;
  final dynamic close;
  final dynamic open;
  final int? lotSize;
  final int? volume;
  final dynamic salePrice;
  final dynamic buyPrice;
  final dynamic lastPrice;

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
      high: parseDouble(json['high']) ?? 0.0,
      low: parseDouble(json['low']) ?? 0.0,
      close: parseDouble(json['close']) ?? 0.0,
      open: parseDouble(json['open']) ?? 0.0,
      lotSize: json['lot_size'] ?? 0,
      volume: json['volume'] as int? ?? 0,
      salePrice: parseDouble(json['sale_price']) ?? 0.0,
      buyPrice: parseDouble(json['buy_price']) ?? 0.0,
      lastPrice: parseDouble(json['last_price']) ?? 0.0,
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
    dynamic high,
    dynamic low,
    dynamic close,
    dynamic open,
    int? lotSize,
    int? volume,
    dynamic salePrice,
    dynamic buyPrice,
    dynamic lastPrice,
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
