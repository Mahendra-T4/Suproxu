import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/logout/logout.dart';
import 'package:suproxu/core/util/suproxu_logo.dart';
import 'package:suproxu/features/navbar/Portfolio/portfolio.dart';
import 'package:suproxu/features/navbar/TradeScreen/tradeTab.dart';
import 'package:suproxu/features/navbar/profile/notification/notificationScreen.dart';
import 'package:suproxu/features/navbar/profile/roles/superoxu_rules.dart';

enum MenuOptions {
  portfolio('Portfolio', Icons.wallet),
  order('Orders', Icons.shopping_cart),
  clearMcxWishlist('Clear MCX Wishlist', Icons.delete_outline),
  clearNfoWishlist('Clear NFO Wishlist', Icons.delete_outline),
  trade('Trades', Icons.trending_up),
  roles('Rules', Icons.security),
  logout('Logout', Icons.logout);

  final String label;
  final IconData icon;
  const MenuOptions(this.label, this.icon);
}

PreferredSizeWidget customAppBar({
  required BuildContext context,
  required bool isShowNotify,
}) => AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: Colors.black,
  centerTitle: true,
  title: Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [_buildModernDropdownButton(context)]),
  ),
  actions: [
    if (isShowNotify)
      IconButton(
        onPressed: () {
          GoRouter.of(context).pushNamed(NotificationScreen.routeName);
        },
        icon: Image.asset(
          Assets.assetsImagesSupertradeNotification,
          scale: 20,
          color: kGoldenBraunColor,
        ),
      ),
  ],
);

Widget _buildModernDropdownButton(BuildContext context) {
  return PopupMenuButton<MenuOptions>(
    onSelected: (MenuOptions result) {
      _handleMenuSelection(result, context);
    },
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    color: const Color(0xFF1A1A1A),
    elevation: 12,
    itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
      _buildMenuItemWidget(MenuOptions.portfolio, context),
      _buildMenuDivider(),

      _buildMenuItemWidget(MenuOptions.trade, context),
      _buildMenuDivider(),
      _buildMenuItemWidget(MenuOptions.order, context),
      _buildMenuDivider(),
      _buildMenuItemWidget(MenuOptions.clearMcxWishlist, context),
      _buildMenuDivider(),
      _buildMenuItemWidget(MenuOptions.clearNfoWishlist, context),
      _buildMenuDivider(),

      _buildMenuItemWidget(MenuOptions.roles, context),
      _buildMenuDivider(),
      _buildMenuItemWidget(MenuOptions.logout, context),
    ],
    child: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            // border: Border.all(
            //   color: kGoldenBraunColor.withOpacity(0.3),
            //   width: 1.5,
            // ),
          ),
          child: SuproxuLogo(width: 65.w),
        ),
      ),
    ),
  );
}

PopupMenuDivider _buildMenuDivider() {
  return PopupMenuDivider(height: 1);
}

PopupMenuItem<MenuOptions> _buildMenuItemWidget(
  MenuOptions option,
  BuildContext context,
) {
  return PopupMenuItem<MenuOptions>(
    value: option,
    onTap: () {
      switch (option) {
        case MenuOptions.portfolio:
          GoRouter.of(context).pushNamed(Portfolioclose.routeName);
        case MenuOptions.trade:
          GoRouter.of(context).pushNamed(TradeTabsScreen.routeName);
        case MenuOptions.order:
          return;
        case MenuOptions.clearMcxWishlist:
          return;
        case MenuOptions.clearNfoWishlist:
          return;
        case MenuOptions.roles:
          return;
        case MenuOptions.logout:
          logoutUser(context);
          // Handled in onSelected callback
          break;
      }
      // Optional: Add custom logic here before menu closes
      // For example: analytics tracking, haptic feedback, etc.
    },
    child: Container(
      width: 200.w,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            option.icon,
            color: option == MenuOptions.logout
                ? Colors.red
                : kGoldenBraunColor,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              option.label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: option == MenuOptions.logout ? Colors.red : Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _handleMenuSelection(MenuOptions option, BuildContext context) {
  switch (option) {
    case MenuOptions.portfolio:
      // Navigate to Portfolio
      // GoRouter.of(context).pushNamed(PortfolioScreen.routeName);
      break;
    case MenuOptions.order:
      // Navigate to Order
      // GoRouter.of(context).pushNamed(OrderScreen.routeName);
      break;
    case MenuOptions.clearMcxWishlist:
      // Clear MCX Wishlist logic
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('MCX Wishlist Cleared')));
      break;
    case MenuOptions.clearNfoWishlist:
      // Clear NFO Wishlist logic
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('NFO Wishlist Cleared')));
      break;
    case MenuOptions.trade:
      // Navigate to Trade
      // GoRouter.of(context).pushNamed(TradeScreen.routeName);
      break;
    case MenuOptions.roles:
      // Navigate to Roles
      GoRouter.of(context).pushNamed(SuproxuRulesPage.routeName);
      break;
    case MenuOptions.logout:
      // Logout logic
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logging out...')));
      // Perform logout operations here
      break;
  }
}

PreferredSizeWidget customAppBarWithTitle({
  required BuildContext context,
  required String title,
  required bool isShowNotify,
}) => AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: Colors.black,
  centerTitle: true,
  title: Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      spacing: 10,
      children: [
        _buildModernDropdownButton(context),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kGoldenBraunColor,
          ),
        ),
      ],
    ),
  ),
  actions: [
    if (isShowNotify)
      IconButton(
        onPressed: () {
          GoRouter.of(context).pushNamed(NotificationScreen.routeName);
        },
        icon: Image.asset(
          Assets.assetsImagesSupertradeNotification,
          scale: 20,
          color: kWhiteColor,
        ),
      ),
  ],
);
