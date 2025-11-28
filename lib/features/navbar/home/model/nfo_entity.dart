// ignore_for_file: public_member_api_docs, sort_constructors_first
class NFODataEntity {
  int? status;
  List<RecordNFO>? response;
  String? message;

  NFODataEntity({this.status, this.response, this.message});

  NFODataEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['response'] != null) {
      response = <RecordNFO>[];
      json['response'].forEach((v) {
        response!.add(RecordNFO.fromJson(v));
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

class RecordNFO {
  String? receivedSymbol;
  String? symbol;
  String? symbolKey;
  dynamic watchlist;
  String? symbolName;
  String? category;
  String? expiryDate;
  String? currentTime;
  double? change;
  dynamic lotSize;
  OhlcNFO? ohlcNSE;

  RecordNFO({
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

  RecordNFO.fromJson(Map<String, dynamic> json) {
    receivedSymbol = json['receivedSymbol'] ?? 'N/A';
    symbol = json['symbol'] ?? 'N/A';
    symbolKey = json['symbolKey'] ?? 'N/A';
    watchlist = json['watchlist'] ?? 'N/A';
    symbolName = json['symbolName'] ?? 'N/A';
    category = json['category'] ?? 'N/A';
    expiryDate = json['expiryDate'] ?? 'N/A';
    currentTime = json['current_time'] ?? 'N/A';
    change = parseDouble(json['change']) ?? 0.0;
    lotSize = json['lotSize'] ?? 0;
    ohlcNSE = json['ohlc'] != null ? OhlcNFO.fromJson(json['ohlc']) : null;
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

class OhlcNFO {
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
  String? currentTime;

  OhlcNFO(
      {this.high,
      this.low,
      this.close,
      this.open,
      this.lotSize,
      this.volume,
      this.change,
      this.salePrice,
      this.buyPrice,
      this.lastPrice,
      this.currentTime});

  OhlcNFO.fromJson(Map<String, dynamic> json) {
    high = parseDouble(json['high']) ?? 0.0;
    low = parseDouble(json['low']) ?? 0.0;
    close = parseDouble(json['close']) ?? 0.0;
    open = parseDouble(json['open']) ?? 0.0;
    lotSize = json['lot_size'];
    volume = parseDouble(json['volume']) ?? 0.0;
    change = parseDouble(json['change']) ?? 0.0;
    salePrice = parseDouble(json['sale_price']) ?? 0.0;
    buyPrice = parseDouble(json['buy_price']) ?? 0.0;
    lastPrice = parseDouble(json['last_price']) ?? 0.0;
    currentTime = json['current_time'] ?? 'N/A';
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

  OhlcNFO copyWith({
    dynamic high,
    dynamic low,
    dynamic close,
    dynamic open,
    dynamic lotSize,
    dynamic volume,
    dynamic change,
    dynamic salePrice,
    dynamic buyPrice,
    dynamic lastPrice,
    String? currentTime,
  }) {
    return OhlcNFO(
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      open: open ?? this.open,
      lotSize: lotSize ?? this.lotSize,
      volume: volume ?? this.volume,
      change: change ?? this.change,
      salePrice: salePrice ?? this.salePrice,
      buyPrice: buyPrice ?? this.buyPrice,
      lastPrice: lastPrice ?? this.lastPrice,
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}
