class LogoModel {
  int? status;
  String? logo;
  String? transparent;
  String? message;

  LogoModel({this.status, this.logo, this.transparent, this.message});

  LogoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    logo = json['logo'];
    transparent = json['transparent'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['logo'] = this.logo;
    data['transparent'] = this.transparent;
    data['message'] = this.message;
    return data;
  }
}
