// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/service/Auth/user_validation.dart';
// import 'package:trading_app/features/navbar/home/nse-future/nfo_ws_handler.dart';

// class NseFutureMain extends StatefulWidget {
//   const NseFutureMain({
//     super.key,
//   });

//   static const String routeName = '/nse-future-main';

//   @override
//   State<NseFutureMain> createState() => _NseFutureMainState();
// }

// class _NseFutureMainState extends State<NseFutureMain> {
//   late Timer _dataTimer;
//   // SocketService mcxSocketService = SocketService();

//   @override
//   void initState() {
//     _dataTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
//       AuthService().checkUserValidation();
//     }); // Reduced frequency

//     AuthService().checkUserValidation();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _dataTimer.cancel(); // Cancel timer to prevent leaks
//     // SocketService().socket.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: kWhiteColor,
//         body: Column(
//           children: [_buildSearchBar(), const NFOWebSocketHandler()],
//         ),
//       ),
//     );
//     // : const NoInternetConnection();
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C2C2E).withOpacity(.9),
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: Row(
//         children: [
//           SizedBox(
//             // height: 45,
//             // width: 45,
//             child: IconButton(
//                 onPressed: () {
//                   context.pop();
//                 },
//                 icon: const Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.white,
//                 )),
//           ),
//           Expanded(
//             child: TextField(
//               // controller: searchController,
//               // focusNode: _searchFocusNode,
//               style: TextStyle(color: Colors.white, fontSize: 16.sp),
//               onChanged: (query) {},
//               decoration: InputDecoration(
//                 hintText: 'Search by symbol or price...',
//                 hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
//                 prefixIcon:
//                     Icon(Icons.search, color: Colors.grey[400], size: 20.r),
//                 border: InputBorder.none,
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Debouncer {
//   final int milliseconds;
//   Timer? _timer;

//   Debouncer({required this.milliseconds});

//   void run(VoidCallback action) {
//     _timer?.cancel();
//     _timer = Timer(Duration(milliseconds: milliseconds), action);
//   }

//   void dispose() {
//     _timer?.cancel();
//   }
// }
