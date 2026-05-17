import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/logout/logout.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/service/Auth/user_validation.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/auth/change-pass/changePassword.dart';
import 'package:suproxu/features/navbar/Portfolio/model/active_portfolio_socket_model.dart';
import 'package:suproxu/features/navbar/Portfolio/portfolio.dart';
import 'package:suproxu/features/navbar/Portfolio/websocket/active_portfolio_socket.dart';
import 'package:suproxu/features/navbar/home/providers/wallet_provider.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';
import 'package:suproxu/features/navbar/profile/ledger/ledgerScreen.dart';
import 'package:suproxu/features/navbar/profile/complaint/lodgeComplaint.dart';
import 'package:suproxu/features/navbar/profile/model/balence_entity.dart';
import 'package:suproxu/features/navbar/profile/payment/paymentScreen.dart';
import 'package:suproxu/features/navbar/profile/profile/profile_info.dart';
import 'package:suproxu/features/navbar/profile/wallet/user_wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Timer? _validationTimer;
  StreamSubscription<void>? _logoutSub;
  late ActivePortfolioSocket _activePortfolioSocket;
  ActivePortfolioSocketModel data = ActivePortfolioSocketModel();

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
  late Timer _refreshTimer;

  Future<void> _refreshWishlistData() async {
    debugPrint('Refreshing MCX Wishlist Data');

    if (mounted && _activePortfolioSocket.socket.connected) {
      debugPrint('Socket connected - data will auto-refresh');
    } else if (mounted) {
      _activePortfolioSocket.connect();
    }
  }

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
    _activePortfolioSocket = ActivePortfolioSocket(
      onDataReceived: (newData) {
        log('Portfolio WebSocket Data Received: $newData');
        setState(() {
          data = newData;
          // setState(() {
          //   _isLoading = false;
          // });
        });
      },
      onError: (error) {
        log('WebSocket Error: $error');
      },
      onConnected: () {
        log('WebSocket Connected');
      },
      onDisconnected: () {
        log('WebSocket Disconnected');
      },
    );
    _activePortfolioSocket.connect();

    _refreshTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        _refreshWishlistData();
      }
    });
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    _profileBloc.add(LoadUserWalletDataEvent());
    timer = Timer.periodic(const Duration(seconds: 1), (timer) => userWallet());
    userWallet();

    // Start periodic validation timer (every 10 seconds)
    _validationTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!mounted) return;
      try {
        await AuthService().validateAndLogout(context);
      } catch (e) {
        debugPrint('Account auth validation error: $e');
      }
    });
    // Subscribe to global logout events to cleanup immediately
    _logoutSub = AuthService().onLogout.listen((_) {
      _validationTimer?.cancel();
      debugPrint('Account: handled global logout cleanup');
    });

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
    // Cancel all timers
    _validationTimer?.cancel();
    _refreshTimer.cancel();
    timer?.cancel();

    // Cancel subscriptions
    _logoutSub?.cancel();

    // Disconnect and dispose WebSocket
    _activePortfolioSocket.disconnect();

    // Close BLoC
    _profileBloc.close();

    // Dispose animation controller
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

  Widget _buildLiveRecordHeader(double screenWidth) => Builder(
    builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              GoRouter.of(context).goNamed(Portfolioclose.routeName);
            },
            child: modernStatCard2(
              icon: Icons.account_balance_wallet_rounded,
              label: "Balance",
              value: data.status == 1
                  ? (data.accountStatics?.ledgerBalance ?? 0).toDouble()
                  : 0.0,
              color: Colors.greenAccent,
              screenWidth: screenWidth,
            ),
          ),
          InkWell(
            onTap: () {
              // Navigate to the portfolio page when tapped
              GoRouter.of(context).goNamed(Portfolioclose.routeName);
            },
            child: modernStatCard2(
              icon: Icons.show_chart_rounded,
              label: "Profit & Loss",
              value: data.status == 1
                  ? (data.accountStatics?.activeProfitLoss ?? 0).toDouble()
                  : 0.0,
              color: Colors.purpleAccent,
              screenWidth: screenWidth,
            ),
          ),
        ],
      );
    },
  );

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
          _buildLiveRecordHeader(screenWidth),
          SizedBox(height: screenWidth * 0.04),
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
                  return GestureDetector(
                    onHorizontalDragEnd: (DragEndDetails details) {
                      // TODO: Implement swipe action for future use
                    },
                    child: Column(
                      spacing: 10,
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        //     InkWell(
                        //       onTap: () {
                        //         GoRouter.of(
                        //           context,
                        //         ).goNamed(Portfolioclose.routeName);
                        //       },
                        //       child: modernStatCard2(
                        //         icon: Icons.account_balance_wallet_rounded,
                        //         label: "Balance",
                        //         value:
                        //             wallet.record?.first.availableBalance ?? 0,
                        //         color: Colors.greenAccent,
                        //         screenWidth: screenWidth,
                        //       ),
                        //     ),
                        //     WalletWidget(screenWidth: screenWidth),
                        //   ],
                        // ),
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
                            const SizedBox(width: 10),
                          ],
                        ),
                        // BidirectionalSwipeButton(
                        //   onSwipeLeft: () {
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //         content: Text("Swiped Left"),
                        //         backgroundColor: Colors.red,
                        //       ),
                        //     );
                        //   },
                        //   onSwipeRight: () {
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //         content: Text("Swiped Right"),
                        //         backgroundColor: Colors.green,
                        //       ),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
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
              fontFamily: FontFamily.globalFontFamily,
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
              fontFamily: FontFamily.globalFontFamily,
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

class BidirectionalSwipeButton extends StatefulWidget {
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const BidirectionalSwipeButton({
    Key? key,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  }) : super(key: key);

  @override
  _BidirectionalSwipeButtonState createState() =>
      _BidirectionalSwipeButtonState();
}

class _BidirectionalSwipeButtonState extends State<BidirectionalSwipeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _thumbPosition = 0.0; // 0.0 = left, 1.0 = right
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animation.addListener(() {
      setState(() {
        _thumbPosition = _animation.value;
      });
    });
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _thumbPosition = prefs.getDouble('swipe_button_position') ?? 0.0;
    });
  }

  Future<void> _savePosition(double position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('swipe_button_position', position);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (!_isDragging) return;
    setState(() {
      _thumbPosition += details.delta.dx / trackWidth;
      _thumbPosition = _thumbPosition.clamp(0.0, 1.0);
    });
  }

  void _onDragStart() {
    setState(() {
      _isDragging = true;
    });
    _animationController.stop();
  }

  void _onDragEnd(double trackWidth) {
    setState(() {
      _isDragging = false;
    });

    // Determine if left or right based on position
    if (_thumbPosition < 0.5) {
      // Snap to left
      _animation = Tween<double>(begin: _thumbPosition, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0.0).then((_) {
        _savePosition(0.0);
      });
      widget.onSwipeLeft();
    } else {
      // Snap to right
      _animation = Tween<double>(begin: _thumbPosition, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0.0).then((_) {
        _savePosition(1.0);
      });
      widget.onSwipeRight();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth - 60; // Account for thumb size
        final thumbSize = 50.0;

        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Stack(
            children: [
              // Track
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _thumbPosition >= 0.5 ? "YES" : "NO",
                      style: TextStyle(
                        color: _thumbPosition >= 0.5
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _thumbPosition >= 0.5
                          ? "Swipe right for YES"
                          : "Swipe left for NO",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Thumb
              Positioned(
                left: _thumbPosition * trackWidth,
                top: 5,
                child: GestureDetector(
                  onHorizontalDragStart: (_) => _onDragStart(),
                  onHorizontalDragUpdate: (details) =>
                      _onDragUpdate(details, trackWidth),
                  onHorizontalDragEnd: (_) => _onDragEnd(trackWidth),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: _thumbPosition < 0.5
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _thumbPosition < 0.5
                          ? Icons.arrow_back
                          : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
