// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trading_app/features/navbar/navbar.dart';

// class ShellScaffold extends StatelessWidget {
//   final Widget child;
//   final bool showNavBar;

//   const ShellScaffold({
//     super.key,
//     required this.child,
//     this.showNavBar = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Get the current location to determine which tab should be active
//     final location = GoRouterState.of(context).uri.path;
//     int currentIndex = _getSelectedIndex(location);

//     return Scaffold(
//       body: child,
//       bottomNavigationBar: showNavBar
//           ? GlobalNavBar(
//               navigateIndex: currentIndex,
//               onNavigate: (index) {
//                 // Handle navigation based on index
//                 String route = _getRouteForIndex(index);
//                 context.go(route);
//               },
//             )
//           : null,
//     );
//   }

//   int _getSelectedIndex(String location) {
//     if (location.startsWith('/wishlist')) return 0;
//     if (location.startsWith('/trade')) return 1;
//     if (location.startsWith('/home')) return 2;
//     if (location.startsWith('/portfolio')) return 3;
//     if (location.startsWith('/account')) return 4;
//     return 2; // Default to home
//   }

//   String _getRouteForIndex(int index) {
//     switch (index) {
//       case 0:
//         return '/wishlist';
//       case 1:
//         return '/trade';
//       case 2:
//         return '/home';
//       case 3:
//         return '/portfolio';
//       case 4:
//         return '/account';
//       default:
//         return '/home';
//     }
//   }
// }
