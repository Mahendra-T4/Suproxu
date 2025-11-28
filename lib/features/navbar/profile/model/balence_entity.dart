class BalanceEntity {
  int? status;
  List<Record>? record;
  String? message;

  BalanceEntity({this.status, this.record, this.message});

  BalanceEntity.fromJson(Map<String, dynamic> json) {
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
  dynamic availableBalance;
  dynamic activeTrade;
  dynamic closeTrade;
  dynamic pendingTrade;
  dynamic profitLoss;
  dynamic brokerageValue;
  dynamic netProfit;

  Record(
      {this.availableBalance,
      this.activeTrade,
      this.closeTrade,
      this.pendingTrade,
      this.profitLoss,
      this.brokerageValue,
      this.netProfit});

  Record.fromJson(Map<String, dynamic> json) {
    availableBalance = json['availableBalance'] ?? 0;
    activeTrade = json['activeTrade'] ?? 0;
    closeTrade = json['closeTrade'] ?? 0;
    pendingTrade = json['pendingTrade'] ?? 0;
    profitLoss = json['profitLoss'] ?? 0.0;
    brokerageValue = json['brokerageValue'] ?? 0.0;
    netProfit = json['netProfit'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['availableBalance'] = this.availableBalance;
    data['activeTrade'] = this.activeTrade;
    data['closeTrade'] = this.closeTrade;
    data['pendingTrade'] = this.pendingTrade;
    data['profitLoss'] = this.profitLoss;
    data['brokerageValue'] = this.brokerageValue;
    data['netProfit'] = this.netProfit;
    return data;
  }
}
