class RemoveWatchListSymbolsEntity {
  int? status;
  String? message;
  Record? record;

  RemoveWatchListSymbolsEntity({this.status, this.message, this.record});

  RemoveWatchListSymbolsEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    record = json['record'] != null ? Record.fromJson(json['record']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (record != null) {
      data['record'] = record!.toJson();
    }
    return data;
  }
}

class Record {
  int? tpWid;
  String? tpWsymbolkey;
  String? tpWexchange;
  String? tpWuser;
  String? tpWencryptkey;
  String? tpWcreatedon;
  int? tpWstatus;

  Record(
      {this.tpWid,
      this.tpWsymbolkey,
      this.tpWexchange,
      this.tpWuser,
      this.tpWencryptkey,
      this.tpWcreatedon,
      this.tpWstatus});

  Record.fromJson(Map<String, dynamic> json) {
    tpWid = json['tp_wid'];
    tpWsymbolkey = json['tp_wsymbolkey'];
    tpWexchange = json['tp_wexchange'];
    tpWuser = json['tp_wuser'];
    tpWencryptkey = json['tp_wencryptkey'];
    tpWcreatedon = json['tp_wcreatedon'];
    tpWstatus = json['tp_wstatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tp_wid'] = tpWid;
    data['tp_wsymbolkey'] = tpWsymbolkey;
    data['tp_wexchange'] = tpWexchange;
    data['tp_wuser'] = tpWuser;
    data['tp_wencryptkey'] = tpWencryptkey;
    data['tp_wcreatedon'] = tpWcreatedon;
    data['tp_wstatus'] = tpWstatus;
    return data;
  }
}
