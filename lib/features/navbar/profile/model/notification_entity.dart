class NotificationEntity {
  int? status;
  List<Notification>? notification;
  String? message;

  NotificationEntity({this.status, this.notification, this.message});

  NotificationEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['record'] != null) {
      notification = <Notification>[];
      json['record'].forEach((v) {
        notification!.add(Notification.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (notification != null) {
      data['record'] = notification!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Notification {
  String? notificationMsg;
  String? notificationDate;

  Notification({this.notificationMsg, this.notificationDate});

  Notification.fromJson(Map<String, dynamic> json) {
    notificationMsg = json['notificationMsg'];
    notificationDate = json['notificationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notificationMsg'] = notificationMsg;
    data['notificationDate'] = notificationDate;
    return data;
  }
}
