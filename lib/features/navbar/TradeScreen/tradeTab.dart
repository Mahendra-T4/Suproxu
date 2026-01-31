import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/TradeScreen/pending_trade.dart';
import 'package:suproxu/features/navbar/TradeScreen/tradeActive.dart';
import 'package:suproxu/features/navbar/TradeScreen/tradeCloseScreen.dart';

class TradeTabsScreen extends StatefulWidget {
  const TradeTabsScreen({super.key});

  static const String routeName = '/trade-screen';

  @override
  // ignore: library_private_types_in_public_api
  _TradeTabsScreenState createState() => _TradeTabsScreenState();
}

class _TradeTabsScreenState extends State<TradeTabsScreen> {
  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: InternetConnectionService().connectionStream,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return const NoInternetConnection(); // Show your offline UI
        }
        return DefaultTabController(
          length: 3,
          child: Builder(
            builder: (context) {
              return Container(
                color: greyColor,
                child: SafeArea(
                  child: Scaffold(
                    backgroundColor: kWhiteColor,
                    appBar: customAppBar(context: context, isShowNotify: true),
                    body: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            // controller: _tabController,
                            dividerColor: Colors.transparent,
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                width: 4.0,
                                color: kGoldenBraunColor,
                              ),
                              insets: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              fontFamily: FontFamily.globalFontFamily,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: kGoldenBraunColor,
                            unselectedLabelColor: Colors.grey[600],
                            tabs: const [
                              Tab(text: "Active"),
                              Tab(text: "Pending"),

                              Tab(text: "Closed"),
                            ],
                          ),
                        ),
                        const Expanded(
                          child: TabBarView(
                            children: [
                              //Tab Bar Screens ClassName

                              // "Pending" Tab Content
                              Tradeactive(),
                              PendingTab(),

                              ClosedOrdersTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // : const NoInternetConnection(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildTradeCategories() {
    return Container(
      height: 90.h,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildCategoryButton('MCX\nTrades', Icons.currency_exchange),
          _buildCategoryButton('Equity\nTrades', Icons.trending_up),
          _buildCategoryButton('Options\nTrades', Icons.style),
          _buildCategoryButton('Crypto\nTrades', Icons.currency_bitcoin),
        ],
      ),
    );
  }

  void _onCategorySelected(String category) {
    // Implement category selection logic
  }

  Widget _buildCategoryButton(String text, IconData icon) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      // height: 70,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onCategorySelected(text),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.2),
                  Colors.blue.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.blue, size: 24.r),
                SizedBox(height: 4.h),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontFamily: FontFamily.globalFontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabContent extends StatelessWidget {
  final List<OrderCard> orders;

  const TabContent({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return orders[index];
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final String type;
  final int quantity;
  final String status;
  final String stockName;
  final String expiryDate;
  final String traderId;
  final String orderPlaced;
  final String orderTriggered;

  const OrderCard({
    super.key,
    required this.type,
    required this.quantity,
    required this.status,
    required this.stockName,
    required this.expiryDate,
    required this.traderId,
    required this.orderPlaced,
    required this.orderTriggered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[900]!.withOpacity(0.95),
            Colors.grey[850]!.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildStockIcon(),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stockName,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: FontFamily.globalFontFamily,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              expiryDate,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: FontFamily.globalFontFamily,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildTradeStatus(status),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(color: Colors.grey[800], height: 1),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      'Type',
                      type,
                      type == 'BUY' ? Colors.green : Colors.red,
                    ),
                    _buildInfoColumn(
                      'Quantity',
                      quantity.toString(),
                      Colors.white,
                    ),
                    _buildInfoColumn('ID', '#$traderId', Colors.blue),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildTimelineInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockIcon() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.show_chart, color: Colors.blue, size: 24.r),
    );
  }

  Widget _buildTradeStatus(String status) {
    final isCompleted = status == 'COMPLETED';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.cancel,
            color: isCompleted ? Colors.green : Colors.red,
            size: 16.r,
          ),
          SizedBox(width: 6.w),
          Text(
            status,
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.red,
              fontSize: 12.sp,
              fontFamily: FontFamily.globalFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontFamily: FontFamily.globalFontFamily,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14.sp,
            fontFamily: FontFamily.globalFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineInfo() {
    return Column(
      children: [
        _buildTimelineItem(
          'Order Placed',
          orderPlaced,
          Icons.schedule,
          Colors.blue,
          isFirst: true,
        ),
        _buildTimelineItem(
          'Order Triggered',
          orderTriggered,
          Icons.check_circle,
          Colors.green,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String label,
    String time,
    IconData icon,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Container(
          width: 2,
          height: 30.h,
          color: isFirst ? Colors.transparent : Colors.grey[800],
          margin: EdgeInsets.symmetric(horizontal: 11.w),
        ),
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14.r),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontFamily: FontFamily.globalFontFamily,
                fontSize: 12.sp,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                fontFamily: FontFamily.globalFontFamily,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ScrollableButtonRow extends StatelessWidget {
  const ScrollableButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Wrap(
              spacing: 8,
              children: [
                _buildTopButton('Close Active\nTrades MCX'),
                _buildTopButton('Close Active\nTrades Equity'),
                _buildTopButton('Close Active\nTrades OPT'),
                _buildTopButton('Close Active\nTrades Cry'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(width: 1, color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontFamily: FontFamily.globalFontFamily,
          color: Colors.black,
        ),
      ),
    );
  }
}

Widget _buildPortfolioItem(
  String name,
  String date,
  int qty,
  double? avgSell,
  double? avgBuy,
  double? profitLoss,
) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: Colors.transparent,
    child: Container(
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
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: FontFamily.globalFontFamily,
                  letterSpacing: 0.5,
                ),
              ),
              if (profitLoss != null)
                Text(
                  '${profitLoss > 0 ? '+' : ''}$profitLoss',
                  style: TextStyle(
                    color: profitLoss > 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: FontFamily.globalFontFamily,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty: $qty',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontFamily: FontFamily.globalFontFamily,
                  fontSize: 14,
                ),
              ),
              if (avgSell != null && avgBuy != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Avg Sell: $avgSell',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontFamily: FontFamily.globalFontFamily,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Avg Buy: $avgBuy',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontFamily: FontFamily.globalFontFamily,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
