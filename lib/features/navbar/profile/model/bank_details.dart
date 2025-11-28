class BankDetails {
  int? status;
  BankRecord? bankRecord;
  String? message;

  BankDetails({this.status, this.bankRecord, this.message});

  BankDetails.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    bankRecord = json['bankDetails'] != null
        ? new BankRecord.fromJson(json['bankDetails'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.bankRecord != null) {
      data['bankDetails'] = this.bankRecord!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class BankRecord {
  int? bankID;
  String? bankName;
  String? accountHolder;
  String? accountNumber;
  String? ifscCode;
  String? qrCode;

  BankRecord(
      {this.bankID,
      this.bankName,
      this.accountHolder,
      this.accountNumber,
      this.ifscCode,
      this.qrCode});

  BankRecord.fromJson(Map<String, dynamic> json) {
    bankID = json['bankID'];
    bankName = json['bankName'];
    accountHolder = json['accountHolder'];
    accountNumber = json['accountNumber'];
    ifscCode = json['ifscCode'];
    qrCode = json['qr-code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bankID'] = this.bankID;
    data['bankName'] = this.bankName;
    data['accountHolder'] = this.accountHolder;
    data['accountNumber'] = this.accountNumber;
    data['ifscCode'] = this.ifscCode;
    data['qr-code'] = this.qrCode;
    return data;
  }
}
