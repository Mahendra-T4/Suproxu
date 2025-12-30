import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/Rules/provider/rules_provider.dart';

class SuproxuRulesPage extends ConsumerStatefulWidget {
  const SuproxuRulesPage({super.key});
  static const String routeName = '/suproxu-rules-page';

  @override
  ConsumerState<SuproxuRulesPage> createState() => _SuproxuRulesPageState();
}

class _SuproxuRulesPageState extends ConsumerState<SuproxuRulesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(rulesProvider.notifier).loadRules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rulesProvider);
    return Scaffold(
      backgroundColor: const Color(0xff0d0d0d),
      appBar: customAppBar(context: context, isShowNotify: true),
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
                      'Loading rules...',
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
                    // _buildHeader(),
                    // SizedBox(height: 20.h),
                    Text(
                      state.rulesModel.pageTitle ?? 'Suproxu Rules',
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
                            'Rules content goes here.',
                      ),
                    ),
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
                child: Icon(Icons.rule, color: kGoldenBraunColor, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'Suproxu Rules',
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
            'Important rules and guidelines',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    final decodedText = _decodeUnicode(text);
    final lines = decodedText.split('\n');
    final textSpans = <TextSpan>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        if (i < lines.length - 1) {
          textSpans.add(TextSpan(text: '\n', style: TextStyle(height: 1.8)));
        }
        continue;
      }

      final startsWithNumber = RegExp(r'^\d+\.').hasMatch(line);

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
    return input
        .replaceAll(r'\u201c', '"')
        .replaceAll(r'\u201d', '"')
        .replaceAll(r'\u2013', '–')
        .replaceAll(r'\u2014', '—')
        .replaceAll(r'\u2019', "'")
        .replaceAll(r'\u2018', "'")
        .replaceAll(r'\n', '\n');
  }
}
