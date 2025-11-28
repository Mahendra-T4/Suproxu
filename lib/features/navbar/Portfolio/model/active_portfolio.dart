class ActivePorfolioEntity {
  int? status;
  List<Response>? response;
  String? message;

  ActivePorfolioEntity({this.status, this.response, this.message});

  ActivePorfolioEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['response'] != null) {
      response = <Response>[];
      json['response'].forEach((v) {
        response!.add(Response.fromJson(v));
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

class Response {
  String? symbolKey;
  int? watchlist;
  String? receivedSymbol;
  String? symbol;
  String? symbolName;
  String? category;
  String? expiryDate;
  String? currentTime;
  dynamic change;
  Ohlc? ohlc;

  Response(
      {this.symbolKey,
      this.watchlist,
      this.receivedSymbol,
      this.symbol,
      this.symbolName,
      this.category,
      this.expiryDate,
      this.currentTime,
      this.change,
      this.ohlc});

  Response.fromJson(Map<String, dynamic> json) {
    symbolKey = json['symbolKey'];
    watchlist = json['watchlist'];
    receivedSymbol = json['receivedSymbol'];
    symbol = json['symbol'];
    symbolName = json['symbolName'];
    category = json['category'];
    expiryDate = json['expiryDate'];
    currentTime = json['current_time'];
    change = json['change'];
    ohlc = json['ohlc'] != null ? Ohlc.fromJson(json['ohlc']) : null;
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
    if (ohlc != null) {
      data['ohlc'] = ohlc!.toJson();
    }
    return data;
  }
}

class Ohlc {
  dynamic high;
  dynamic low;
  dynamic close;
  dynamic open;
  int? lotSize;
  dynamic volume;
  dynamic salePrice;
  dynamic buyPrice;
  dynamic lastPrice;

  Ohlc(
      {this.high,
      this.low,
      this.close,
      this.open,
      this.lotSize,
      this.volume,
      this.salePrice,
      this.buyPrice,
      this.lastPrice});

  Ohlc.fromJson(Map<String, dynamic> json) {
    high = _parseDouble(json['high']);
    low = _parseDouble(json['low']);
    close = _parseDouble(json['close']);
    open = _parseDouble(json['open']);
    lotSize = json['lot_size'];
    volume = _parseDouble(json['volume']);
    salePrice = _parseDouble(json['sale_price']);
    buyPrice = _parseDouble(json['buy_price']);
    lastPrice = _parseDouble(json['last_price']);
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
}
