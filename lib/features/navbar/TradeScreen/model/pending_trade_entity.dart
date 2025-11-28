class PendingTradeEntity {
  int? status;
  List<Record>? record;
  String? message;

  PendingTradeEntity({this.status, this.record, this.message});

  PendingTradeEntity.fromJson(Map<String, dynamic> json) {
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
  int? tradeID;
  String? symbolName;
  String? symbolKey;
  String? dataRelatedTo;
  dynamic stockPrice;
  String? orderMethod;
  int? tradeMethod;
  int? availableQty;
  String? currentDate;
  String? time;
  String? tradeKey;
  int? tradeStatus;

  Record(
      {this.tradeID,
      this.symbolName,
      this.symbolKey,
      this.dataRelatedTo,
      this.stockPrice,
      this.orderMethod,
      this.tradeMethod,
      this.availableQty,
      this.currentDate,
      this.time,
      this.tradeKey,
      this.tradeStatus});

  Record.fromJson(Map<String, dynamic> json) {
    tradeID = json['tradeID'];
    symbolName = json['symbolName'];
    symbolKey = json['symbolKey'];
    dataRelatedTo = json['dataRelatedTo'];
    stockPrice = json['stockPrice'];
    orderMethod = json['orderMethod'];
    tradeMethod = json['tradeMethod'];
    availableQty = json['availableQty'];
    currentDate = json['currentDate'];
    time = json['time'];
    tradeKey = json['tradeKey'];
    tradeStatus = json['tradeStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tradeID'] = this.tradeID;
    data['symbolName'] = this.symbolName;
    data['symbolKey'] = this.symbolKey;
    data['dataRelatedTo'] = this.dataRelatedTo;
    data['stockPrice'] = this.stockPrice;
    data['orderMethod'] = this.orderMethod;
    data['tradeMethod'] = this.tradeMethod;
    data['availableQty'] = this.availableQty;
    data['currentDate'] = this.currentDate;
    data['time'] = this.time;
    data['tradeKey'] = this.tradeKey;
    data['tradeStatus'] = this.tradeStatus;
    return data;
  }
}
