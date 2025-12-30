// import 'dart:convert';
// import 'dart:developer';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:suproxu/Assets/assets.dart';
// import 'package:suproxu/core/Database/key.dart';
// import 'package:suproxu/core/Database/user_db.dart';
// import 'package:suproxu/core/constants/apis/api_urls.dart';
// import 'package:suproxu/core/constants/color.dart';
// import 'package:suproxu/features/auth/login/loginPage.dart';
// import 'package:http/http.dart' as http;
// import 'package:suproxu/features/navbar/wishlist/wishlist.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   static const String routeName = '/splash-screen';

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat();
//     _animation = Tween<double>(begin: -1.0, end: 1.0).animate(_controller);
//     // userExists();
//     userNavigator();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<bool> userExists() async {
//     if (!mounted) return false;

//     DatabaseService dbService = DatabaseService();
//     try {
//       final userKey = await dbService.getUserData(key: userIDKey);
//       final url = Uri.parse(superTradeBaseApiEndPointUrl);

//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

//       final response = await http.post(
//         url,
//         body: {
//           "activity": "device-check",
//           "deviceID": androidInfo.id.toString(),
//           "userKey": userKey.toString(),
//         },
//       );

//       if (!mounted) return false;

//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         log('User Exists Response => ${response.body}');
//         log('User Key => $userKey');
//         log('Device ID => ${androidInfo.id}');

//         if (jsonData['status'] == 1) {
//           log('User Exists => ${jsonData['message']}');
//           log('User Exists Status => ${jsonData['status']}');
//           return true;
//         } else {
//           SharedPreferences pref = await SharedPreferences.getInstance();
//           await dbService.clearAllData();
//           await pref.setBool(loginToken, false);
//           return false;
//         }
//       }
//       return false;
//     } catch (e) {
//       log('Checking user exists error: $e');
//       return false;
//     }
//   }

//   Future<void> userNavigator() async {
//     if (!mounted) return;

//     try {
//       SharedPreferences pref = await SharedPreferences.getInstance();
//       if (!mounted) return;

//       final loggedIN = pref.getBool(loginToken) ?? false;

//       if (loggedIN) {
//         final userValid = await userExists();
//         if (!mounted) return;

//         if (userValid) {
//           await Future.delayed(const Duration(seconds: 3));
//           if (!mounted) return;

//           if (context.mounted) {
//             context.goNamed(WishList.routeName);
//           }
//         } else {
//           if (!mounted) return;
//           if (context.mounted) {
//             await Future.delayed(const Duration(seconds: 3));

//             context.goNamed(LoginPages.routeName);
//           }
//         }
//       } else {
//         if (!mounted) return;
//         if (context.mounted) {
//           await Future.delayed(const Duration(seconds: 3));

//           context.goNamed(LoginPages.routeName);
//         }
//       }
//     } catch (e) {
//       log('Navigation error: $e');
//       if (mounted && context.mounted) {
//         context.goNamed(LoginPages.routeName);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final connectivity = context.watch<ConnectivityService>();
//     return Scaffold(
//       backgroundColor: zBlack,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Logo
//           Center(
//             child: AnimatedBuilder(
//               animation: _animation,

//               builder: (context, child) {
//                 return ShaderMask(
//                   shaderCallback: (Rect bounds) {
//                     return LinearGradient(
//                       begin: Alignment(
//                         _animation.value - 0.5,
//                         _animation.value - 0.5,
//                       ),
//                       end: Alignment(
//                         _animation.value + 0.5,
//                         _animation.value + 0.5,
//                       ),
//                       colors: [
//                         Colors.transparent,
//                         Colors.white.withOpacity(1.0),
//                         Colors.transparent,
//                       ],
//                     ).createShader(bounds);
//                   },
//                   blendMode: BlendMode.overlay,
//                   child: child,
//                 );
//               },

//               child: SizedBox(
//                 width: 300,
//                 height: 300,
//                 child: Image.asset(
//                   Assets.assetsImagesSuproxuSplashlogo,
//                   fit: BoxFit.fill,
//                   // color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           // if (child != null) child!, // Include additional content if provided
//         ],
//       ),
//     );
//   }
// }
