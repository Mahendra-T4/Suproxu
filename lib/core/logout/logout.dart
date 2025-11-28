import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/features/auth/login/loginPage.dart';


Future<void> logoutUser(BuildContext context) async {
  // First clear the data regardless of navigation
  try {
    DatabaseService dbService = DatabaseService();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await dbService.clearAllData();
    await pref.setBool(loginToken, false);
  } catch (e) {
    debugPrint('Error clearing data: $e');
  }

  // Then handle navigation
  if (!context.mounted) return;

  try {
    // Try using GoRouter first
    final router = GoRouter.of(context);
    router.goNamed(LoginPages.routeName);
  } catch (e) {
    debugPrint('GoRouter navigation failed: $e');

    // Fallback to traditional navigation
    try {
      // Find the nearest navigator
      final navigator = Navigator.maybeOf(context);
      if (navigator != null) {
        await navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPages()),
          (route) => false,
        );
      } else {
        // If no navigator is found, try root navigator
        if (!context.mounted) return;
        final rootNavigator = Navigator.of(context, rootNavigator: true);
        await rootNavigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPages()),
          (route) => false,
        );
      }
    } catch (navigatorError) {
      debugPrint('Traditional navigation failed: $navigatorError');
      // If all navigation attempts fail, at least the data is cleared
    }
  }
}

class CustomDialog extends StatefulWidget {
  const CustomDialog({super.key});

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool isLogout = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5 * _fadeAnimation.value,
            sigmaY: 5 * _fadeAnimation.value,
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 0.8.sw,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: Colors.deepPurpleAccent,
                          size: 40.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      const Text(
                        'Logout',
                      ).textStyleHB(),
                      SizedBox(height: 16.h),
                      const Text(
                        'Are you sure you want to logout?',
                        textAlign: TextAlign.center,
                      ).textStyleH1(),
                      SizedBox(height: 32.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              title: 'Cancel',
                              onTap: () => Navigator.of(context).pop(),
                              isOutlined: true,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildButton(
                              title: 'Logout',
                              onTap: () async {
                                // First close the dialog
                                Navigator.of(context).pop();

                                // Then perform logout
                                if (!context.mounted) return;
                                try {
                                  await logoutUser(context);
                                } catch (e) {
                                  debugPrint('Logout error: $e');
                                }
                              },
                              isOutlined: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required String title,
    required VoidCallback onTap,
    required bool isOutlined,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isOutlined
                ? null
                : LinearGradient(
                    colors: [Colors.black, Colors.blue.shade400],
                  ),
            borderRadius: BorderRadius.circular(12.r),
            border: isOutlined
                ? Border.all(color: Colors.deepPurpleAccent, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                // fontFamily: 'JetBrainsMono',
                color: isOutlined ? Colors.deepPurpleAccent : Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
