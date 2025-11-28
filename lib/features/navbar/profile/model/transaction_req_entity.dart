class TransRequestListEntity {
  int? status;
  List<Record>? record;
  String? message;

  TransRequestListEntity({this.status, this.record, this.message});

  TransRequestListEntity.fromJson(Map<String, dynamic> json) {
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
  String? transactionDate;
  int? transactionAmount;
  String? utrNumber;
  String? transactionProof;
  String? transactionNote;
  String? transactionStatus;

  Record(
      {this.transactionDate,
      this.transactionAmount,
      this.utrNumber,
      this.transactionProof,
      this.transactionNote,
      this.transactionStatus});

  Record.fromJson(Map<String, dynamic> json) {
    transactionDate = json['transactionDate'];
    transactionAmount = json['transactionAmount'];
    utrNumber = json['utrNumber'];
    transactionProof = json['transactionProof'];
    transactionNote = json['transactionNote'];
    transactionStatus = json['transactionStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transactionDate'] = transactionDate;
    data['transactionAmount'] = transactionAmount;
    data['utrNumber'] = utrNumber;
    data['transactionProof'] = transactionProof;
    data['transactionNote'] = transactionNote;
    data['transactionStatus'] = transactionStatus;
    return data;
  }
}
