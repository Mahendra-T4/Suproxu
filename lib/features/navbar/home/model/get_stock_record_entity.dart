// ignore_for_file: public_member_api_docs, sort_constructors_first


double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  return double.tryParse(value.toString());
}

class GetStockRecordEntity {
  int status;
  List<ResponseGetRecord> response;
  String message;

  GetStockRecordEntity({
    this.status = 0,
    List<ResponseGetRecord>? response,
    this.message = '',
  }) : response = response ?? [];

  factory GetStockRecordEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return GetStockRecordEntity();
    }
    // Support legacy shape where 'response' is a List and new shape where 'data' is a single object
    final int status = json['status'] is int
        ? json['status'] ?? 0
        : int.tryParse(json['status']?.toString() ?? '') ?? 0;

    List<ResponseGetRecord> responseList = [];

    if (json['response'] != null && json['response'] is List) {
      responseList = (json['response'] as List)
          .map((v) => ResponseGetRecord.fromJson(v as Map<String, dynamic>?))
          .toList();
    } else if (json['data'] != null) {
      // 'data' may be a Map for single-record responses or a List
      if (json['data'] is List) {
        responseList = (json['data'] as List)
            .map((v) => ResponseGetRecord.fromJson(v as Map<String, dynamic>?))
            .toList();
      } else if (json['data'] is Map) {
        responseList = [
          ResponseGetRecord.fromJson(json['data'] as Map<String, dynamic>?)
        ];
      }
    }

    return GetStockRecordEntity(
      status: status,
      response: responseList,
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['response'] = response.map((v) => v.toJson()).toList();
    data['message'] = message;
    return data;
  }
}

class ResponseGetRecord {
  final String symbolKey;
  int watchlist; // Not final since it can be updated
  final String receivedSymbol;
  final String symbol;
  final String symbolName;
  final String category;
  final String expiryDate;
  final String currentTime;
  final dynamic change;
  final dynamic openInterest;
  final dynamic upperCKT;
  final dynamic lowerCKT;
  final dynamic averageTradePrice;
  final LastBuy lastBuy;
  final LastBuy lastSell;
  final int lotSize;
  final OhlcGetRecord ohlc;

  ResponseGetRecord({
    this.symbolKey = '',
    this.watchlist = 0,
    this.receivedSymbol = '',
    this.symbol = '',
    this.symbolName = '',
    this.category = '',
    this.expiryDate = '',
    this.currentTime = '',
    this.change = 0.0,
    this.openInterest = 0.0,
    this.upperCKT = 0.0,
    this.lowerCKT = 0.0,
    this.averageTradePrice = 0.0,
    LastBuy? lastBuy,
    LastBuy? lastSell,
    this.lotSize = 0,
    OhlcGetRecord? ohlc,
  })  : lastBuy = lastBuy ?? LastBuy(),
        lastSell = lastSell ?? LastBuy(),
        ohlc = ohlc ?? OhlcGetRecord();

  factory ResponseGetRecord.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ResponseGetRecord();
    }
    // Helper to read possible variants of keys
    String? readString(Map<String, dynamic> m, List<String> keys) {
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) return m[k].toString();
      }
      return null;
    }

    dynamic readDynamic(Map<String, dynamic> m, List<String> keys) {
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) return m[k];
      }
      return null;
    }

    final Map<String, dynamic> m = json;

    // Build ohlc: either nested 'ohlc' or flat open/high/low/close/volume and optional 'ltp'
    OhlcGetRecord ohlcRecord;
    if (m['ohlc'] != null && m['ohlc'] is Map) {
      ohlcRecord = OhlcGetRecord.fromJson(m['ohlc'] as Map<String, dynamic>?);
    } else {
      ohlcRecord = OhlcGetRecord(
        high: parseDouble(readString(m, ['high']) ?? m['high']) ?? 0.0,
        low: parseDouble(readString(m, ['low']) ?? m['low']) ?? 0.0,
        close: parseDouble(readString(m, ['close']) ?? m['close']) ?? 0.0,
        open: parseDouble(readString(m, ['open']) ?? m['open']) ?? 0.0,
        volume: parseDouble(readString(m, ['volume']) ?? m['volume']) ?? 0.0,
        salePrice: parseDouble(readString(m, ['sale_price', 'salePrice']) ??
                m['sale_price']) ??
            0.0,
        buyPrice: parseDouble(
                readString(m, ['buy_price', 'buyPrice']) ?? m['buy_price']) ??
            0.0,
        lastPrice: parseDouble(
                readString(m, ['ltp', 'last_price', 'lastPrice']) ??
                    m['ltp']) ??
            0.0,
      );
    }

    // If top-level ltp is present prefer it as lastPrice (over any inside ohlc)
    final dynamic topLtp = readDynamic(m, ['ltp', 'last_price', 'lastPrice']);
    if (topLtp != null) {
      final parsedLtp = parseDouble(topLtp) ?? 0.0;
      ohlcRecord = ohlcRecord.copyWith(lastPrice: parsedLtp);
    }

    return ResponseGetRecord(
      symbolKey: readString(
              m, ['symbolKey', 'symbol_key', 'symbolkey', 'symbolKey']) ??
          '',
      watchlist: m['watchlist'] is int
          ? m['watchlist'] ?? 0
          : int.tryParse(m['watchlist']?.toString() ?? '') ?? 0,
      receivedSymbol: readString(m, ['receivedSymbol']) ?? '',
      symbol: readString(m, ['symbol']) ?? '',
      symbolName:
          readString(m, ['symbolName']) ?? readString(m, ['symbol']) ?? '',
      category: readString(m, ['category', 'exchange', 'dataRelatedTo']) ?? '',
      expiryDate: readString(m, ['expiryDate', 'expiry_date']) ?? '',
      currentTime: readString(m, ['current_time', 'updated_at']) ?? '',
      change: readDynamic(m, ['change']) ?? 0.0,
      openInterest: readDynamic(m, ['openInterest']) ?? 0.0,
      upperCKT: readDynamic(m, ['upperCKT']) ?? 0.0,
      lowerCKT: readDynamic(m, ['lowerCKT']) ?? 0.0,
      averageTradePrice: readDynamic(m, ['averageTradePrice', 'ltp']) ?? 0.0,
      lastBuy: m['lastBuy'] != null
          ? LastBuy.fromJson(m['lastBuy'] as Map<String, dynamic>?)
          : LastBuy(),
      lastSell: m['lastSell'] != null
          ? LastBuy.fromJson(m['lastSell'] as Map<String, dynamic>?)
          : LastBuy(),
      lotSize: m['lotSize'] is int
          ? m['lotSize'] ?? 0
          : int.tryParse(m['lotSize']?.toString() ?? '') ?? 0,
      ohlc: ohlcRecord,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['symbolKey'] = symbolKey;
    data['watchlist'] = watchlist;
    data['receivedSymbol'] = receivedSymbol;
    data['symbol'] = symbol;
    data['symbolName'] = symbolName;
    data['category'] = category;
    data['expiryDate'] = expiryDate;
    data['current_time'] = currentTime;
    data['change'] = change;
    data['openInterest'] = openInterest;
    data['upperCKT'] = upperCKT;
    data['lowerCKT'] = lowerCKT;
    data['averageTradePrice'] = averageTradePrice;
    data['lastBuy'] = lastBuy.toJson();
    data['lastSell'] = lastSell.toJson();
    data['lotSize'] = lotSize;
    data['ohlc'] = ohlc.toJson();
    return data;
  }

  ResponseGetRecord copyWith({
    String? symbolKey,
    int? watchlist,
    String? receivedSymbol,
    String? symbol,
    String? symbolName,
    String? category,
    String? expiryDate,
    String? currentTime,
    dynamic change,
    dynamic openInterest,
    dynamic upperCKT,
    dynamic lowerCKT,
    dynamic averageTradePrice,
    LastBuy? lastBuy,
    LastBuy? lastSell,
    int? lotSize,
    OhlcGetRecord? ohlc,
  }) {
    return ResponseGetRecord(
      symbolKey: symbolKey ?? this.symbolKey,
      watchlist: watchlist ?? this.watchlist,
      receivedSymbol: receivedSymbol ?? this.receivedSymbol,
      symbol: symbol ?? this.symbol,
      symbolName: symbolName ?? this.symbolName,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      currentTime: currentTime ?? this.currentTime,
      change: change ?? this.change,
      openInterest: openInterest ?? this.openInterest,
      upperCKT: upperCKT ?? this.upperCKT,
      lowerCKT: lowerCKT ?? this.lowerCKT,
      averageTradePrice: averageTradePrice ?? this.averageTradePrice,
      lastBuy: lastBuy ?? this.lastBuy,
      lastSell: lastSell ?? this.lastSell,
      lotSize: lotSize ?? this.lotSize,
      ohlc: ohlc ?? this.ohlc,
    );
  }
}

class LastBuy {
  final dynamic price;
  final int quantity;
  final int orders;

  LastBuy({
    this.price = 0.0,
    this.quantity = 0,
    this.orders = 0,
  });

  factory LastBuy.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LastBuy();
    }
    return LastBuy(
      price: json['price'] ?? 0.0,
      quantity: json['quantity'] is int
          ? json['quantity'] ?? 0
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      orders: json['orders'] is int
          ? json['orders'] ?? 0
          : int.tryParse(json['orders']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['quantity'] = quantity;
    data['orders'] = orders;
    return data;
  }

  LastBuy copyWith({
    dynamic price,
    int? quantity,
    int? orders,
  }) {
    return LastBuy(
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      orders: orders ?? this.orders,
    );
  }
}

class OhlcGetRecord {
  final dynamic high;
  final dynamic low;
  final dynamic close;
  final dynamic open;
  final dynamic volume;
  final dynamic salePrice;
  final dynamic buyPrice;
  final dynamic lastPrice;

  OhlcGetRecord({
    this.high = 0.0,
    this.low = 0.0,
    this.close = 0.0,
    this.open = 0.0,
    this.volume = 0.0,
    this.salePrice = 0.0,
    this.buyPrice = 0.0,
    this.lastPrice = 0.0,
  });

  factory OhlcGetRecord.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OhlcGetRecord();
    }
    return OhlcGetRecord(
      high: parseDouble(json['high']) ?? 0.0,
      low: parseDouble(json['low']) ?? 0.0,
      close: parseDouble(json['close']) ?? 0.0,
      open: parseDouble(json['open']) ?? 0.0,
      volume: parseDouble(json['volume']) ?? 0.0,
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
    data['volume'] = volume;
    data['sale_price'] = salePrice;
    data['buy_price'] = buyPrice;
    data['last_price'] = lastPrice;
    return data;
  }

  OhlcGetRecord copyWith({
    dynamic high,
    dynamic low,
    dynamic close,
    dynamic open,
    dynamic volume,
    dynamic salePrice,
    dynamic buyPrice,
    dynamic lastPrice,
  }) {
    return OhlcGetRecord(
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      open: open ?? this.open,
      volume: volume ?? this.volume,
      salePrice: salePrice ?? this.salePrice,
      buyPrice: buyPrice ?? this.buyPrice,
      lastPrice: lastPrice ?? this.lastPrice,
    );
  }
}
