class StocksCategoryEntity {
  int? status;
  List<Record>? record;
  String? message;

  StocksCategoryEntity({this.status, this.record, this.message});

  StocksCategoryEntity.fromJson(Map<String, dynamic> json) {
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
  int? categoryID;
  String? categoryName;
  String? categoryCode;

  Record({this.categoryID, this.categoryName, this.categoryCode});

  Record.fromJson(Map<String, dynamic> json) {
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
