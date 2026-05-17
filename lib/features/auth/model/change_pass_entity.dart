class ChangePasswordEntity {
  int? status;
  String? message;
  String? redirect;

  ChangePasswordEntity({this.status, this.message, this.redirect});

  ChangePasswordEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    redirect = json['redirect'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['redirect'] = this.redirect;
    return data;
  }
}
