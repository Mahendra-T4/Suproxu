class RulesModel {
  int? status;
  String? pageTitle;
  String? pageDescription;

  RulesModel({this.status, this.pageTitle, this.pageDescription});

  RulesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    pageTitle = json['pageTitle'];
    pageDescription = json['pageDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['pageTitle'] = this.pageTitle;
    data['pageDescription'] = this.pageDescription;
    return data;
  }
}
