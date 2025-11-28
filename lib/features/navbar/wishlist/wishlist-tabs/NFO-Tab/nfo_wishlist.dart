// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trading_app/core/constants/color.dart';
// import 'package:trading_app/core/service/Auth/user_validation.dart';
// import 'package:trading_app/features/navbar/home/nse-future/nse_future_main.dart';
// import 'package:trading_app/features/navbar/home/nse-future/page/nse_future.dart';
// import 'package:trading_app/features/navbar/wishlist/widgets/search_widget.dart';
// import 'package:trading_app/features/navbar/wishlist/wishlist-tabs/NFO-Tab/nfo_watchlist_main.dart';

// // ignore: must_be_immutable
// class NFOWishlist extends StatefulWidget {
//   NFOWishlist({
//     Key? key,
//   }) : super(key: key);
//   static const String routeName = '/nse-future-wishlist-main';

//   @override
//   State<NFOWishlist> createState() => _NFOWishlistState();
// }

// class _NFOWishlistState extends State<NFOWishlist> {
//   late Timer _timer;
//   @override
//   void initState() {
//     super.initState();

//     AuthService().checkUserValidation();
//     _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       AuthService().checkUserValidation();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: kWhiteColor,
//         body: Column(
//           children: [
//             SearchWidget(
//               hint: 'Search & Add',
//               isReadOnly: true,
//               onTap: () {
//                 context.pushNamed(NseFuture.routeName);
//               },
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//             const NFOWatchListMain()
//           ],
//         ));
//   }
// }
