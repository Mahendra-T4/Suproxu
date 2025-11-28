class BalanceLogModel {
  int? status;
  List<Record>? record;
  String? message;

  BalanceLogModel({this.status, this.record, this.message});

  BalanceLogModel.fromJson(Map<String, dynamic> json) {
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
  String? transactionDate;
  int? transactionAmount;

  Record({this.transactionDate, this.transactionAmount});

  Record.fromJson(Map<String, dynamic> json) {
    transactionDate = json['transactionDate'];
    transactionAmount = json['transactionAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionDate'] = this.transactionDate;
    data['transactionAmount'] = this.transactionAmount;
    return data;
  }
}
