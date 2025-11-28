import 'dart:convert';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/model/nse_wishlist_entity.dart';
import 'package:suproxu/features/navbar/wishlist/model/sorting_param.dart';
import 'package:suproxu/features/navbar/wishlist/model/symbol_sort_model.dart';
import 'package:suproxu/features/navbar/wishlist/model/wishlist_entity.dart';

abstract class WishlistRepository {
  static final client = http.Client();
  static final url = Uri.parse(superTradeBaseApiEndPointUrl);

  static Future<bool> addToWishlist(
      {required String category,
      required String symbolKey,
      required BuildContext context}) async {
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    DatabaseService databaseService = DatabaseService();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    final uKey = await databaseService.getUserData(key: userIDKey);
    try {
      final response = await http.post(url, body: {
        'activity': 'add-wishlist',
        'userKey': uKey,
        'symbolKey': symbolKey,
        "deviceID": deviceID.toString(),
        'dataRelatedTo': category
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log('Wishlist Response =>> ${jsonResponse['message']}');
        return true;
      } else if (response.statusCode == 500) {
        log('Server Error ${response.statusCode}');
      }
      return false;
    } catch (err) {
      log('Wishlist Error =>> $err');
      return false;
    }
  }

  static Future<NSEWishlistEntity> fatchWishlistForNSE() async {
    NSEWishlistEntity nseWishlistEntity = NSEWishlistEntity();
    DatabaseService databaseService = DatabaseService();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    final uKey = await databaseService.getUserData(key: userIDKey);
    try {
      final response = await client.post(url, body: {
        'activity': 'wishlist',
        'userKey': uKey,
        "deviceID": deviceID.toString(),
        'dataRelatedTo': 'NSE'
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        nseWishlistEntity = NSEWishlistEntity.fromJson(jsonResponse);
        log('WishList =>>${nseWishlistEntity.message}');
      } else {
        log('Wishlist=>> failed to load data from Server');
      }
    } catch (error) {
      log('Fatch Wishlist Error =>> $error');
    }
    return nseWishlistEntity;
  }

  static Future<MCXWishlistEntity> fatchWishlistForMCX() async {
    MCXWishlistEntity mcxWishlistEntity = MCXWishlistEntity();
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(url, body: {
        'activity': 'wishlist',
        'userKey': uKey.tos,
        "deviceID": deviceID.toString(),
        'dataRelatedTo': 'MCX'
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        mcxWishlistEntity = MCXWishlistEntity.fromJson(jsonResponse);
        // log(name: 'MCX WatchList', response.body);
        log('WishList =>>${mcxWishlistEntity.message}');
      } else {
        log('Wishlist=>> failed to load data from Server');
      }
    } catch (error) {
      log('Fatch Wishlist Error =>> $error');
    }
    return mcxWishlistEntity;
  }

  static Future<NFOWishlistEntity> fatchWishlistForNFO() async {
    NFOWishlistEntity wishlistStocksEntity = NFOWishlistEntity();
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(url, body: {
        'activity': 'wishlist',
        'userKey': uKey,
        "deviceID": deviceID.toString(),
        'dataRelatedTo': 'NFO'
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        wishlistStocksEntity = NFOWishlistEntity.fromJson(jsonResponse);
        log('WishList =>>${wishlistStocksEntity.message}');
      } else {
        log('Wishlist=>> failed to load data from Server');
      }
    } catch (error) {
      log('Fatch Wishlist Error =>> $error');
    }
    return wishlistStocksEntity;
  }

  static Future<bool> removeWatchListSymbols({
    required String category,
    required String symbolKey,
  }) async {
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(url, body: {
        'activity': 'remove-wishlist',
        'userKey': uKey,
        'symbolKey': symbolKey,
        "deviceID": deviceID.toString(),
        'dataRelatedTo': category
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log('Remove Wishlist Response =>> ${jsonResponse['message']}');
        return true;
      }
      return false;
    } catch (err) {
      log('Remove Wishlist Error =>> $err');
      return false;
    }
  }

  static Future<SymbolSortModel> symbolSorting(
      {required SortListParam param}) async {
    SymbolSortModel symbolSortModel = SymbolSortModel();

    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
      // Convert List<String> to comma-separated strings
      // final symbolKeyString = param.symbolKey.join(',');
      // final symbolOrderString = param.symbolOrder.join(',');

      final response = await client.post(url, body: {
        'activity': 'sort-stocks',
        'userKey': uKey.toString(),
        'symbolKey': param.symbolKey,
        'symbolOrder': param.symbolOrder,
        'deviceID': deviceID.toString(),
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        symbolSortModel = SymbolSortModel.fromJson(jsonData);
        log(name: 'Symbol Sorting', symbolSortModel.message.toString());
      } else {
        throw 'failed to load data from server';
      }
    } catch (e) {
      log(name: 'Symbol Sorting Error', e.toString());
    }
    return symbolSortModel;
  }
}
