import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/features/auth/change-pass/changePassword.dart';
import 'package:suproxu/features/navbar/Portfolio/portfolio.dart';
import 'package:suproxu/features/navbar/TradeScreen/tradeTab.dart';
import 'package:suproxu/features/navbar/profile/accountScreen.dart';
import 'package:suproxu/features/navbar/profile/complaint/lodgeComplaint.dart';
import 'package:suproxu/features/navbar/profile/ledger/ledgerScreen.dart';
import 'package:suproxu/features/navbar/profile/notification/notificationScreen.dart';
import 'package:suproxu/features/navbar/profile/payment/paymentScreen.dart';
import 'package:suproxu/features/navbar/profile/profile/profile_info.dart';
import 'package:suproxu/features/navbar/profile/wallet/user_wallet.dart';
import 'package:suproxu/features/navbar/profile/withdraw/withdraw.dart';
import 'package:suproxu/features/navbar/wishlist/wishlist.dart';

class GlobalNavBar extends StatefulWidget {
  // final int? navigateIndex;
  final Widget? child;

  static const String routeName = '/global-nav-bar';

  const GlobalNavBar({super.key, this.child});

  @override
  _GlobalNavBarState createState() => _GlobalNavBarState();
}

class _GlobalNavBarState extends State<GlobalNavBar>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _controller;
  late Animation<double> _animation;

  static final List<String> _listOfWidget = [
    WishList.routeName,
    TradeTabsScreen.routeName,
    Portfolioclose.routeName,
    Accountscreen.routeName,
  ];

  final List<String> _allRoutes = [
    UserWalletPage.routeName,
    WithdrawPage.routeName,
    ChangePasswordScreen.routeName,
    PaymentScreen.routeName,
    LedgerReportScreen.routeName, // Assuming you have a ledger balance screen
    ProfileInfo.routeName, // Assuming you have a profile info screen
    LodgeComplaintScreen.routeName, // Assuming you have a complaint screen
  ];

  // Routes where navbar should be neutral (no selection)
  static const String notificationRouteName = NotificationScreen.routeName;
  final List<String> _neutralRoutes = [notificationRouteName];

  @override
  void initState() {
    super.initState();
    // _selectedIndex =
    //     widget.navigateIndex ?? 2; // Default to Home if not provided
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      context.goNamed(_listOfWidget[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the bottom padding of the device
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final currentPath = GoRouterState.of(context).uri.path;

    // Check if current path is a neutral route (like notification page)
    if (_neutralRoutes.contains(currentPath)) {
      _selectedIndex = -1; // Neutral - no item selected
    } else {
      _selectedIndex = _listOfWidget.indexOf(currentPath);
      if (_selectedIndex == -1) {
        _selectedIndex = _allRoutes.contains(currentPath)
            ? 3
            : 0; // Default to first tab if on a non-nav route
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: widget.child,
      ),
      bottomNavigationBar: ClipRRect(
        // borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 60 + bottomPadding,
          color: const Color(0xFF000000),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.list,
                label: 'Wishlist',
                selected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _NavBarItem(
                icon: Icons.show_chart_rounded,
                label: 'Trade',
                selected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _NavBarItem(
                icon: Icons.pie_chart,
                label: 'Portfolio',
                selected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              _NavBarItem(
                icon: Icons.person_rounded,
                label: 'Account',
                selected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.grey.shade600;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: 4,
              width: 32,
              margin: EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(icon, color: color, size: 28),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontFamily: FontFamily.globalFontFamily,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
