class ActivePortfolioSocketModel {
  int? status;
  String? activity;
  AccountStatics? accountStatics;
  List<Response>? response;

  ActivePortfolioSocketModel({
    this.status,
    this.activity,
    this.accountStatics,
    this.response,
  });

  ActivePortfolioSocketModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    activity = json['activity'];
    accountStatics = json['accountStatics'] != null
        ? new AccountStatics.fromJson(json['accountStatics'])
        : null;
    if (json['response'] != null) {
      response = <Response>[];
      json['response'].forEach((v) {
        response!.add(new Response.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['activity'] = this.activity;
    if (this.accountStatics != null) {
      data['accountStatics'] = this.accountStatics!.toJson();
    }
    if (this.response != null) {
      data['response'] = this.response!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AccountStatics {
  num? ledgerBalance;
  num? marginAvailable;
  num? activeProfitLoss;
  num? m2m;
  num? requiredHoldingMargin;

  AccountStatics({
    this.ledgerBalance,
    this.marginAvailable,
    this.activeProfitLoss,
    this.m2m,
    this.requiredHoldingMargin,
  });

  AccountStatics.fromJson(Map<String, dynamic> json) {
    ledgerBalance = (json['ledgerBalance'] is num)
        ? json['ledgerBalance']
        : num.tryParse(json['ledgerBalance'].toString());
    marginAvailable = (json['marginAvailable'] is num)
        ? json['marginAvailable']
        : num.tryParse(json['marginAvailable'].toString());
    activeProfitLoss = (json['activeProfitLoss'] is num)
        ? json['activeProfitLoss']
        : num.tryParse(json['activeProfitLoss'].toString());
    m2m = (json['m2m'] is num)
        ? json['m2m']
        : num.tryParse(json['m2m'].toString());
    requiredHoldingMargin = (json['requiredHoldingMargin'] is num)
        ? json['requiredHoldingMargin']
        : num.tryParse(json['requiredHoldingMargin'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ledgerBalance'] = this.ledgerBalance;
    data['marginAvailable'] = this.marginAvailable;
    data['activeProfitLoss'] = this.activeProfitLoss;
    data['m2m'] = this.m2m;
    data['requiredHoldingMargin'] = this.requiredHoldingMargin;
    return data;
  }
}

class Response {
  String? symbolKey;
  String? symbol;
  String? symbolName;
  String? exchange;
  String? category;
  String? expiryDate;
  String? currentTime;
  int? token;
  int? lotSize;
  int? maxQuantity;
  dynamic change;
  dynamic openInterest;
  dynamic upperCKT;
  dynamic lowerCKT;
  dynamic averageTradePrice;
  LastBuy? lastBuy;
  LastBuy? lastSell;
  Ohlc? ohlc;
  dynamic tradePrice;
  int? qty;
  int? tradeMethod;
  String? dataRelatedTo;
  dynamic livePrice;
  dynamic buyPrice;
  dynamic sellPrice;
  dynamic currentMarketPrice;
  dynamic profitLoss;
  dynamic margin;
  dynamic marginHolding;
  dynamic tradeM2M;

  Response({
    this.symbolKey,
    this.symbol,
    this.symbolName,
    this.exchange,
    this.category,
    this.expiryDate,
    this.currentTime,
    this.token,
    this.lotSize,
    this.maxQuantity,
    this.change,
    this.openInterest,
    this.upperCKT,
    this.lowerCKT,
    this.averageTradePrice,
    this.lastBuy,
    this.lastSell,
    this.ohlc,
    this.tradePrice,
    this.qty,
    this.tradeMethod,
    this.dataRelatedTo,
    this.livePrice,
    this.buyPrice,
    this.sellPrice,
    this.currentMarketPrice,
    this.profitLoss,
    this.margin,
    this.marginHolding,
    this.tradeM2M,
  });

  Response.fromJson(Map<String, dynamic> json) {
    symbolKey = json['symbolKey'];
    symbol = json['symbol'];
    symbolName = json['symbolName'];
    exchange = json['exchange'];
    category = json['category'];
    expiryDate = json['expiryDate'];
    currentTime = json['current_time'];
    token = json['token'];
    lotSize = json['lotSize'];
    maxQuantity = json['maxQuantity'];
    change = json['change'];
    openInterest = json['openInterest'];
    upperCKT = json['upperCKT'];
    lowerCKT = json['lowerCKT'];
    averageTradePrice = json['averageTradePrice'];
    lastBuy = json['lastBuy'] != null
        ? new LastBuy.fromJson(json['lastBuy'])
        : null;
    lastSell = json['lastSell'] != null
        ? new LastBuy.fromJson(json['lastSell'])
        : null;
    ohlc = json['ohlc'] != null ? new Ohlc.fromJson(json['ohlc']) : null;
    tradePrice = json['tradePrice'];
    qty = json['qty'];
    tradeMethod = json['tradeMethod'];
    dataRelatedTo = json['dataRelatedTo'];
    livePrice = json['livePrice'];
    buyPrice = json['buyPrice'];
    sellPrice = json['sellPrice'];
    currentMarketPrice = json['currentMarketPrice'];
    profitLoss = json['profitLoss'];
    margin = json['margin'];
    marginHolding = json['marginHolding'];
    tradeM2M = json['tradeM2M'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['symbolKey'] = this.symbolKey;
    data['symbol'] = this.symbol;
    data['symbolName'] = this.symbolName;
    data['exchange'] = this.exchange;
    data['category'] = this.category;
    data['expiryDate'] = this.expiryDate;
    data['current_time'] = this.currentTime;
    data['token'] = this.token;
    data['lotSize'] = this.lotSize;
    data['maxQuantity'] = this.maxQuantity;
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
    if (this.ohlc != null) {
      data['ohlc'] = this.ohlc!.toJson();
    }
    data['tradePrice'] = this.tradePrice;
    data['qty'] = this.qty;
    data['tradeMethod'] = this.tradeMethod;
    data['dataRelatedTo'] = this.dataRelatedTo;
    data['livePrice'] = this.livePrice;
    data['buyPrice'] = this.buyPrice;
    data['sellPrice'] = this.sellPrice;
    data['currentMarketPrice'] = this.currentMarketPrice;
    data['profitLoss'] = this.profitLoss;
    data['margin'] = this.margin;
    data['marginHolding'] = this.marginHolding;
    data['tradeM2M'] = this.tradeM2M;
    return data;
  }
}

class LastBuy {
  dynamic price;
  int? quantity;
  dynamic orders;

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

class Ohlc {
  dynamic open;
  dynamic high;
  dynamic low;
  dynamic close;
  dynamic volume;
  dynamic lastPrice;
  dynamic buyPrice;
  dynamic salePrice;

  Ohlc({
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
    this.lastPrice,
    this.buyPrice,
    this.salePrice,
  });

  Ohlc.fromJson(Map<String, dynamic> json) {
    open = json['open'];
    high = json['high'];
    low = json['low'];
    close = json['close'];
    volume = json['volume'];
    lastPrice = json['last_price'];
    buyPrice = json['buy_price'];
    salePrice = json['sale_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['open'] = this.open;
    data['high'] = this.high;
    data['low'] = this.low;
    data['close'] = this.close;
    data['volume'] = this.volume;
    data['last_price'] = this.lastPrice;
    data['buy_price'] = this.buyPrice;
    data['sale_price'] = this.salePrice;
    return data;
  }
}
