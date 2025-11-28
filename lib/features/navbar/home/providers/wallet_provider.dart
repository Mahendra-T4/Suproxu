import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/profile/model/balence_entity.dart';

final walletProvider = StreamProvider<BalanceEntity>((ref) async* {
  final url = Uri.parse(notificationApiEndPointUrl);
  DatabaseService databaseService = DatabaseService();
  ref.keepAlive();
  while (true) {
    BalanceEntity balanceEntity = BalanceEntity();
    final userID = await databaseService.getUserData(key: userIDKey);
    try {
      final response = await http
          .post(url, body: {'activity': 'get-statics', 'userKey': userID});
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        balanceEntity = BalanceEntity.fromJson(jsonData);
        log('Balance Response : ${balanceEntity.message.toString()}');
      }
    } catch (e) {
      log('Balance Error : $e');
    }
    yield balanceEntity;
    await Future.delayed(
        const Duration(milliseconds: 400)); // refresh every 5 seconds
  }
});
