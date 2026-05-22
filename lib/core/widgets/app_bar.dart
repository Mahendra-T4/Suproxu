import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/logout/logout.dart';
import 'package:suproxu/core/util/suproxu_logo.dart';
import 'package:suproxu/features/navbar/Portfolio/portfolio.dart';
import 'package:suproxu/features/navbar/TradeScreen/tradeTab.dart';
import 'package:suproxu/features/navbar/profile/notification/notificationScreen.dart';
import 'package:suproxu/features/navbar/profile/roles/superoxu_rules.dart';
import 'package:suproxu/features/navbar/wishlist/repositories/wishlist_repo.dart';

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
  VoidCallback? clearMCX,
  VoidCallback? clearNFO,
}) => AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: Colors.black,
  centerTitle: true,
  title: Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [_buildModernDropdownButton(context, clearMCX, clearNFO)],
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
          color: kGoldenBraunColor,
        ),
      ),
  ],
);

Widget _buildModernDropdownButton(
  BuildContext context,
  VoidCallback? clearMCX,
  VoidCallback? clearNFO,
) {
  return PopupMenuButton<MenuOptions>(
    onSelected: (MenuOptions result) {
      _handleMenuSelection(result, context, clearMCX, clearNFO);
    },
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    color: const Color(0xFF1A1A1A),
    elevation: 12,
    itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
      _buildMenuItemWidget(MenuOptions.portfolio, context, clearMCX, clearNFO),
      _buildMenuDivider(),

      _buildMenuItemWidget(MenuOptions.trade, context, clearMCX, clearNFO),
      _buildMenuDivider(),
      _buildMenuItemWidget(MenuOptions.order, context, clearMCX, clearNFO),
      _buildMenuDivider(),
      _buildMenuItemWidget(
        MenuOptions.clearMcxWishlist,
        context,
        clearMCX,
        clearNFO,
      ),
      _buildMenuDivider(),
      _buildMenuItemWidget(
        MenuOptions.clearNfoWishlist,
        context,
        clearMCX,
        clearNFO,
      ),
      _buildMenuDivider(),

      _buildMenuItemWidget(MenuOptions.roles, context, clearMCX, clearNFO),
      _buildMenuDivider(),
      _buildMenuItemWidget(MenuOptions.logout, context, clearMCX, clearNFO),
    ],
    child: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          child: SuproxuLogo(width: 65.w),
        ),
      ),
    ),
  );
}

PopupMenuDivider _buildMenuDivider() {
  return PopupMenuDivider(height: 1);
}

Future<void> _clearWishlistWithRefresh(
  BuildContext context,
  String category,
) async {
  try {
    await WishlistRepository.clearWatchListSymbols(category: category);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$category Wishlist Cleared'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Trigger refresh by popping and letting pages reinitialize
      // This will cause the pages' activate() method to be called
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing $category Wishlist: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

PopupMenuItem<MenuOptions> _buildMenuItemWidget(
  MenuOptions option,
  BuildContext context,
  VoidCallback? clearMCX,
  VoidCallback? clearNFO,
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
          if (clearMCX != null) {
            clearMCX();
          } else {
            _clearWishlistWithRefresh(context, 'MCX');
          }
        case MenuOptions.clearNfoWishlist:
          if (clearNFO != null) {
            clearNFO();
          } else {
            _clearWishlistWithRefresh(context, 'NFO');
          }
        case MenuOptions.roles:
          return;
        case MenuOptions.logout:
          logoutUser(context);
          break;
      }
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
                fontFamily: FontFamily.globalFontFamily,
                color: option == MenuOptions.logout ? Colors.red : Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _handleMenuSelection(
  MenuOptions option,
  BuildContext context,
  VoidCallback? clearMCX,
  VoidCallback? clearNFO,
) {
  switch (option) {
    case MenuOptions.portfolio:
      break;
    case MenuOptions.order:
      break;
    case MenuOptions.clearMcxWishlist:
      break;
    case MenuOptions.clearNfoWishlist:
      break;
    case MenuOptions.trade:
      break;
    case MenuOptions.roles:
      GoRouter.of(context).pushNamed(SuproxuRulesPage.routeName);
      break;
    case MenuOptions.logout:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Logging out...',
            style: TextStyle(fontFamily: FontFamily.globalFontFamily),
          ),
        ),
      );
      break;
  }
}

PreferredSizeWidget customAppBarWithTitle({
  required BuildContext context,
  required String title,
  required bool isShowNotify,
  VoidCallback? clearMCX,
  VoidCallback? clearNFO,
}) => AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: Colors.black,
  centerTitle: true,
  title: Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      spacing: 10,
      children: [
        _buildModernDropdownButton(context, clearMCX, clearNFO),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: FontFamily.globalFontFamily,
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
