// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/responsive/responsive.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/Portfolio/close_portfolio_tab.dart';
import 'package:suproxu/features/navbar/Portfolio/active_portfolio.dart';

import 'package:suproxu/features/navbar/profile/notification/notificationScreen.dart';

class Portfolioclose extends StatefulWidget {
  final bool showCloseTab;
  const Portfolioclose({super.key, this.showCloseTab = false});
  static const String routeName = '/portfolio-page';

  @override
  State<Portfolioclose> createState() => _PortfoliocloseState();
}

class _PortfoliocloseState extends State<Portfolioclose>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  double ledgerBalance = 19700.25;
  double investBalance = 10000;
  var ProfitLoOnInvest = 0.0;
  double calculateLossOnInvest(double ledgerBalance, double investBalance) {
    final loss = investBalance - 2000;
    ProfitLoOnInvest = investBalance - loss;
    return ProfitLoOnInvest;
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.showCloseTab ? 1 : 0);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: InternetConnectionService().connectionStream,
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return const NoInternetConnection(); // Show your offline UI
          }
          return Container(
            color: greyColor,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: zBlack,
                appBar: customAppBar(context: context, isShowNotify: true),
                body: Column(
                  children: [
                    Container(
                      color: zBlack,
                      child: TabBar(
                        controller: tabController,
                        dividerColor: Colors.transparent,
                        indicator: UnderlineTabIndicator(
                          borderSide:
                              BorderSide(width: 4.0, color: kGoldenBraunColor),
                          insets: const EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16.sp),
                        unselectedLabelStyle:
                            const TextStyle(fontWeight: FontWeight.w500),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: kGoldenBraunColor,
                        unselectedLabelColor: kGoldenBraunColor,
                        tabs: const [
                          Tab(text: 'Active'),
                          Tab(text: 'Closed'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: const [
                          PortfolioActiveTab(),
                          PortfolioCloseTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
