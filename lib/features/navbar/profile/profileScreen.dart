import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/service/connectivity/connectivity_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initClientDetails();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  String? uFName;
  String? uLName;
  String? uEmail;
  String? profitLoss;
  String? active;
  String? close;
  String? pending;

  String? uBalance;

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();
    return Container(
      color: greyColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: scaffoldBGColor, // Dark premium background
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: FontFamily.globalFontFamily,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white70),
                onPressed: () {},
              ),
            ],
          ),
          body: connectivity.isConnected
              ? SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent.withOpacity(0.2),
                                  Colors.grey[900]!.withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.blueAccent
                                      .withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Hey, Welcome Back 👋',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: FontFamily.globalFontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$uFName $uLName',
                                  style: TextStyle(
                                    fontFamily: FontFamily.globalFontFamily,
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Row(
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceEvenly,
                                //   children: [
                                //     _buildStatItem('Trades', uTrade.toString(),
                                //         Colors.orangeAccent),
                                //     _buildStatItem('Points', uPoints.toString(),
                                //         Colors.purpleAccent),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Ledger Balance and Margin Available Section
                          _buildLedgerCard(),

                          const SizedBox(height: 24),

                          // Market Sections (NSE, MCX, OPT)
                          // _buildInfoCard(
                          //   "NSE",
                          //   "Per core basis",
                          //   "3000",
                          //   "Per turnover basis",
                          //   "200",
                          //   "50",
                          //   Colors.blueAccent,
                          // ),
                          // const SizedBox(height: 16),
                          // _buildInfoCard(
                          //   "MCX",
                          //   "Per core basis",
                          //   "3000",
                          //   "Per turnover basis",
                          //   "200",
                          //   "50",
                          //   Colors.greenAccent,
                          // ),
                          // const SizedBox(height: 16),
                          // _buildInfoCard(
                          //   "OPT",
                          //   "Per lot basis",
                          //   "25",
                          //   "Per turnover basis",
                          //   "100",
                          //   null,
                          //   Colors.orangeAccent,
                          // ),
                        ],
                      ),
                    ),
                  ),
                )
              : const NoInternetConnection(),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontFamily: FontFamily.globalFontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.globalFontFamily,
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[850]!.withOpacity(0.9),
            Colors.grey[900]!.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ledger Balance',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: FontFamily.globalFontFamily,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.account_balance_wallet, color: Colors.greenAccent),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '\$19,708.07',
            style: TextStyle(
              fontSize: 28,
              fontFamily: FontFamily.globalFontFamily,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Margin Available',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: FontFamily.globalFontFamily,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.insert_chart, color: Colors.orangeAccent),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '\$13,308.57',
            style: TextStyle(
              fontSize: 28,
              fontFamily: FontFamily.globalFontFamily,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String brokerageType,
    String brokerage,
    String exposureType,
    String intradayExposure,
    String? holdingExposure,
    Color accentColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[850]!.withOpacity(0.9),
            Colors.grey[900]!.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontFamily.globalFontFamily,
                  color: accentColor,
                ),
              ),
              Icon(Icons.info_outline, color: accentColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Brokerage Type:', brokerageType, Colors.white70),
          const SizedBox(height: 8),
          _buildInfoRow('Brokerage:', brokerage, Colors.white),
          const SizedBox(height: 8),
          _buildInfoRow('Exposure Type:', exposureType, Colors.white70),
          const SizedBox(height: 8),
          _buildInfoRow('Intraday Exposure:', intradayExposure, Colors.white),
          if (holdingExposure != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Holding Exposure:', holdingExposure, Colors.white),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: FontFamily.globalFontFamily,
            color: Colors.grey[500],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor,
            fontFamily: FontFamily.globalFontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
