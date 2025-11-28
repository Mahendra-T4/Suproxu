class ClosePortfolioStockEntity {
  int? status;
  List<Record>? record;
  String? message;

  ClosePortfolioStockEntity({this.status, this.record, this.message});

  ClosePortfolioStockEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['record'] != null) {
      record = <Record>[];
      json['record'].forEach((v) {
        record!.add(new Record.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.record != null) {
      data['record'] = this.record!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Record {
  String? symbolName;
  String? dataRelatedTo;
  dynamic buyPrice;
  dynamic salePrice;
  String? stockQty;
  dynamic profitLoss;
  dynamic brokerageValue;
  dynamic totalBuyPrice;
  dynamic totalSalePrice;
  dynamic closeMargin;

  Record(
      {this.symbolName,
      this.dataRelatedTo,
      this.buyPrice,
      this.salePrice,
      this.stockQty,
      this.brokerageValue,
      this.profitLoss,
      this.totalBuyPrice,
      this.totalSalePrice,
      this.closeMargin});

  Record.fromJson(Map<String, dynamic> json) {
    symbolName = json['symbolName'];
    dataRelatedTo = json['dataRelatedTo'];
    buyPrice = json['buyPrice'] ?? 0.0;
    salePrice = json['salePrice'] ?? 0.0;
    stockQty = json['stockQty'];
    brokerageValue = json['brokerageValue'] ?? 0.0;
    profitLoss = json['profitLoss'] ?? 0.0;
    totalBuyPrice = json['totalBuyPrice'] ?? 0.0;
    totalSalePrice = json['totalSalePrice'] ?? 0.0;
    closeMargin = json['closeMargin'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['symbolName'] = this.symbolName;
    data['dataRelatedTo'] = this.dataRelatedTo;
    data['buyPrice'] = this.buyPrice;
    data['salePrice'] = this.salePrice;
    data['stockQty'] = this.stockQty;
    data['brokerageValue'] = this.brokerageValue;
    data['profitLoss'] = this.profitLoss;
    data['totalBuyPrice'] = this.totalBuyPrice;
    data['totalSalePrice'] = this.totalSalePrice;
    data['closeMargin'] = this.closeMargin;
    return data;
  }
}
