import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/logout/logout.dart';
import 'package:suproxu/features/Rules/provider/rules_provider.dart';
import 'package:suproxu/features/auth/change-pass/changePassword.dart';

import 'package:suproxu/features/navbar/wishlist/wishlist.dart';

class TradeWarning extends ConsumerStatefulWidget {
  const TradeWarning({super.key, required this.updatePassword});
  final String updatePassword;
  static const String routeName = '/trade-warning';

  @override
  ConsumerState<TradeWarning> createState() => _TradeWarningState();
}

class _TradeWarningState extends ConsumerState<TradeWarning> {
  bool _agreedToRisks = false;
  bool _agreedToTerms = false;

  warningAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_agreedToRisks && _agreedToTerms) {
      await prefs.setBool(warnedKey, true).then((_) {
        if (widget.updatePassword == '1') {
          context.goNamed(WishList.routeName);
        } else {
          context.pushNamed(ChangePasswordScreen.routeName);
        }
      });
      log('User has accepted the trade warning.', name: 'TradeWarning Accept');
    } else {
      waringToast(context, 'Please accept all terms & conditions to continue.');
    }
  }

  warningDeclined() async {
    if (!_agreedToRisks && !_agreedToTerms) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(warnedKey, false).then((_) => logoutUser(context));
      log(
        'User has not accepted the trade warning.',
        name: 'TradeWarning Decline',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Load rules data when the widget initializes
    Future.microtask(() {
      ref.read(rulesProvider.notifier).loadRules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rulesProvider);
    return Scaffold(
      backgroundColor: const Color(0xff0d0d0d),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (state.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xffc9a227),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading trading disclaimer...',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  ],
                ),
              );
            } else if (state.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Error: ${state.errorMessage}',
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(rulesProvider.notifier).loadRules();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGoldenBraunColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 20.h),
                    Text(
                      state.rulesModel.pageTitle ?? 'Trading Risk Disclaimer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: const Color(0xff1a1a1a),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: _buildFormattedText(
                        state.rulesModel.pageDescription ??
                            'Please read the disclaimer carefully before proceeding.',
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildCheckboxes(),
                    SizedBox(height: 24.h),
                    _buildFooter(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xff1a1a1a), const Color(0xff0d0d0d)],
        ),
        border: Border(
          bottom: BorderSide(
            color: kGoldenBraunColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: kGoldenBraunColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: kGoldenBraunColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Trading Risk Disclaimer',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Important: Please read carefully before trading',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxItem(
          value: _agreedToRisks,
          onChanged: (value) {
            setState(() => _agreedToRisks = value ?? false);
          },
          label: 'I understand and acknowledge all trading risks',
        ),
        SizedBox(height: 12.h),
        _buildCheckboxItem(
          value: _agreedToTerms,
          onChanged: (value) {
            setState(() => _agreedToTerms = value ?? false);
          },
          label: 'I agree to the terms and conditions',
        ),
      ],
    );
  }

  Widget _buildCheckboxItem({
    required bool value,
    required Function(bool?) onChanged,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: value ? kGoldenBraunColor : Colors.grey.shade800,
            width: 1.5,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: kGoldenBraunColor.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: value ? kGoldenBraunColor : Colors.transparent,
                border: Border.all(
                  color: value ? kGoldenBraunColor : Colors.grey.shade600,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: value
                  ? Icon(Icons.check, size: 16.sp, color: Colors.black)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade800, width: 1)),
        color: const Color(0xff0d0d0d),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: warningDeclined,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Decline',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: warningAccepted,
              style: ElevatedButton.styleFrom(
                backgroundColor: _agreedToRisks && _agreedToTerms
                    ? kGoldenBraunColor
                    : Colors.grey.shade700,
                disabledBackgroundColor: Colors.grey.shade700,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Accept & Continue',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: _agreedToRisks && _agreedToTerms
                      ? Colors.black
                      : Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    // Decode unicode characters
    final decodedText = _decodeUnicode(text);
    final lines = decodedText.split('\n');
    final textSpans = <TextSpan>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        // Keep empty lines
        if (i < lines.length - 1) {
          textSpans.add(TextSpan(text: '\n', style: TextStyle(height: 1.8)));
        }
        continue;
      }

      // Check if line starts with a number followed by a dot (e.g., "1.", "2.", etc.)
      final startsWithNumber = RegExp(r'^\d+\.').hasMatch(line);

      // Check if line STARTS with (not contains) section headers or "Clarification"
      final lineLower = line.toLowerCase();
      final isSectionHeader =
          lineLower.startsWith('clerification:') ||
          lineLower.startsWith('clarification:') ||
          lineLower.startsWith('what information we collect') ||
          lineLower.startsWith('how do we safeguard') ||
          lineLower.startsWith('amendments to the privacy policy');

      final isBoldLine = startsWithNumber || isSectionHeader;

      textSpans.add(
        TextSpan(
          text: line,
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 14.sp,
            fontWeight: isBoldLine ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
      );

      // Add newline except for the last line
      if (i < lines.length - 1) {
        textSpans.add(TextSpan(text: '\n', style: TextStyle(height: 1.8)));
      }
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
        style: TextStyle(
          color: Colors.grey.shade300,
          fontSize: 13.sp,
          height: 1.8,
        ),
      ),
    );
  }

  String _decodeUnicode(String input) {
    // Replace common unicode characters
    return input
        .replaceAll(r'\u201c', '"') // Left double quotation mark
        .replaceAll(r'\u201d', '"') // Right double quotation mark
        .replaceAll(r'\u2013', '–') // En dash
        .replaceAll(r'\u2014', '—') // Em dash
        .replaceAll(r'\u2019', "'") // Right single quotation mark
        .replaceAll(r'\u2018', "'") // Left single quotation mark
        .replaceAll(r'\n', '\n');
  }
}
