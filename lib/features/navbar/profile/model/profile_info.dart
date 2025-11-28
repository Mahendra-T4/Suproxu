class ProfileInfoModel {
  int? status;
  String? message;
  NseDetails? nseDetails;
  McxDetails? mcxDetails;

  ProfileInfoModel(
      {this.status, this.message, this.nseDetails, this.mcxDetails});

  ProfileInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    nseDetails = json['nseDetails'] != null
        ? new NseDetails.fromJson(json['nseDetails'])
        : null;
    mcxDetails = json['mcxDetails'] != null
        ? new McxDetails.fromJson(json['mcxDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.nseDetails != null) {
      data['nseDetails'] = this.nseDetails!.toJson();
    }
    if (this.mcxDetails != null) {
      data['mcxDetails'] = this.mcxDetails!.toJson();
    }
    return data;
  }
}

class NseDetails {
  dynamic nseBrokerage;
  dynamic nseInterday;
  dynamic nseHolding;

  NseDetails({this.nseBrokerage, this.nseInterday, this.nseHolding});

  NseDetails.fromJson(Map<String, dynamic> json) {
    nseBrokerage = json['nseBrokerage'];
    nseInterday = json['nseInterday'];
    nseHolding = json['nseHolding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nseBrokerage'] = this.nseBrokerage;
    data['nseInterday'] = this.nseInterday;
    data['nseHolding'] = this.nseHolding;
    return data;
  }
}

class McxDetails {
  int? mcxBrokerage;
  List<MarginHolding>? marginHolding;
  List<MarginUsed>? marginUsed;

  McxDetails({this.mcxBrokerage, this.marginHolding, this.marginUsed});

  McxDetails.fromJson(Map<String, dynamic> json) {
    mcxBrokerage = json['mcxBrokerage'];
    if (json['marginHolding'] != null) {
      marginHolding = <MarginHolding>[];
      json['marginHolding'].forEach((v) {
        marginHolding!.add(new MarginHolding.fromJson(v));
      });
    }
    if (json['marginUsed'] != null) {
      marginUsed = <MarginUsed>[];
      json['marginUsed'].forEach((v) {
        marginUsed!.add(new MarginUsed.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mcxBrokerage'] = this.mcxBrokerage;
    if (this.marginHolding != null) {
      data['marginHolding'] =
          this.marginHolding!.map((v) => v.toJson()).toList();
    }
    if (this.marginUsed != null) {
      data['marginUsed'] = this.marginUsed!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MarginHolding {
  String? stymbolName;
  dynamic marginIntraday;

  MarginHolding({this.stymbolName, this.marginIntraday});

  MarginHolding.fromJson(Map<String, dynamic> json) {
    stymbolName = json['stymbolName'];
    marginIntraday = json['marginIntraday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stymbolName'] = this.stymbolName;
    data['marginIntraday'] = this.marginIntraday;
    return data;
  }
}

class MarginUsed {
  String? stymbolName;
  int? marginHolding;

  MarginUsed({this.stymbolName, this.marginHolding});

  MarginUsed.fromJson(Map<String, dynamic> json) {
    stymbolName = json['stymbolName'];
    marginHolding = json['marginHolding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stymbolName'] = this.stymbolName;
    data['marginHolding'] = this.marginHolding;
    return data;
  }
}
