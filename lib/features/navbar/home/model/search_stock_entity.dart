class SearchStockEntity {
  int? status;
  List<SearchResponse>? response;
  String? message;

  SearchStockEntity({this.status, this.response, this.message});

  SearchStockEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['response'] != null) {
      response = <SearchResponse>[];
      json['response'].forEach((v) {
        response!.add(new SearchResponse.fromJson(v));
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

class SearchResponse {
  String? symbolKey;
  int? watchlist;
  String? receivedSymbol;
  String? symbol;
  String? symbolName;
  String? category;
  String? expiryDate;
  String? currentTime;
  double? change;
  int? openInterest;
  double? upperCKT;
  double? lowerCKT;
  double? averageTradePrice;
  LastBuy? lastBuy;
  LastBuy? lastSell;
  int? lotSize;
  SearchOhlc? ohlc;

  SearchResponse(
      {this.symbolKey,
      this.watchlist,
      this.receivedSymbol,
      this.symbol,
      this.symbolName,
      this.category,
      this.expiryDate,
      this.currentTime,
      this.change,
      this.openInterest,
      this.upperCKT,
      this.lowerCKT,
      this.averageTradePrice,
      this.lastBuy,
      this.lastSell,
      this.lotSize,
      this.ohlc});

  SearchResponse.fromJson(Map<String, dynamic> json) {
    symbolKey = json['symbolKey'];
    watchlist = json['watchlist'];
    receivedSymbol = json['receivedSymbol'];
    symbol = json['symbol'];
    symbolName = json['symbolName'];
    category = json['category'];
    expiryDate = json['expiryDate'];
    currentTime = json['current_time'];
    change = json['change'];
    openInterest = json['openInterest'];
    upperCKT = json['upperCKT'];
    lowerCKT = json['lowerCKT'];
    averageTradePrice = json['averageTradePrice'];
    lastBuy =
        json['lastBuy'] != null ? new LastBuy.fromJson(json['lastBuy']) : null;
    lastSell = json['lastSell'] != null
        ? new LastBuy.fromJson(json['lastSell'])
        : null;
    lotSize = json['lotSize'];
    ohlc = json['ohlc'] != null ? new SearchOhlc.fromJson(json['ohlc']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['symbolKey'] = this.symbolKey;
    data['watchlist'] = this.watchlist;
    data['receivedSymbol'] = this.receivedSymbol;
    data['symbol'] = this.symbol;
    data['symbolName'] = this.symbolName;
    data['category'] = this.category;
    data['expiryDate'] = this.expiryDate;
    data['current_time'] = this.currentTime;
    data['change'] = this.change;
    data['openInterest'] = this.openInterest;
    data['upperCKT'] = this.upperCKT;
    data['lowerCKT'] = this.lowerCKT;
    data['averageTradePrice'] = this.averageTradePrice;
    if (this.lastBuy != null) {
      data['lastBuy'] = this.lastBuy!.toJson();
    }
    if (this.lastSell != null) {
      data['lastSell'] = this.lastSell!.toJson();
    }
    data['lotSize'] = this.lotSize;
    if (this.ohlc != null) {
      data['ohlc'] = this.ohlc!.toJson();
    }
    return data;
  }
}

class LastBuy {
  double? price;
  int? quantity;
  int? orders;

  LastBuy({this.price, this.quantity, this.orders});

  LastBuy.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    quantity = json['quantity'];
    orders = json['orders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this.price;
    data['quantity'] = this.quantity;
    data['orders'] = this.orders;
    return data;
  }
}

class SearchOhlc {
  double? high;
  double? low;
  double? close;
  double? open;
  int? volume;
  double? salePrice;
  double? buyPrice;
  double? lastPrice;

  SearchOhlc(
      {this.high,
      this.low,
      this.close,
      this.open,
      this.volume,
      this.salePrice,
      this.buyPrice,
      this.lastPrice});

  SearchOhlc.fromJson(Map<String, dynamic> json) {
    high = json['high'];
    low = json['low'];
    close = json['close'];
    open = json['open'];
    volume = json['volume'];
    salePrice = json['sale_price'];
    buyPrice = json['buy_price'];
    lastPrice = json['last_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['high'] = this.high;
    data['low'] = this.low;
    data['close'] = this.close;
    data['open'] = this.open;
    data['volume'] = this.volume;
    data['sale_price'] = this.salePrice;
    data['buy_price'] = this.buyPrice;
    data['last_price'] = this.lastPrice;
    return data;
  }
}
