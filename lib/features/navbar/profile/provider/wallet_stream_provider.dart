import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/profile/model/balence_entity.dart';

final walletProvider = StreamProvider<BalanceEntity>((ref) async* {
  final databaseService = DatabaseService();
  final userID = await databaseService.getUserData(key: userIDKey);
  final url = Uri.parse(superTradeBaseApiEndPointUrl);

  while (true) {
    try {
      final response = await http.post(
        url,
        body: {'activity': 'get-statics', 'userKey': userID},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final balanceEntity = BalanceEntity.fromJson(jsonData);
        yield balanceEntity;
      } else {
        // Optionally yield an error state or log
      }
    } catch (e) {
      // Optionally yield an error state or log
    }
    await Future.delayed(const Duration(seconds: 1));
  }
});
