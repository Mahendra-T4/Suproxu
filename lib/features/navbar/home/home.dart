// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trading_app/Assets/assets.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/logout/logout.dart'; // Ensure this file exports autoLogoutUser
// import 'package:trading_app/core/responsive/responsive.dart';
// import 'package:trading_app/core/service/Auth/auto_logout.dart';
// import 'package:trading_app/core/service/Auth/user_validation.dart';
// import 'package:trading_app/core/service/connectivity/internet_connection_service.dart';
// import 'package:trading_app/core/service/notification/notification_service.dart';
// import 'package:trading_app/core/service/page/not_connected.dart';
// import 'package:trading_app/features/navbar/home/mcx/mcx.dart';
// import 'package:trading_app/features/navbar/home/mcx/mcxScreen.dart';
// import 'package:trading_app/features/navbar/home/nse-future/nse_future_main.dart';
// import 'package:trading_app/features/navbar/profile/notification/notificationScreen.dart';

// class SuperTradeHome extends StatefulWidget {
//   const SuperTradeHome({super.key});
//   static const String routeName = '/';

//   @override
//   State<SuperTradeHome> createState() => _SuperTradeHomeState();
// }

// class _SuperTradeHomeState extends State<SuperTradeHome>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final NotificationService _notificationService = NotificationService();

//   bool isMCX = false;
//   bool isNFO = false;
//   bool isMCXOpen = true;
//   bool isNFOOpen = true;
//   Timer? _dataTimer;
//   @override
//   void initState() {
//     _tabController = TabController(length: 2, vsync: this);

//     // Call user validation (do not use as a condition if not returning bool)
//     if (!mounted) return;
//     // Ensure autoLogoutUser is imported from core/logout/logout.dart
//     autoLogoutUser(context, mounted);
//     _notificationService.startPolling();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _notificationService.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: greyColor,
//       child: StreamBuilder<bool>(
//           stream: InternetConnectionService().connectionStream,
//           builder: (context, snapshot) {
//             if (snapshot.data == false) {
//               return const NoInternetConnection();
//             }
//             return SafeArea(
//               child: Scaffold(
//                 backgroundColor: scaffoldBGColor,
//                 appBar: AppBar(
//                   backgroundColor: scaffoldBGColor,
//                   elevation: 0,
//                   title: Row(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: Image.asset(
//                           'assets/images/superlogo.png',
//                           height: 65.h,
//                           width: 65.w,
//                           color: kWhiteColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   actions: [
//                     IconButton(
//                       icon: Icon(Icons.search, color: kWhiteColor, size: 30),
//                       onPressed: () {
//                         if (_tabController.index == 0) {
//                           setState(() {
//                             isMCX = !isMCX;
//                             isNFO = false;
//                           });
//                         }
//                         if (_tabController.index == 1) {
//                           setState(() {
//                             isMCX = false;
//                             isNFO = !isNFO;
//                           });
//                         }
//                       },
//                     ),
//                     Stack(
//                       children: [
//                         IconButton(
//                           icon: Image.asset(
//                             Assets.assetsImagesSupertradeNotification,
//                             scale: 20,
//                             color: kWhiteColor,
//                           ),
//                           onPressed: () {
//                             _notificationService.markAsRead();
//                             GoRouter.of(context)
//                                 .pushNamed(NotificationScreen.routeName);
//                           },
//                         ),
//                         StreamBuilder<int>(
//                           stream: _notificationService.unreadCountStream,
//                           initialData: 0,
//                           builder: (context, snapshot) {
//                             if (!snapshot.hasData || snapshot.data == 0) {
//                               return const SizedBox.shrink();
//                             }

//                             return Positioned(
//                               right: 5,
//                               top: 5,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 6, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 constraints: const BoxConstraints(
//                                   minWidth: 20,
//                                   minHeight: 20,
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     snapshot.data! > 99
//                                         ? '99+'
//                                         : snapshot.data.toString(),
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 body: Column(
//                   children: [
//                     Container(
//                       color: Colors.white,
//                       child: TabBar(
//                         controller: _tabController,
//                         dividerColor: Colors.transparent,
//                         indicator: UnderlineTabIndicator(
//                           borderSide:
//                               BorderSide(width: 4.0, color: kGoldenBraunColor),
//                           insets: const EdgeInsets.symmetric(horizontal: 16.0),
//                         ),
//                         labelStyle: TextStyle(
//                             fontWeight: FontWeight.w600, fontSize: 16.sp),
//                         unselectedLabelStyle:
//                             const TextStyle(fontWeight: FontWeight.w500),
//                         indicatorSize: TabBarIndicatorSize.tab,
//                         labelColor: kGoldenBraunColor,
//                         unselectedLabelColor: Colors.grey[600],
//                         tabs: [
//                           Tab(
//                             child: Container(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 8),
//                               child: const Text(
//                                 'MCX',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Tab(
//                             child: Container(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 8),
//                               child: const Text(
//                                 'NSE-FUT',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: TabBarView(
//                         controller: _tabController,
//                         children: [
//                           const MCXStockPage(),
//                           NseFutureMain(),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//     );
//   }
// }
