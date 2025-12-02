import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/Rules/model/rules_model.dart';

class RulesRepository {
  Future<RulesModel> fetchRules() async {
    RulesModel rulesModel = RulesModel();
    try {
      DatabaseService databaseService = DatabaseService();
      final userKey = await databaseService.getUserData(key: userIDKey);
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;
      final deviceID = deviceInfo.id.toString();
      final response = await http.post(
        Uri.parse(superTradeBaseApiEndPointUrl),
        body: {'activity': 'rules', 'userKey': userKey, 'deviceID': deviceID},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        rulesModel = RulesModel.fromJson(jsonData);
        // Process the response as needed
        log('Rules fetched successfully: ${response.body}');
      } else {
        log('Failed to fetch rules. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString(), name: 'Error fetching rules');
    }
    return rulesModel;
  }
}
