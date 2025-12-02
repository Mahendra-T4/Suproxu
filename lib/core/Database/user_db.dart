import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService with ChangeNotifier {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<void> saveUserData({
    required String key,
    required dynamic value,
  }) async {
    final pref = await SharedPreferences.getInstance();
    try {
      if (value is String) {
        await pref.setString(key, value);
      } else if (value is int) {
        await pref.setInt(key, value);
      } else if (value is double) {
        await pref.setDouble(key, value);
      } else if (value is bool) {
        await pref.setBool(key, value);
      } else {
        await pref.setString(key, jsonDecode(value));
      }
      notifyListeners();
    } catch (e) {
      throw Exception("Error saving data: $e");
    }
  }

  Future<dynamic> getUserData({required String key}) async {
    final pref = await SharedPreferences.getInstance();
    try {
      return pref.get(key);
    } catch (e) {
      throw Exception("Error retrieving data: $e");
    }
  }

  Future<bool> removeUserData({required String key}) async {
    final pref = await SharedPreferences.getInstance();
    try {
      final result = await pref.remove(key);
      notifyListeners();
      return result;
    } catch (e) {
      throw Exception("Error removing data: $e");
    }
  }

  Future<bool> clearAllData() async {
    final pref = await SharedPreferences.getInstance();
    try {
      final result = await pref.clear();
      notifyListeners();
      return result;
    } catch (e) {
      throw Exception("Error clearing data: $e");
    }
  }

  /// Listen to changes in the SharedPreferences data.

  Stream<SharedPreferences> get preferencesStream async* {
    final pref = await SharedPreferences.getInstance();
    yield pref;
    notifyListeners();
  }
}
