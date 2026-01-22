import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/logout/logout.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/auth/change-pass/changePassword.dart';
import 'package:suproxu/features/navbar/Portfolio/portfolio.dart';
import 'package:suproxu/features/navbar/home/providers/wallet_provider.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';
import 'package:suproxu/features/navbar/profile/example_wallet_widget.dart';
import 'package:suproxu/features/navbar/profile/ledger/ledgerScreen.dart';
import 'package:suproxu/features/navbar/profile/complaint/lodgeComplaint.dart';
import 'package:suproxu/features/navbar/profile/model/balence_entity.dart';
import 'package:suproxu/features/navbar/profile/payment/paymentScreen.dart';
import 'package:suproxu/features/navbar/profile/profile/profile_info.dart';
import 'package:suproxu/features/navbar/profile/wallet/user_wallet.dart';
import 'package:suproxu/features/navbar/profile/withdraw/withdraw.dart';

class Accountscreen extends ConsumerStatefulWidget {
  const Accountscreen({super.key});
  static const String routeName = '/account-profile';

  @override
  ConsumerState<Accountscreen> createState() => _AccountscreenState();
}

class _AccountscreenState extends ConsumerState<Accountscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? uFName;
  String? uLName;
  String? uEmail;
  String? uTrade;
  String? uPoints;
  String? uBalance;
  String? profitLoss;
  String? active;
  String? close;
  String? pending;

  BalanceEntity balanceEntity = BalanceEntity();
  bool isLoading = true;

  Future<void> userWallet() async {
    final DatabaseService databaseService = DatabaseService();
    final userID = await databaseService.getUserData(key: userIDKey);
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    try {
      final response = await http.post(
        url,
        body: {'activity': 'get-statics', 'userKey': userID},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        balanceEntity = BalanceEntity.fromJson(jsonData);
        log('Balance Response : ${balanceEntity.message.toString()}');
      }
    } catch (e) {
      log('Balance Error : $e');
    }
  }

  initClientDetails() async {
    DatabaseService databaseService = DatabaseService();
    final fName = await databaseService.getUserData(key: userFirstNameKey);
    final lName = await databaseService.getUserData(key: userLastNameKey);
    final uemail = await databaseService.getUserData(key: userEmailIDKey);
    final activeTrade = await databaseService.getUserData(key: activeTradeKey);
    final closeTrade = await databaseService.getUserData(key: closeTradeKey);
    final pendingTrade = await databaseService.getUserData(
      key: pendingTradeKey,
    );
    final profitAndLoss = await databaseService.getUserData(
      key: profitAndLossKey,
    );
    final userBalance = await databaseService.getUserData(key: userBalanceKey);
    setState(() {
      uFName = fName;
      uLName = lName;
      uEmail = uemail;
      profitLoss = profitAndLoss;
      active = activeTrade;
      close = closeTrade;
      pending = pendingTrade;
      uBalance = userBalance;
    });
  }

  late ProfileBloc _profileBloc;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    initClientDetails();
    _profileBloc = ProfileBloc();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    _profileBloc.add(LoadUserWalletDataEvent());
    timer = Timer.periodic(const Duration(seconds: 1), (timer) => userWallet());
    userWallet();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uWalletProvider = ref.watch(walletProvider);
    // final connectivity = context.watch<ConnectivityService>();
    // ClientConfig.initStudents();
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final bool isLargeScreen = screenWidth > 600;
        final double padding = screenWidth * 0.04;
        final double avatarRadius = isLargeScreen ? 70 : screenWidth * 0.15;

        return Container(
          color: greyColor,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: kWhiteColor,
              appBar: customAppBar(context: context, isShowNotify: true),
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: padding),
                        _buildProfileContainer(
                          screenWidth,
                          avatarRadius,
                          isLargeScreen,
                        ),
                        SizedBox(height: padding * 1.5),
                        _buildOptionsList(
                          screenWidth,
                          screenHeight,
                          isLargeScreen,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        // : const NoInternetConnection();
      },
    );
  }

  Widget _buildProfileContainer(
    double screenWidth,
    double avatarRadius,
    bool isLargeScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade900.withOpacity(0.95),
            Colors.blueGrey.shade900.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          // Modern avatar with border and shadow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.5),
                width: 4,
              ),
            ),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.indigo.shade800,
              child: Icon(
                Icons.person,
                size: avatarRadius * 1.2,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          // Name with gradient text
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Colors.blueAccent, Colors.cyanAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Text(
              '${uFName.toString().toUpperCase()} ${uLName.toString().toUpperCase()}',
              textAlign: TextAlign.center,
            ).textStyleHT(),
          ),
          SizedBox(height: screenWidth * 0.01),
          // Email with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email,
                color: Colors.cyanAccent,
                size: isLargeScreen ? 20 : screenWidth * 0.045,
              ),
              const SizedBox(width: 8),
              Text(
                uEmail?.isNotEmpty == true ? uEmail! : 'No email',
                textAlign: TextAlign.center,
              ).textStyleH2W(),
            ],
          ),
          SizedBox(height: screenWidth * 0.04),
          // Modern stats with glass effect
          BlocConsumer(
            bloc: _profileBloc,
            listener: (context, state) {
              if (state is LoadUserWalletDataFailedStatus) {
                final error = state.error;
                failedToast(context, error.toString());
              }
            },
            builder: (context, state) {
              switch (state.runtimeType) {
                case const (ProfileLoadingState):
                  return const CircularProgressIndicator.adaptive();
                case const (LoadUserWalletDataSuccessStatus):
                  final wallet =
                      (state as LoadUserWalletDataSuccessStatus).balanceEntity;
                  return Column(
                    spacing: 10,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          modernStatCard2(
                            icon: Icons.account_balance_wallet_rounded,
                            label: "Balance",
                            value: wallet.record?.first.availableBalance ?? 0,
                            color: Colors.greenAccent,
                            screenWidth: screenWidth,
                          ),
                          WalletWidget(screenWidth: screenWidth),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                GoRouter.of(context).goNamed(
                                  Portfolioclose.routeName,
                                  extra: {'showCloseTab': false},
                                );
                              },
                              child: modernStatCard(
                                icon: Icons.trending_up_rounded,
                                label: "Active",
                                value: wallet.record?.first.activeTrade ?? 0,
                                color: Colors.orangeAccent,
                                screenWidth: screenWidth,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // Navigate with both the nav index and showCloseTab parameter
                                GoRouter.of(context).goNamed(
                                  Portfolioclose.routeName,
                                  extra: {'showCloseTab': true},
                                );
                              },
                              child: modernStatCard(
                                icon: Icons.trending_up_rounded,
                                label: "Close",
                                value:
                                    wallet.record?.first.closeTrade ??
                                    0.toString(),
                                color: Colors.redAccent,
                                screenWidth: screenWidth,
                              ),
                            ),
                          ),
                          // InkWell(
                          //   onTap: () {
                          //     GoRouter.of(context).goNamed(
                          //       TradeTabsScreen.routeName,
                          //     );
                          //   },
                          //   child: modernStatCard(
                          //       icon: Icons.trending_up_rounded,
                          //       label: "Pending",
                          //       value: wallet.record?.first.pendingTrade ?? 0,
                          //       color: Colors.cyanAccent,
                          //       screenWidth: screenWidth),
                          // ),
                        ],
                      ),
                    ],
                  );
                case const (LoadUserWalletDataFailedStatus):
                  return const SizedBox.shrink();
                default:
                  return const Text('State Not Found');
              }
            },
          ),
        ],
      ),
    );
  }

  // Modern stat card widget (move outside _buildProfileContainer)
  Widget modernStatCard({
    required IconData icon,
    required String label,
    required dynamic value,
    required Color color,
    required double screenWidth,
  }) {
    return Container(
      width: screenWidth * 0.25,
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.03,
        horizontal: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: color.withOpacity(0.18),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: screenWidth * 0.08),
          SizedBox(height: screenWidth * 0.01),
          Text(value.toString(), textAlign: TextAlign.center).textStyleH1W(),
          SizedBox(height: screenWidth * 0.005),
          Text(label, textAlign: TextAlign.center).textStyleH2W(),
        ],
      ),
    );
  }

  Widget modernStatCard2({
    required IconData icon,
    required String label,
    required dynamic value,
    required Color color,
    required double screenWidth,
  }) {
    return Container(
      // width: screenWidth * 0.25,
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.03,
        horizontal: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: color.withOpacity(0.18),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: screenWidth * 0.08),
          SizedBox(height: screenWidth * 0.01),
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              // fontFamily: 'JetBrainsMono',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenWidth * 0.005),
          Text(label, textAlign: TextAlign.center).textStyleH2W(),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              // fontFamily: 'JetBrainsMono',
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(label).textStyleH2W(),
        ],
      ),
    );
  }

  Widget _buildOptionsList(
    double screenWidth,
    double screenHeight,
    bool isLargeScreen,
  ) {
    return SizedBox(
      height: isLargeScreen ? screenHeight * 0.6 : null,
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          _buildListItem(
            Icons.person_outline_rounded,
            "Profile",
            ProfileInfo.routeName,
            Colors.blueAccent,
            screenWidth,
          ),
          _buildListItem(
            Icons.money,
            "Withdraw",
            WithdrawPage.routeName,
            Colors.deepPurpleAccent,
            screenWidth,
          ),
          _buildListItem(
            Icons.wallet,
            "Wallet",
            UserWalletPage.routeName,
            kGoldenBraunColor,
            screenWidth,
          ),
          _buildListItem(
            Icons.sticky_note_2_outlined,
            "Ledger Report",
            LedgerReportScreen.routeName,
            Colors.greenAccent,
            screenWidth,
          ),
          _buildListItem(
            Icons.credit_card_outlined,
            "Payment",
            PaymentScreen.routeName,
            Colors.orangeAccent,
            screenWidth,
          ),
          _buildListItem(
            Icons.quiz_outlined,
            "Lodge Complaint",
            LodgeComplaintScreen.routeName,
            Colors.tealAccent,
            screenWidth,
          ),
          _buildListItem(
            Icons.password_outlined,
            "Change Password",
            ChangePasswordScreen.routeName,
            Colors.redAccent,
            screenWidth,
          ),
          // _buildListItem(Icons.password_outlined, "MCX", MCXStockPage.routeName,
          //     Colors.redAccent, screenWidth),
          _buildLogoutItem(
            Icons.logout,
            "Logout",
            Colors.deepPurple,
            screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    IconData icon,
    String title,
    String routeName,
    Color accentColor,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: GestureDetector(
        onTap: () => _navigateTo(context, routeName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // height: screenWidth * 0.18,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              Icon(icon, color: accentColor, size: screenWidth * 0.07),
              SizedBox(width: screenWidth * 0.04),
              Expanded(child: Text(title).textStyleH1P()),
              Icon(
                Icons.arrow_forward_ios,
                size: screenWidth * 0.025,
                color: Colors.grey[500],
              ),
              SizedBox(width: screenWidth * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem(
    IconData icon,
    String title,
    Color accentColor,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => const CustomDialog(),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // height: screenWidth * 0.18,
          child: Row(
            children: [
              // SizedBox(width: screenWidth * 0.03),
              Icon(icon, color: accentColor, size: screenWidth * 0.07),
              SizedBox(width: screenWidth * 0.04),
              Expanded(child: Text(title).textStyleH1P()),
              Icon(
                Icons.arrow_forward_ios,
                size: screenWidth * 0.025,
                color: Colors.grey[500],
              ),
              SizedBox(width: screenWidth * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeName) {
    GoRouter.of(context).pushNamed(routeName);
    // Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
