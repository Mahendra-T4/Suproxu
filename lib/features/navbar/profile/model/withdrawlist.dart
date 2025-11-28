class WithdrawList {
  int? status;
  List<Record>? record;
  String? message;

  WithdrawList({this.status, this.record, this.message});

  WithdrawList.fromJson(Map<String, dynamic> json) {
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
  String? transactionStatus;

  Record(
      {this.transactionDate, this.transactionAmount, this.transactionStatus});

  Record.fromJson(Map<String, dynamic> json) {
    transactionDate = json['transactionDate'];
    transactionAmount = json['transactionAmount'];
    transactionStatus = json['transactionStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionDate'] = this.transactionDate;
    data['transactionAmount'] = this.transactionAmount;
    data['transactionStatus'] = this.transactionStatus;
    return data;
  }
}