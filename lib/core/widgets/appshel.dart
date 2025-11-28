// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/material.dart';

// import 'package:trading_app/features/navbar/Portfolio/portfolio.dart';
// import 'package:trading_app/features/navbar/TradeScreen/tradeTab.dart';
// import 'package:trading_app/features/navbar/home/home.dart';
// import 'package:trading_app/features/navbar/profile/accountScreen.dart';
// import 'package:trading_app/features/navbar/wishlist/wishlist.dart';

// class AppShell extends StatefulWidget {
//   final Widget child;
//   @override
//   _AppShellState createState() => _AppShellState();
//   static const String routeName = '/global-nav-bar';

//   const AppShell({
//     Key? key,
//     required this.child,
//   }) : super(key: key);
// }

// class _AppShellState extends State<AppShell>
//     with SingleTickerProviderStateMixin {
//   int? _selectedIndex;
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   static final List<Widget> _listOfWidget = <Widget>[
//     const WishList(),
//     const TradeTabsScreen(),
//     const SuperTradeHome(),
//     const Portfolioclose(),
//     const Accountscreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       _controller.forward(from: 0);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get the bottom padding of the device
//     final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 350),
//         child: _listOfWidget[_selectedIndex!],
//       ),
//       bottomNavigationBar: ClipRRect(
//         // borderRadius: BorderRadius.circular(24),
//         child: Container(
//           height: 60 + bottomPadding,
//           color: const Color(0xFF000000),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _NavBarItem(
//                 icon: Icons.list,
//                 label: 'Wishlist',
//                 selected: _selectedIndex == 0,
//                 onTap: () => setState(() => _selectedIndex = 0),
//               ),
//               _NavBarItem(
//                 icon: Icons.show_chart_rounded,
//                 label: 'Trade',
//                 selected: _selectedIndex == 1,
//                 onTap: () => setState(() => _selectedIndex = 1),
//               ),
//               _NavBarItem(
//                 icon: Icons.home,
//                 label: 'Home',
//                 selected: _selectedIndex == 2,
//                 onTap: () => setState(() => _selectedIndex = 2),
//               ),
//               _NavBarItem(
//                 icon: Icons.pie_chart,
//                 label: 'Portfolio',
//                 selected: _selectedIndex == 3,
//                 onTap: () => setState(() => _selectedIndex = 3),
//               ),
//               _NavBarItem(
//                 icon: Icons.person_rounded,
//                 label: 'Profile',
//                 selected: _selectedIndex == 4,
//                 onTap: () => setState(() => _selectedIndex = 4),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NavBarItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;

//   const _NavBarItem({
//     required this.icon,
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = selected ? Colors.white : Colors.grey.shade600;
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AnimatedContainer(
//               duration: Duration(milliseconds: 200),
//               height: 4,
//               width: 32,
//               margin: EdgeInsets.only(bottom: 4),
//               decoration: BoxDecoration(
//                 color: selected ? Colors.white : Colors.transparent,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Icon(icon, color: color, size: 28),
//             SizedBox(height: 2),
//             Text(
//               label,
//               style: TextStyle(
//                 color: color,
//                 fontWeight: selected ? FontWeight.bold : FontWeight.w500,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
