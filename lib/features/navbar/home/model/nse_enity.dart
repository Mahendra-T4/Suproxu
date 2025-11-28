class NSEDataEntity {
  int? status;
  List<RecordNSE>? response;
  String? message;

  NSEDataEntity({this.status, this.response, this.message});

  NSEDataEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['response'] != null) {
      response = <RecordNSE>[];
      json['response'].forEach((v) {
        response!.add(RecordNSE.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (response != null) {
      data['response'] = response!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class RecordNSE {
  String? receivedSymbol;
  String? symbol;
  String? symbolKey;
  int? watchlist;
  String? symbolName;
  String? category;
  String? expiryDate;
  String? currentTime;
  double? change;
   int? lotSize;
  OhlcNSE? ohlcNSE;

  RecordNSE({
    this.receivedSymbol,
    this.symbol,
    this.symbolKey,
    this.watchlist,
    this.symbolName,
    this.category,
    this.expiryDate,
    this.currentTime,
    this.change,
    this.lotSize,
    this.ohlcNSE,
  });

  RecordNSE.fromJson(Map<String, dynamic> json) {
    receivedSymbol = json['receivedSymbol'] ?? '';
    symbol = json['symbol'] ?? '';
    symbolKey = json['symbolKey'] ?? '';
    watchlist = json['watchlist'] ?? '';
    symbolName = json['symbolName'] ?? '';
    category = json['category'] ?? '';
    expiryDate = json['expiryDate'] ?? '';
    currentTime = json['current_time'] ?? '';
    change = json['change']?.toDouble();
     lotSize = json['lotSize'] ?? 0;
    ohlcNSE = json['ohlc'] != null ? OhlcNSE.fromJson(json['ohlc']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['receivedSymbol'] = receivedSymbol;
    data['symbol'] = symbol;
    data['symbolKey'] = symbolKey;
    data['watchlist'] = watchlist;
    data['symbolName'] = symbolName;
    data['category'] = category;
    data['expiryDate'] = expiryDate;
    data['current_time'] = currentTime;
    data['change'] = change;
      data['lotSize'] = lotSize;
    if (ohlcNSE != null) {
      data['ohlc'] = ohlcNSE!.toJson();
    }
    return data;
  }
}

class OhlcNSE {
  dynamic high;
  dynamic low;
  dynamic close;
  dynamic open;
  dynamic lotSize;
  dynamic volume;
  dynamic change;
  dynamic salePrice;
  dynamic buyPrice;
  dynamic lastPrice;
  dynamic currentTime;

  OhlcNSE({
    this.high,
    this.low,
    this.close,
    this.open,
    this.lotSize,
    this.volume,
    this.change,
    this.salePrice,
    this.buyPrice,
    this.lastPrice,
    this.currentTime,
  });

  OhlcNSE.fromJson(Map<String, dynamic> json) {
    high = _parseDouble(json['high']) ?? 0.0;
    low = _parseDouble(json['low']) ?? 0.0;
    close = _parseDouble(json['close']) ?? 0.0;
    open = _parseDouble(json['open']) ?? 0.0;
    lotSize = _parseInt(json['lot_size']);
    volume = _parseInt(json['volume']);
    change = _parseDouble(json['change']) ?? 0.0;
    salePrice = _parseDouble(json['sale_price']) ?? 0.0;
    buyPrice = _parseDouble(json['buy_price']) ?? 0.0;
    lastPrice = _parseDouble(json['last_price']) ?? 0.0;
    currentTime = json['current_time']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['high'] = high;
    data['low'] = low;
    data['close'] = close;
    data['open'] = open;
    data['lot_size'] = lotSize;
    data['volume'] = volume;
    data['change'] = change;
    data['sale_price'] = salePrice;
    data['buy_price'] = buyPrice;
    data['last_price'] = lastPrice;
    data['current_time'] = currentTime;
    return data;
  }

  // Helper methods for safe parsing
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Convenience getters for safe access
  double get highValue => high ?? 0.0;
  double get lowValue => low ?? 0.0;
  double get closeValue => close ?? 0.0;
  double get openValue => open ?? 0.0;
  int get lotSizeValue => lotSize ?? 0;
  int get volumeValue => volume ?? 0;
  double get changeValue => change ?? 0.0;
  double get salePriceValue => salePrice ?? 0.0;
  double get buyPriceValue => buyPrice ?? 0.0;
  double get lastPriceValue => lastPrice ?? 0.0;
  String get currentTimeValue => currentTime ?? 'N/A';

  // Helper method to check if price data is valid
  bool get hasPriceData =>
      high != null && low != null && open != null && close != null;

  // Helper method to calculate price change percentage
  double? getPriceChangePercentage() {
    if (open == null || lastPrice == null || open == 0) return null;
    return ((lastPrice! - open!) / open!) * 100;
  }
}
