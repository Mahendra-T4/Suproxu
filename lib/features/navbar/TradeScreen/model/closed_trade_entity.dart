class ClosedTradeEntity {
  int? status;
  List<Record>? record;
  String? message;

  ClosedTradeEntity({this.status, this.record, this.message});

  ClosedTradeEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['record'] != null) {
      record = <Record>[];
      json['record'].forEach((v) {
        record!.add(Record.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (record != null) {
      data['record'] = record!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Record {
  dynamic symbolName;
  dynamic symbolKey;
  dynamic dataRelatedTo;
  dynamic buyPrice;
  dynamic salePrice;
  dynamic stockQty;
  dynamic profitLoss;
  dynamic closeDate;
  dynamic closeTime;
  dynamic totalBuyPrice;

  dynamic totalSalePrice;
  dynamic closeMargin;
  dynamic brokerageValue;

  Record(
      {this.symbolName,
      this.symbolKey,
      this.dataRelatedTo,
      this.buyPrice,
      this.salePrice,
      this.stockQty,
      this.profitLoss,
      this.closeDate,
      this.closeTime,
      this.totalBuyPrice,
      this.totalSalePrice,
      this.closeMargin,
      this.brokerageValue});

  Record.fromJson(Map<String, dynamic> json) {
    symbolName = json['symbolName'];
    symbolKey = json['symbolKey'];
    dataRelatedTo = json['dataRelatedTo'];
    buyPrice = json['buyPrice'];
    salePrice = json['salePrice'];
    stockQty = json['stockQty'];
    profitLoss = json['profitLoss'];
    closeDate = json['closeDate'];
    closeTime = json['closeTime'];
    totalBuyPrice = json['totalBuyPrice'];
    totalSalePrice = json['totalSalePrice'];
    closeMargin = json['closeMargin'];
    brokerageValue = json['brokerageValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['symbolName'] = symbolName;
    data['symbolKey'] = symbolKey;
    data['dataRelatedTo'] = dataRelatedTo;
    data['buyPrice'] = buyPrice;
    data['salePrice'] = salePrice;
    data['stockQty'] = stockQty;
    data['profitLoss'] = profitLoss;
    data['closeDate'] = closeDate;
    data['closeTime'] = closeTime;
    data['totalBuyPrice'] = totalBuyPrice;
    data['totalSalePrice'] = totalSalePrice;
    data['closeMargin'] = closeMargin;
    data['brokerageValue'] = this.brokerageValue;
    return data;
  }
}
