// ignore_for_file: public_member_api_docs, sort_constructors_first

class MCXDataEntity {
  int? status;
  List<RecordMCX>? response;
  String? message;

  MCXDataEntity({this.status, this.response, this.message});

  MCXDataEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['response'] != null) {
      response = <RecordMCX>[];
      json['response'].forEach((v) {
        response!.add(new RecordMCX.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.response != null) {
      data['response'] = this.response!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class RecordMCX {
  final dynamic receivedSymbol;
  final dynamic symbol;
  final dynamic symbolKey;
  int? watchlist;
  final dynamic symbolName;
  final dynamic category;
  final String? expiryDate;
  final dynamic currentTime;
  final dynamic change;
  final int? lotSize;
  final OhlcMCX? ohlc;

  RecordMCX({
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
    this.ohlc,
  });

  factory RecordMCX.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RecordMCX();
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return RecordMCX(
      receivedSymbol: json['receivedSymbol']?.toString(),
      symbol: json['symbol']?.toString(),
      symbolKey: json['symbolKey']?.toString(),
      watchlist: json['watchlist'] is int
          ? json['watchlist']
          : int.tryParse(json['watchlist']?.toString() ?? ''),
      symbolName: json['symbolName']?.toString(),
      category: json['category']?.toString(),
      expiryDate: json['expiryDate'],
      currentTime: json['current_time']?.toString(),
      change: parseDouble(json['change']),
      lotSize: json['lotSize'],
      ohlc: (json['ohlc'] is Map<String, dynamic>)
          ? OhlcMCX.fromJson(json['ohlc'] as Map<String, dynamic>?)
          : null,
    );
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
    if (ohlc != null) {
      data['ohlc'] = ohlc!.toJson();
    }
    return data;
  }

  RecordMCX copyWith({
    dynamic receivedSymbol,
    dynamic symbol,
    dynamic symbolKey,
    int? watchlist,
    dynamic symbolName,
    dynamic category,
    dynamic expiryDate,
    dynamic currentTime,
    dynamic change,
    int? lotSize,
    OhlcMCX? ohlc,
  }) {
    return RecordMCX(
      receivedSymbol: receivedSymbol ?? this.receivedSymbol,
      symbol: symbol ?? this.symbol,
      symbolKey: symbolKey ?? this.symbolKey,
      watchlist: watchlist ?? this.watchlist,
      symbolName: symbolName ?? this.symbolName,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      currentTime: currentTime ?? this.currentTime,
      change: change ?? this.change,
      lotSize: lotSize ?? this.lotSize,
      ohlc: ohlc ?? this.ohlc,
    );
  }
}

class OhlcMCX {
  final dynamic high;
  final dynamic low;
  final dynamic close;
  final dynamic open;
  final int? lotSize;
  final dynamic volume;
  final dynamic change;
  final dynamic salePrice;
  final dynamic buyPrice;
  final dynamic lastPrice;

  OhlcMCX({
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
  });

  factory OhlcMCX.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OhlcMCX();
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return OhlcMCX(
      high: parseDouble(json['high']) ?? 0.0,
      low: parseDouble(json['low']) ?? 0.0,
      close: parseDouble(json['close']) ?? 0.0,
      open: parseDouble(json['open']) ?? 0.0,
      lotSize: json['lot_size'] ?? 0,
      volume: parseDouble(json['volume']) ?? 0.0,
      change: parseDouble(json['change']) ?? 0.0,
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
    data['change'] = change;
    data['sale_price'] = salePrice;
    data['buy_price'] = buyPrice;
    data['last_price'] = lastPrice;
    return data;
  }

  OhlcMCX copyWith({
    dynamic high,
    dynamic low,
    dynamic close,
    dynamic open,
    int? lotSize,
    dynamic volume,
    dynamic change,
    dynamic salePrice,
    dynamic buyPrice,
    dynamic lastPrice,
  }) {
    return OhlcMCX(
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
    );
  }
}
