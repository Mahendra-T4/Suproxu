class ChangePasswordEntity {
  int? status;
  String? message;

  ChangePasswordEntity({this.status, this.message});

  ChangePasswordEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}
