import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/service/device_service.dart';
import 'package:suproxu/features/navbar/profile/model/balence_entity.dart';
import 'package:suproxu/features/navbar/profile/model/notification_entity.dart';
import 'package:suproxu/features/navbar/profile/model/profile_info.dart';

typedef EitherHandler<T> = Either<String, T>;

class ProfileRepository {
  static final client = http.Client();
  static Map<String, dynamic>? profileJsonData;
  static List<Map<String, dynamic>> marginHolding = [];
  static List<Map<String, dynamic>> marginUsed = [];

  static Future<EitherHandler<NotificationEntity>> notification() async {
    final url = Uri.parse(notificationApiEndPointUrl);
    NotificationEntity notificationEntity = NotificationEntity();
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(url, body: {
        "activity": "notification",
        "deviceID": deviceID.toString(),
        "userKey": uKey
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log(jsonResponse['message']);
        notificationEntity = NotificationEntity.fromJson(jsonResponse);
        return right(notificationEntity);
      } else {
        return left('Notification not found');
      }
    } catch (e) {
      log('Notification Repository Error =>> $e');
      return left(e.toString());
    }
  }

  static Future<BalanceEntity> userWallet() async {
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    BalanceEntity balanceEntity = BalanceEntity();
    DatabaseService databaseService = DatabaseService();
    final userID = await databaseService.getUserData(key: userIDKey);
     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();

    try {
      final response = await http.post(url, body: {
        'activity': 'get-statics',
        "deviceID": deviceID.toString(),
        'userKey': userID
      });
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        balanceEntity = BalanceEntity.fromJson(jsonData);
        log('Balance Response : ${balanceEntity.message.toString()}');
      } else {
        throw Exception('Failed to load wallet data: ${response.statusCode}');
      }
    } catch (e) {
      log('Balance Error : $e');
      throw Exception('Failed to load wallet data: $e');
    }
    return balanceEntity;
  }

  static Future<ProfileInfoModel> profileInfo() async {
    ProfileInfoModel profileInfoModel = ProfileInfoModel();
    final url = Uri.parse(notificationApiEndPointUrl);
    DatabaseService databaseService = DatabaseService();
    final userID = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
    try {
      final response = await http.post(url, body: {
        'activity': 'margin-brokerage-details',
        "deviceID": deviceID.toString(),
        'userKey': userID.toString()
      });
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        profileInfoModel = ProfileInfoModel.fromJson(jsonData);
        profileJsonData = jsonData; // Store the profile data for later use
        // Access the nested data inside mcxDetails
        if (jsonData['mcxDetails'] != null) {
          marginHolding = List<Map<String, dynamic>>.from(
              jsonData['mcxDetails']['marginHolding'] ?? []);
          marginUsed = List<Map<String, dynamic>>.from(
              jsonData['mcxDetails']['marginUsed'] ?? []);
          log('Margin Holding: ${marginHolding.toString()}');
          log('Margin Used: ${marginUsed.toString()}');
        }
        log('Profile Info Response : ${profileInfoModel.message.toString()}');
      } else {
        log('Failed to load profile info');
      }
    } catch (e) {
      log('Profile Info Error : $e');
    }
    return profileInfoModel;
  }
}
