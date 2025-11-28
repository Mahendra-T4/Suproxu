import 'dart:async';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'dart:convert';

import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/profile/model/notification_entity.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _unreadCountController = StreamController<int>.broadcast();
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  Timer? _pollingTimer;

  void startPolling() {
    // Fetch immediately when starting
    fetchUnreadCount();
    // Then set up periodic polling
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchUnreadCount();
    });
  }

  Future<void> fetchUnreadCount() async {
    try {
      DatabaseService databaseService = DatabaseService();
      final uKey = await databaseService.getUserData(key: userIDKey);

      if (uKey == null) {
        log('User key is null');
        _safeAdd(0);
        return;
      }

      final response = await http.post(
        Uri.parse(notificationApiEndPointUrl),
        body: {
          "activity": "notification",
          "userKey": uKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final notificationEntity = NotificationEntity.fromJson(jsonResponse);

        if (jsonResponse['status'] == 1) {
          final newCount = notificationEntity.notification?.length ?? 0;
          final oldMsg =
              await databaseService.getUserData(key: notifyKey) ?? '0';
          final oldCount = int.tryParse(oldMsg.toString()) ?? 0;

          // Save new count
          await databaseService.saveUserData(
            key: notifyKey,
            value: newCount.toString(),
          );

          // Calculate unread
          final unreadCount = newCount - oldCount;
          _safeAdd(unreadCount < 0 ? 0 : unreadCount);

          log('Notification Count - New: $newCount, Old: $oldCount, Unread: $unreadCount');
        } else {
          _safeAdd(0);
        }
      }
    } catch (e) {
      log('Notification fetch error: $e');
      _safeAdd(0);
    }
  }

  void _safeAdd(int count) {
    if (!_unreadCountController.isClosed) {
      _unreadCountController.add(count);
    }
  }

  void markAsRead() {
    _safeAdd(0);
    DatabaseService().saveUserData(key: notifyKey, value: '0');
  }

  void dispose() {
    _pollingTimer?.cancel();
    if (!_unreadCountController.isClosed) {
      _unreadCountController.close();
    }
  }
}
