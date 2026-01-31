import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/Assets/font_family.dart';
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
      // backgroundColor: zBlack,
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
              // if (errorMessage != null) {
              //   return Center(
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Text(
              //           'Error: $errorMessage',
              //           style: const TextStyle(color: Colors.red),
              //           textAlign: TextAlign.center,
              //         ),
              //         const SizedBox(height: 16),
              //         ElevatedButton(
              //           onPressed: () {
              //             setState(() {
              //               errorMessage = null;
              //             });
              //             try {
              //               webSocket.disconnect();
              //             } catch (_) {}
              //             webSocket.connect();
              //           },
              //           child: const Text('Retry Connection'),
              //         ),
              //       ],
              //     ),
              //   );
              // }

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
                      height: screenHeight * 0.08,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: lvoryWhiteColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: .5,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Stack(
                          children: [
                            // Animated Sliding Background Indicator
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              alignment: selectedTab == 0
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Container(
                                width:
                                    (MediaQuery.of(context).size.width - 48) /
                                    2, // Half width minus padding/margin
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.018,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedTab == 0
                                      ? aquaGreyColor.withOpacity(.6)
                                      : aquaGreyColor.withOpacity(.6),

                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            // Tab Buttons (on top of the sliding background)
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => selectedTab = 0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.018,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedScale(
                                            scale: selectedTab == 0
                                                ? 1.05
                                                : 1.0,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: Icon(
                                              Icons.show_chart,
                                              color: selectedTab == 0
                                                  ? Colors.black
                                                  : aquaGreyColor,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            style: TextStyle(
                                              color: selectedTab == 0
                                                  ? Colors.black
                                                  : aquaGreyColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18.5,
                                              letterSpacing: 2,
                                            ),
                                            child: const Text(
                                              "MARKET",
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.globalFontFamily,
                                              ),
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
                                    onTap: () =>
                                        setState(() => selectedTab = 1),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.018,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedScale(
                                            scale: selectedTab == 1
                                                ? 1.05
                                                : 1.0,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: Icon(
                                              Icons.receipt_long,
                                              color: selectedTab == 1
                                                  ? Colors.black
                                                  : aquaGreyColor,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            style: TextStyle(
                                              color: selectedTab == 1
                                                  ? Colors.black
                                                  : aquaGreyColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18.5,
                                              letterSpacing: 2,
                                            ),
                                            child: const Text(
                                              "ORDER",
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.globalFontFamily,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                fontFamily: FontFamily.globalFontFamily,
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
