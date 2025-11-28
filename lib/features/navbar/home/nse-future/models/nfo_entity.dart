class NFODataEntity {
  List<NFOResponseItem>? response;

  NFODataEntity({this.response});

  factory NFODataEntity.fromJson(Map<String, dynamic> json) {
    return NFODataEntity(
      response: (json['response'] as List?)
          ?.map((e) => NFOResponseItem.fromJson(e))
          .toList(),
    );
  }
}

class NFOResponseItem {
  final String? symbol;
  final String? symbolName;
  final String? symbolKey;
  final String? expiryDate;
  final double? change;
  int watchlist;
  final OHLC? ohlcNSE;

  NFOResponseItem({
    this.symbol,
    this.symbolName,
    this.symbolKey,
    this.expiryDate,
    this.change,
    this.watchlist = 0,
    this.ohlcNSE,
  });

  factory NFOResponseItem.fromJson(Map<String, dynamic> json) {
    return NFOResponseItem(
      symbol: json['symbol'] as String?,
      symbolName: json['symbolName'] as String?,
      symbolKey: json['symbolKey'] as String?,
      expiryDate: json['expiryDate'] as String?,
      change: (json['change'] as num?)?.toDouble(),
      watchlist: json['watchlist'] as int? ?? 0,
      ohlcNSE: json['ohlcNSE'] != null ? OHLC.fromJson(json['ohlcNSE']) : null,
    );
  }
}

class OHLC {
  final double high;
  final double low;
  final double lastPrice;
  final double salePrice;
  final double buyPrice;

  OHLC({
    required this.high,
    required this.low,
    required this.lastPrice,
    required this.salePrice,
    required this.buyPrice,
  });

  factory OHLC.fromJson(Map<String, dynamic> json) {
    return OHLC(
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      lastPrice: (json['lastPrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      buyPrice: (json['buyPrice'] as num).toDouble(),
    );
  }
}
