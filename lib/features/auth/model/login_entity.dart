class LoginModel {
  int? status;
  String? message;
  Record? record;

  LoginModel({this.status, this.message, this.record});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    record = json['record'] != null
        ? new Record.fromJson(json['record'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.record != null) {
      data['record'] = this.record!.toJson();
    }
    return data;
  }
}

class Record {
  String? userFirstName;
  String? userLastName;
  String? userEmailID;
  String? userMobileNumber;
  String? userAlternateNumber;
  dynamic userBalance;
  String? userImage;
  dynamic userActiveTrade;
  dynamic userCloseTrade;
  dynamic userPendingTrade;
  dynamic userProfitLoss;
  String? userKey;
  String? agentQR;
  String? agentBankName;
  String? agentHolderName;
  String? agentAccountNumber;
  String? agentIFSCCode;
  int? updatePassword;

  Record({
    this.userFirstName,
    this.userLastName,
    this.userEmailID,
    this.userMobileNumber,
    this.userAlternateNumber,
    this.userBalance,
    this.userImage,
    this.userActiveTrade,
    this.userCloseTrade,
    this.userPendingTrade,
    this.userProfitLoss,
    this.userKey,
    this.agentQR,
    this.agentBankName,
    this.agentHolderName,
    this.agentAccountNumber,
    this.agentIFSCCode,
    this.updatePassword,
  });

  Record.fromJson(Map<String, dynamic> json) {
    userFirstName = json['userFirstName'];
    userLastName = json['userLastName'];
    userEmailID = json['userEmailID'];
    userMobileNumber = json['userMobileNumber'];
    userAlternateNumber = json['userAlternateNumber'];
    userBalance = json['userBalance'];
    userImage = json['userImage'];
    userActiveTrade = json['userActiveTrade'];
    userCloseTrade = json['userCloseTrade'];
    userPendingTrade = json['userPendingTrade'];
    userProfitLoss = json['userProfitLoss'];
    userKey = json['userKey'];
    agentQR = json['agentQR'];
    agentBankName = json['agentBankName'];
    agentHolderName = json['agentHolderName'];
    agentAccountNumber = json['agentAccountNumber'];
    agentIFSCCode = json['agentIFSCCode'];
    updatePassword = json['updatePassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userFirstName'] = this.userFirstName;
    data['userLastName'] = this.userLastName;
    data['userEmailID'] = this.userEmailID;
    data['userMobileNumber'] = this.userMobileNumber;
    data['userAlternateNumber'] = this.userAlternateNumber;
    data['userBalance'] = this.userBalance;
    data['userImage'] = this.userImage;
    data['userActiveTrade'] = this.userActiveTrade;
    data['userCloseTrade'] = this.userCloseTrade;
    data['userPendingTrade'] = this.userPendingTrade;
    data['userProfitLoss'] = this.userProfitLoss;
    data['userKey'] = this.userKey;
    data['agentQR'] = this.agentQR;
    data['agentBankName'] = this.agentBankName;
    data['agentHolderName'] = this.agentHolderName;
    data['agentAccountNumber'] = this.agentAccountNumber;
    data['agentIFSCCode'] = this.agentIFSCCode;
    data['updatePassword'] = this.updatePassword;
    return data;
  }
}
