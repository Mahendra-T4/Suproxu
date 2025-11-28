class StockListEntity {
  dynamic status;
  List<Stocks>? stocks;
  String? message;

  StockListEntity({this.status, this.stocks, this.message});

  StockListEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['record'] != null) {
      stocks = <Stocks>[];
      json['record'].forEach((v) {
        stocks!.add(Stocks.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (stocks != null) {
      data['record'] = stocks!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Stocks {
  int? categoryID;
  String? categoryName;
  String? categoryCode;

  Stocks({this.categoryID, this.categoryName, this.categoryCode});

  Stocks.fromJson(Map<String, dynamic> json) {
    categoryID = json['categoryID'];
    categoryName = json['categoryName'];
    categoryCode = json['categoryCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryID'] = categoryID;
    data['categoryName'] = categoryName;
    data['categoryCode'] = categoryCode;
    return data;
  }
}
