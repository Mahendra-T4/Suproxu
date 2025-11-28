import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol_builder.dart';
import 'package:suproxu/features/navbar/profile/notification/notificationScreen.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_symbol_param.dart';

class MCXSymbolRecordPage extends StatefulWidget {
  const MCXSymbolRecordPage({super.key, required this.params});
  static const String routeName = '/MCX-Symbol-Record-Page';
  final MCXSymbolParams params;

  @override
  State<MCXSymbolRecordPage> createState() => _MCXSymbolRecordPageState();
}

class _MCXSymbolRecordPageState extends MCXSymbolWidgetBuilder {
  @override
  Widget build(BuildContext context) {
    // final symbolData = state.data!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: zBlack,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back, color: kGoldenBraunColor),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              Assets.assetsImagesSupertradeNotification,
              scale: 20,
              color: kGoldenBraunColor,
            ),
            onPressed: () {
              context.pushNamed(NotificationScreen.routeName);
            },
          ),
        ],
        title: Text(widget.params.symbol).textStyleH(),
      ),
      body: StreamBuilder<bool>(
        stream: InternetConnectionService().connectionStream,
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return const NoInternetConnection(); // Show your offline UI
          }
          return Builder(
            builder: (context) {
              if (errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            errorMessage = null;
                          });
                          try {
                            webSocket.disconnect();
                          } catch (_) {}
                          webSocket.connect();
                        },
                        child: const Text('Retry Connection'),
                      ),
                    ],
                  ),
                );
              }

              // Show loading indicator while waiting for first data
              if (symbolData.status != 1 && errorMessage == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (symbolData.response.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kWhiteColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => selectedTab = 0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.018,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: selectedTab == 0
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFF00C853),
                                              const Color(
                                                0xFF00C853,
                                              ).withOpacity(0.8),
                                            ],
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: selectedTab == 0
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF00C853,
                                              ).withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.show_chart,
                                        color: selectedTab == 0
                                            ? Colors.white
                                            : Colors.black,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Market",
                                        style: TextStyle(
                                          color: selectedTab == 0
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.h),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => selectedTab = 1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.018,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedTab == 1
                                        ? const Color(0xFF2C2C2E)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: selectedTab == 1
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFF00C853),
                                              const Color(
                                                0xFF00C853,
                                              ).withOpacity(0.8),
                                            ],
                                          )
                                        : null,
                                    boxShadow: selectedTab == 1
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF00C853,
                                              ).withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        color: selectedTab == 1
                                            ? Colors.white
                                            : zBlack,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Order",
                                        style: TextStyle(
                                          color: selectedTab == 1
                                              ? Colors.white
                                              : zBlack,
                                          fontFamily: 'JetBrainsMono',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    symbolData.status == 1
                        ? selectedTab == 0
                              ? marketCrudeoil(
                                  context,
                                  symbolData.response.first.ohlc,
                                  symbolData.response.first,
                                  screenHeight,
                                  screenWidth,
                                )
                              : limitCrudeoil(
                                  context,
                                  symbolData.response.first.ohlc,
                                  symbolData.response.first,
                                  screenHeight,
                                  screenWidth,
                                )
                        : Center(
                            child: Text(
                              symbolData.message.toString(),
                              style: const TextStyle(
                                color: zBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
