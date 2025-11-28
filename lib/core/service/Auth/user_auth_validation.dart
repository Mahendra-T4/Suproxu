// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';
// import 'package:trading_app/core/constants/apis/api_urls.dart';

// class UserAuth {
//   static final UserAuth _instance = UserAuth.internal();

//   factory UserAuth() => _instance;

//   UserAuth.internal();

//   final StreamController<bool> _authController =
//       StreamController<bool>.broadcast();

//   final _apiUrl = Uri.parse(superTradeBaseApiEndPointUrl);

//   Timer? _periodicTimer;

//   Stream<bool> get authStream => _authController.stream;

//    Future<bool> checkUserValidation() async {
//     try {
//       final pref = await SharedPreferences.getInstance();
//       final authToken = pref.getBool(loginToken) ?? false;

//       // On app start, if there's no token, mark as invalid and return false
//       if (!authToken) {
//         log('No auth token found');
       
//         return false;
//       }

//       // Add a small delay on startup to ensure all services are initialized
//       await Future.delayed(const Duration(milliseconds: 500));

//       DatabaseService dbService = DatabaseService();
//       final userKey = await dbService.getUserData(key: userIDKey);

//       // Immediate check for user key
//       if (userKey == null) {
//         log('User key not found, triggering immediate logout');
     
//         return false;
//       }

//       final deviceInfo = DeviceInfoPlugin();
//       final androidInfo = await deviceInfo.androidInfo;

//       final response = await http.post(
//         _apiUrl,
//         body: {
//           "activity": "device-check",
//           "deviceID": androidInfo.id.toString(),
//           "userKey": userKey.toString()
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         log('Device check response: ${response.body}');

//         if (jsonData['status'] == 1) {
//           // User is valid, update the token and validation state
//           final pref = await SharedPreferences.getInstance();
       
//           log('User validation successful');
//           return true;
//         } else {
//           // Immediate logout on invalid session
//           log('Invalid session detected, triggering immediate logout');
        
//           return false;
//         }
//       } else {
//         log('Server error: ${response.statusCode}');
//         // Only logout on specific error codes (401, 403)
     
//         // For other server errors, keep the session active
//         return true;
//       }
//     } catch (e) {
//       log('User validation error: $e');
//       // Only logout for specific security-related errors
//       if (e.toString().contains('token expired') ||
//           e.toString().contains('invalid auth') ||
//           e.toString().contains('unauthorized')) {
//         log('Security-sensitive error detected, triggering logout');
       
//         return false;
//       }
//       // For other errors (like network issues), keep the previous validation state
//       log('Non-critical error, keeping session active: $e');
//       // Don't update _isValidUser here to maintain the last known state
     
//     }
//   }
// }
