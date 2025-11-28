import 'dart:convert';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/features/auth/login/loginPage.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/features/navbar/wishlist/wishlist.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // userExists();
    userNavigator();
  }

  Future<bool> userExists() async {
    if (!mounted) return false;

    DatabaseService dbService = DatabaseService();
    try {
      final userKey = await dbService.getUserData(key: userIDKey);
      final url = Uri.parse(superTradeBaseApiEndPointUrl);

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      final response = await http.post(url, body: {
        "activity": "device-check",
        "deviceID": androidInfo.id.toString(),
        "userKey": userKey.toString()
      });

      if (!mounted) return false;

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        log('User Exists Response => ${response.body}');
        log('User Key => $userKey');
        log('Device ID => ${androidInfo.id}');

        if (jsonData['status'] == 1) {
          log('User Exists => ${jsonData['message']}');
          log('User Exists Status => ${jsonData['status']}');
          return true;
        } else {
          SharedPreferences pref = await SharedPreferences.getInstance();
          await dbService.clearAllData();
          await pref.setBool(loginToken, false);
          return false;
        }
      }
      return false;
    } catch (e) {
      log('Checking user exists error: $e');
      return false;
    }
  }

  Future<void> userNavigator() async {
    if (!mounted) return;

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (!mounted) return;

      final loggedIN = pref.getBool(loginToken) ?? false;

      if (loggedIN) {
        final userValid = await userExists();
        if (!mounted) return;

        if (userValid) {
          await Future.delayed(const Duration(seconds: 3));
          if (!mounted) return;

          if (context.mounted) {
            context.goNamed(WishList.routeName);
          }
        } else {
          if (context.mounted) {
            context.goNamed(LoginPages.routeName);
          }
        }
      } else {
        if (context.mounted) {
          context.goNamed(LoginPages.routeName);
        }
      }
    } catch (e) {
      log('Navigation error: $e');
      if (mounted && context.mounted) {
        context.goNamed(LoginPages.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final connectivity = context.watch<ConnectivityService>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo

          Center(
            child: Image.asset(
              Assets.assetsImagesSuproxulogo,
              width: 200,
              // color: Colors.white,
            ),
          ),
          // if (child != null) child!, // Include additional content if provided
        ],
      ),
    );
  }
}
