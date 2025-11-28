class ActivePortfolioStockEntity {
  int? status;
  List<Response>? response;
  String? message;
  ActiveStatics? activeStatics;

  ActivePortfolioStockEntity(
      {this.status, this.response, this.message, this.activeStatics});

  ActivePortfolioStockEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['response'] != null) {
      response = <Response>[];
      json['response'].forEach((v) {
        response!.add(new Response.fromJson(v));
      });
    }
    message = json['message'];
    activeStatics = json['activeStatics'] != null
        ? new ActiveStatics.fromJson(json['activeStatics'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.response != null) {
      data['response'] = this.response!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    if (this.activeStatics != null) {
      data['activeStatics'] = this.activeStatics!.toJson();
    }
    return data;
  }
}

class Response {
  String? symbolName;
  String? symbolKey;
  String? dataRelatedTo;
  dynamic tradePrice;
  String? orderMethod;
  int? tradeMethod;
  String? stockQty;
  dynamic margin;
  dynamic marginHolding;
  LiveData? liveData;

  Response(
      {this.symbolName,
      this.symbolKey,
      this.dataRelatedTo,
      this.tradePrice,
      this.orderMethod,
      this.tradeMethod,
      this.stockQty,
      this.margin,
      this.marginHolding,
      this.liveData});

  Response.fromJson(Map<String, dynamic> json) {
    symbolName = json['symbolName'];
    symbolKey = json['symbolKey'];
    dataRelatedTo = json['dataRelatedTo'];
    tradePrice = json['tradePrice'] ?? 0.0;
    orderMethod = json['orderMethod'];
    tradeMethod = json['tradeMethod'];
    stockQty = json['stockQty'];
    margin = json['margin'] ?? 0.0;
    marginHolding = json['marginHolding'] ?? 0.0;

    liveData = json['liveData'] != null
        ? new LiveData.fromJson(json['liveData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['symbolName'] = this.symbolName;
    data['symbolKey'] = this.symbolKey;
    data['dataRelatedTo'] = this.dataRelatedTo;
    data['tradePrice'] = this.tradePrice;
    data['orderMethod'] = this.orderMethod;
    data['tradeMethod'] = this.tradeMethod;
    data['stockQty'] = this.stockQty;
    data['margin'] = this.margin;
    data['marginHolding'] = this.marginHolding;
    if (this.liveData != null) {
      data['liveData'] = this.liveData!.toJson();
    }
    return data;
  }
}

class LiveData {
  dynamic currentMarketPrice;
  int? lotSize;
  dynamic profitLoss;
  dynamic tradeM2M;

  LiveData(
      {this.currentMarketPrice, this.lotSize, this.profitLoss, this.tradeM2M});

  LiveData.fromJson(Map<String, dynamic> json) {
    currentMarketPrice = json['currentMarketPrice'];
    lotSize = json['lotSize'];
    profitLoss = json['profitLoss'] ?? 0.0;
    tradeM2M = json['tradeM2M'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentMarketPrice'] = this.currentMarketPrice;
    data['lotSize'] = this.lotSize;
    data['profitLoss'] = this.profitLoss;

    data['tradeM2M'] = this.tradeM2M;
    return data;
  }
}

class ActiveStatics {
  dynamic ledgerBalance;
  dynamic marginAvailable;
  dynamic m2m;
  dynamic activeProfitLoss;

  ActiveStatics(
      {this.ledgerBalance,
      this.marginAvailable,
      this.m2m,
      this.activeProfitLoss});

  ActiveStatics.fromJson(Map<String, dynamic> json) {
    ledgerBalance = json['ledgerBalance'];
    marginAvailable = json['marginAvailable'];
    m2m = json['m2m'];
    activeProfitLoss ??= json['activeProfitLoss'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ledgerBalance'] = this.ledgerBalance;
    data['marginAvailable'] = this.marginAvailable;
    data['m2m'] = this.m2m;
    data['activeProfitLoss'] = this.activeProfitLoss;
    return data;
  }
}
