import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/extensions/double_etx.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/extensions/color_ext.dart';
import 'package:suproxu/core/extensions/neg-pos-tracker.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/service/Auth/user_validation.dart';
import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol.dart';
import 'package:suproxu/features/navbar/home/model/buy_sale_entity.dart';
import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';
import 'package:suproxu/features/navbar/home/websocket/mcx_symbol_websocket.dart';

abstract class MCXSymbolWidgetBuilder extends State<MCXSymbolRecordPage> {
  final ValueNotifier<int> lotsNotifierMrk = ValueNotifier<int>(1);
  late MCXSymbolWebSocketService webSocket;
  GetStockRecordEntity symbolData = GetStockRecordEntity();
  String? errorMessage;
  dynamic orderSellPrice;
  dynamic orderBuyPrice;

  final ValueNotifier<int> lotsNotifierLmt = ValueNotifier<int>(1);
  final TextEditingController usernameController = TextEditingController(
    text: 0.toString(),
  );
  final TextEditingController lotsMktController = TextEditingController(
    text: '1',
  );
  final TextEditingController lotsOdrController = TextEditingController(
    text: '1',
  );
  int lots = 1; // Variable to track the lot count
  int selectedTab = 0;
  bool isBuyClicked = false;
  bool isSellClicked = false;
  bool isMarketOpen = true;

  late Timer timer;
  Timer? _validationTimer;
  StreamSubscription<void>? _logoutSub;

  void initMCXSymbolWebSocket() {
    // First, ensure any previous socket is fully cleaned up
    if (!mounted) return;
    setState(() {});
    try {
      webSocket.disconnect();
    } catch (_) {}

    webSocket = MCXSymbolWebSocketService(
      symbolKey: widget.params.symbolKey,
      onDataReceived: (data) {
        // Forward socket data into the broadcast stream so UI can react via StreamBuilder
        if (!mounted) return;
        try {
          // Extra validation: ensure response contains the requested symbol
          final hasMatchingSymbol =
              data.response.isNotEmpty &&
              data.response.any(
                (r) => r.symbolKey.trim() == widget.params.symbolKey.trim(),
              );

          if (!hasMatchingSymbol) {
            log(
              '⚠ Rejected data: no matching symbolKey. Expected: ${widget.params.symbolKey}',
            );
            return;
          }

          setState(() {
            symbolData = data; // keep a copy for quick access if needed
            errorMessage = null;
          });
        } catch (e) {
          log('Error updating symbolData in state: $e');
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          errorMessage = error;
        });
      },
      onConnected: () {
        if (!mounted) return;
        setState(() {
          // clear any previous error on reconnect
          errorMessage = null;
        });
        // Seed the UI with an HTTP fallback once socket connected
      },
      onDisconnected: () {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Connection lost. Trying to reconnect...';
        });
      },
    );

    webSocket.connect();
  }

  final client = http.Client();
  final url = Uri.parse(superTradeBaseApiEndPointUrl);
  dynamic uBalance;

  /// Fetch initial data via HTTP to show immediately while WebSocket connects
  Future<void> _fetchInitialDataViaHttp() async {
    try {
      DatabaseService databaseService = DatabaseService();
      final userKey = await databaseService.getUserData(key: userIDKey);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final deviceID = androidInfo.id.toString();

      final response = await client
          .post(
            url,
            body: {
              'activity': 'get-stock-record',
              'userKey': userKey,
              'symbolKey': widget.params.symbolKey,
              'dataRelatedTo': 'MCX',
              'deviceID': deviceID.toString(),
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => http.Response('timeout', 408),
          );

      if (response.statusCode == 200) {
        if (!mounted) return;
        try {
          final jsonResponse = jsonDecode(response.body);
          final data = GetStockRecordEntity.fromJson(jsonResponse);

          if (data.status == 1 && data.response.isNotEmpty) {
            setState(() {
              symbolData = data;
              errorMessage = null;
            });
            log('Initial HTTP data loaded successfully');
          }
        } catch (e) {
          log('Failed to parse initial HTTP response: $e');
        }
      }
    } catch (e) {
      log('Initial HTTP fetch error: $e');
      // Continue silently - WebSocket will handle it
    }
  }

  Future<void> buyStock({
    required String symbolKey,
    required String activity,
    required String categoryName,
    required String stockPrice,
    required String stockQty,
    required BuildContext context,
  }) async {
    BuySaleEntity buySaleEntity = BuySaleEntity();
    try {
      DatabaseService databaseService = DatabaseService();
      final userKey = await databaseService.getUserData(key: userIDKey);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final deviceID = androidInfo.id.toString();

      setState(() {
        isBuyClicked = true;
      });
      final response = await client.post(
        url,
        body: {
          // 'activity': 'buy-stock',
          'activity': activity,
          'userKey': userKey,
          'symbolKey': symbolKey, // Fixed typo: 'symbolKey:' to 'symbolKey'
          'dataRelatedTo': categoryName,
          "deviceID": deviceID.toString(),
          'stockPrice': stockPrice,

          'stockQty': stockQty,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          isBuyClicked = false;
        });
        log('buy stock message =>> ${jsonResponse['message']}');
        buySaleEntity = BuySaleEntity.fromJson(jsonResponse);

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  jsonResponse['status'] == 1
                      ? Lottie.asset(
                          Assets.assetsImagesSupertradeGreenAnimation,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        )
                      : Lottie.asset(
                          Assets.assetsImagesSupertradeFailedGreenAnimation,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                  SizedBox(height: 16.h),
                  Text(
                    buySaleEntity.message.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: FontFamily.globalFontFamily,
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: FontFamily.globalFontFamily,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
        // return BuySaleEntity.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          log('Buy Stock Error => ${response.body}');
        }
        // return BuySaleEntity(
        //   status: 0,
        //   message: 'failed to load Stock Buy data',
        // );
      }
    } catch (e) {
      log('Buy Stock Repo Error =>> $e'); // Changed message for clarity
      // return BuySaleEntity(
      //   status: 0,
      //   message: 'failed to load Stock Buy data',
      // );
    }
    // return buySaleEntity;
  }

  Future<void> saleStock({
    required String symbolKey,
    required String categoryName,
    required String activity,
    required String stockPrice,
    required String stockQty,
    required BuildContext context,
  }) async {
    BuySaleEntity buySaleEntity = BuySaleEntity();
    try {
      DatabaseService databaseService = DatabaseService();
      final userKey = await databaseService.getUserData(key: userIDKey);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final deviceID = androidInfo.id.toString();
      if (!mounted) return;
      setState(() {
        isSellClicked = true;
      });
      final response = await client.post(
        url,
        body: {
          // 'activity': 'sale-stock',
          'activity': activity,
          'userKey': userKey,
          'symbolKey': symbolKey, // Fixed typo: 'symbolKey:' to 'symbolKey'
          'dataRelatedTo': categoryName,
          'stockPrice': stockPrice,
          "deviceID": deviceID.toString(),
          'stockQty': stockQty,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        buySaleEntity = BuySaleEntity.fromJson(jsonResponse);

        setState(() {
          isSellClicked = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  jsonResponse['status'] == 1
                      ? Lottie.asset(
                          Assets.assetsImagesSupertradeRedAnimation,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        )
                      : Lottie.asset(
                          Assets.assetsImagesSupertradeFailedRedAnimation,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                  SizedBox(height: 16.h),
                  Text(
                    buySaleEntity.message.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: FontFamily.globalFontFamily,
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"),
                  ),
                ),
              ],
            );
          },
        );

        log('sale stock message =>> ${jsonResponse['message']}');

        // return BuySaleEntity.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          log('Sale Stock Error => ${response.body}');
        }
        // return BuySaleEntity(
        //   status: 0,
        //   message: 'failed to load Stock Sale data',
        // );
      }
    } catch (e) {
      log('Sale Stock Repo Error =>> $e');
      // return BuySaleEntity(
      //   status: 0,
      //   message: 'failed to load Stock Sale data',
      // );
    }
    // return buySaleEntity;
  }

  initUser() async {
    DatabaseService databaseService = DatabaseService();
    final userBalance = await databaseService.getUserData(key: userBalanceKey);
    if (!mounted) return;
    setState(() {
      uBalance = userBalance;
    });
  }

  void _checkMarketStatus() {
    final now = DateTime.now();
    final marketOpenTime = DateTime(now.year, now.month, now.day, 9, 15);
    final marketCloseTime = DateTime(now.year, now.month, now.day, 23, 00);

    // Make sure the system is not on Saturday or Sunday
    final isWeekday =
        now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;

    final newMarketStatus =
        isWeekday &&
        now.isAfter(marketOpenTime) &&
        now.isBefore(marketCloseTime);

    if (isMarketOpen != newMarketStatus) {
      if (!mounted) return;
      setState(() {
        isMarketOpen = newMarketStatus;
      });
    }

    print('Now: $now');
    print('Market Open Time: $marketOpenTime');
    print('Market Close Time: $marketCloseTime');
    print('Market Status: $isMarketOpen');
  }

  var record;
  var ohlcMCX;

  @override
  void initState() {
    super.initState();
    _validationTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!mounted) return;
      try {
        await AuthService().validateAndLogout(context);
      } catch (e) {
        log('MCX symbol auth validation error: $e');
      }
    });
    _logoutSub = AuthService().onLogout.listen((_) {
      _validationTimer?.cancel();
      try {
        webSocket.disconnect();
      } catch (_) {}
      log('MCX symbol: handled global logout cleanup');
    });
    initMCXSymbolWebSocket();
    _fetchInitialDataViaHttp(); // Fetch data immediately via HTTP while WebSocket connects
    initUser();

    // Setup lots notifier listeners
    lotsNotifierMrk.addListener(() {
      lotsMktController.text = lotsNotifierMrk.value.toString();
    });

    lotsNotifierLmt.addListener(() {
      lotsOdrController.text = lotsNotifierLmt.value.toString();
      log('Lots value changed: ${lotsNotifierLmt.value}');
    });

    // Setup periodic updates - REDUCED to 5 seconds (was 500ms causing blinking)
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      initUser();
      _checkMarketStatus();
    });

    initUser();
    _checkMarketStatus();

    // Fallback: If no data arrives in 2 seconds, auto-retry socket connection
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && (symbolData.status != 1 || symbolData.response.isEmpty)) {
        try {
          webSocket.disconnect();
        } catch (_) {}
        webSocket.connect();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _validationTimer?.cancel();
    _logoutSub?.cancel();
    try {
      webSocket.disconnect();
    } catch (_) {}

    // widget.params.symbolKey = '';

    usernameController.dispose();
    lotsMktController.dispose();
    lotsOdrController.dispose();
    lotsNotifierMrk.dispose();
    lotsNotifierLmt.dispose();
    super.dispose();
  }

  Widget marketCrudeoil(
    BuildContext context,
    OhlcGetRecord ohlc,
    ResponseGetRecord response,
    double screenHeight,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: screenWidth * 0.03,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: screenHeight * 0.03),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: lvoryWhiteColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("LOT'S").textStyleH11Color(),
                  ValueListenableBuilder<int>(
                    valueListenable: lotsNotifierMrk,
                    builder: (context, lots, child) {
                      return Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  lots > 1 ? lotsNotifierMrk.value-- : null,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: aquaGreyColor.withOpacity(0.6),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: zBlack,
                                  size: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: screenWidth * 0.20,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: aquaGreyColor.withOpacity(0.6),
                            ),
                            child: TextField(
                              controller: lotsMktController,
                              textAlign: TextAlign.center,

                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                color: zBlack,
                                fontFamily: FontFamily.globalFontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final newLots = int.tryParse(value) ?? 1;
                                  if (newLots > 0) {
                                    lotsNotifierMrk.value = newLots;
                                    log('Lots updated: $newLots');
                                  }
                                }
                              },
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => lotsNotifierMrk.value++,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: aquaGreyColor.withOpacity(0.6),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: zBlack,
                                  size: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isSellClicked
                      ? SizedBox(
                          width: screenWidth / 2.5,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greyColor,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'PROCESSING...',
                              textAlign: TextAlign.center,
                            ).textStyleH1(),
                          ),
                        )
                      : Container(
                          width: screenWidth / 2.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xffd00000),
                            // gradient: const LinearGradient(
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            //   colors: [Color(0xFFFF3B30), Color(0xFFFF3B30)],
                            // ),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: const Color(0xFFFF3B30).withOpacity(0.3),
                            //     spreadRadius: 1,
                            //     blurRadius: 8,
                            //     offset: const Offset(0, 4),
                            //   ),
                            // ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                saleStock(
                                  activity: 'sale-stock',
                                  context: context,
                                  symbolKey: response.symbolKey,
                                  categoryName: 'MCX',
                                  stockPrice:
                                      '${ohlc.salePrice} * ${lotsNotifierMrk.value}',
                                  stockQty: lotsNotifierMrk.value.toString(),
                                );
                                // if (isMarketOpen) {
                                //   // saleStock(
                                //   //   activity: 'sale-stock',
                                //   //   context: context,
                                //   //   symbolKey: response.symbolKey,
                                //   //   categoryName: 'MCX',
                                //   //   stockPrice:
                                //   //       '${ohlc.salePrice} * ${lotsNotifierMrk.value}',
                                //   //   stockQty: lotsNotifierMrk.value.toString(),
                                //   // );
                                // } else {
                                //   showDialog(
                                //     context: context,
                                //     builder: (context) => const WarningAlertBox(
                                //       title: 'Warning',
                                //       message:
                                //           'Market Closed You Cant Sale Stocks!',
                                //     ),
                                //   );
                                // }

                                // if (ohlc.salePrice > parsedUBalance) {
                                //   showDialog(
                                //     context: context,
                                //     builder: (context) => const WarningAlertBox(
                                //       title: 'Warning',
                                //       message:
                                //           'You Cant Sale Stock Your Balance is Low!',
                                //     ),
                                //   );
                                // } else {

                                // }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.02,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.sell,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text("SELL").textStyleH1W(),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${formatDoubleNumber(response.ohlc.salePrice)}",
                                    ).textStyleH1W(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  SizedBox(width: screenWidth * 0.03),
                  isBuyClicked
                      ? SizedBox(
                          width: screenWidth / 2.5,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greyColor,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'PROCESSING...',
                              textAlign: TextAlign.center,
                            ).textStyleH1(),
                          ),
                        )
                      : Container(
                          width: screenWidth / 2.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xff208b3a),
                            // gradient: const LinearGradient(
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            //   colors: [Color(0xFF34C759), Color(0xFF34C759)],
                            // ),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: const Color(0xFF34C759).withOpacity(0.3),
                            //     spreadRadius: 1,
                            //     blurRadius: 8,
                            //     offset: const Offset(0, 4),
                            //   ),
                            // ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                buyStock(
                                  activity: 'buy-stock',
                                  context: context,
                                  symbolKey: response.symbolKey,
                                  categoryName: 'MCX',
                                  stockPrice:
                                      '${ohlc.buyPrice} * ${lotsNotifierMrk.value}',
                                  stockQty: lotsNotifierMrk.value.toString(),
                                );
                                // if (isMarketOpen) {

                                // } else {
                                //   showDialog(
                                //     context: context,
                                //     builder: (context) => const WarningAlertBox(
                                //       title: 'Warning',
                                //       message:
                                //           'Market Closed You Cant Buy Stocks!',
                                //     ),
                                //   );
                                // }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.02,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.shopping_cart,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text("BUY").textStyleH1W(),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${formatDoubleNumber(response.ohlc.buyPrice)}",
                                    ).textStyleH1W(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Container(
              margin: EdgeInsets.only(top: 10.w, bottom: 10),
              padding: EdgeInsets.all(10.r),
              // width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: lvoryWhiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60,
                          margin: EdgeInsets.only(right: 4.w),
                          width: screenWidth * 0.20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.blink(
                              baseValue: ohlc.lastPrice,
                              compValue: ohlc.salePrice,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sell Price").textStyleH2S(),
                              const SizedBox(height: 4),
                              Text(
                                ohlc.salePrice.toString(),
                                style: const TextStyle(
                                  color: zBlack,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.globalFontFamily,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // _buildInfoBox(
                        //     "Bid", ohlc.salePrice.toString(), screenWidth),
                        Container(
                          height: 60,
                          // margin: EdgeInsets.only(right: 4.w),
                          width: screenWidth * 0.20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.blink(
                              baseValue: ohlc.lastPrice,
                              compValue: ohlc.buyPrice,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Buy Price").textStyleH2S(),
                              const SizedBox(height: 4),
                              Text(
                                response.ohlc.buyPrice.toString(),
                                style: const TextStyle(
                                  color: zBlack,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.globalFontFamily,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // _buildInfoBox(
                        //     "Ask", ohlc.buyPrice.toString(), screenWidth),
                        _buildInfoBox(
                          "Ltp",
                          ohlc.lastPrice.toString(),
                          screenWidth,
                        ),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBox("Open", ohlc.open.toString(), screenWidth),

                      _buildInfoBox(
                        "Close",
                        ohlc.close.toString().toString(),
                        screenWidth,
                      ),

                      _buildInfoBox(
                        "ATP",
                        response.averageTradePrice.toString(),
                        screenWidth,
                      ),

                      // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoBox(
                          "High",
                          ohlc.high.toString().toString(),
                          screenWidth,
                        ),

                        _buildInfoBox("Low", ohlc.low.toString(), screenWidth),

                        _buildInfoBox(
                          "Volume",
                          ohlc.volume.toString(),
                          screenWidth,
                        ),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoBox(
                          "Upper ckt",
                          response.upperCKT.toString(),
                          screenWidth,
                        ),

                        _buildInfoBox(
                          "Lower ckt",
                          response.lowerCKT.toString(),
                          screenWidth,
                        ),

                        Container(
                          height: 60,
                          width: screenWidth * 0.20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.valueColor(response.change),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Change",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: FontFamily.globalFontFamily,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                response.change.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.globalFontFamily,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // _buildInfoBox("Change", response.change, screenWidth),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoBox(
                          "Last Buy",
                          response.lastBuy.price,
                          screenWidth,
                        ),

                        _buildInfoBox(
                          "Last Sell",
                          response.lastSell.price,
                          screenWidth,
                        ),

                        _buildInfoBox(
                          "Lot Size",
                          response.lotSize.toString(),
                          screenWidth,
                        ),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // _buildInfoBox("Buyer", 'N/A', screenWidth),

                        // _buildInfoBox("Seller", 'N/A', screenWidth),
                        _buildInfoBox(
                          "Open Interest",
                          response.openInterest,
                          screenWidth,
                        ),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget limitCrudeoil(
    BuildContext context,
    OhlcGetRecord ohlc,
    ResponseGetRecord response,
    double screenHeight,
    double screenWidth,
  ) {
    orderBuyPrice = ohlc.buyPrice;
    orderSellPrice = ohlc.salePrice;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015,
          horizontal: screenWidth * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: screenHeight * 0.03),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: lvoryWhiteColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("LOT'S").textStyleH11Color(),
                  ValueListenableBuilder<int>(
                    valueListenable: lotsNotifierLmt,
                    builder: (context, lots, child) {
                      return Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (lots > 1) {
                                  lotsNotifierLmt.value--;
                                  log(
                                    'Lots decreased to: ${lotsNotifierLmt.value}',
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: aquaGreyColor.withOpacity(0.6),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: zBlack,
                                  size: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: screenWidth * 0.20,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: aquaGreyColor.withOpacity(0.6),
                            ),
                            child: TextField(
                              controller: lotsOdrController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                color: zBlack,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final newLots = int.tryParse(value) ?? 1;
                                  if (newLots > 0) {
                                    lotsNotifierLmt.value = newLots;
                                    log('Lots updated: $newLots');
                                  }
                                }
                              },
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                lotsNotifierLmt.value++;
                                log(
                                  'Lots increased to: ${lotsNotifierLmt.value}',
                                );
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: aquaGreyColor.withOpacity(0.6),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: zBlack,
                                  size: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: aquaGreyColor.withOpacity(0.6),
              ),
              child: TextFormField(
                controller: usernameController,
                style: TextStyle(
                  color: zBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  // labelText: "Price",
                  labelStyle: TextStyle(
                    color: zBlack,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 16),
                    child: Text(
                      'Price :  ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: FontFamily.globalFontFamily,
                        fontSize: 20,
                        color: zBlack,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: const Color(0xFF00C853),
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFF00C853),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: lvoryWhiteColor,
                ),
                keyboardType: TextInputType.number,
                cursorColor: const Color(0xFF00C853),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isSellClicked
                      ? SizedBox(
                          width: screenWidth / 2.5,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greyColor,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'PROCESSING...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.045,
                                fontFamily: FontFamily.globalFontFamily,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SizedBox(
                          width: screenWidth / 2.5,
                          child: ElevatedButton(
                            onPressed: () {
                              if (double.parse(usernameController.text) >
                                      double.parse(ohlc.salePrice.toString()) ||
                                  double.parse(usernameController.text) <
                                      double.parse(ohlc.buyPrice.toString())) {
                                saleStock(
                                  activity: 'sale-stock-order',
                                  context: context,
                                  symbolKey: widget.params.symbolKey,
                                  categoryName: 'MCX',
                                  stockPrice:
                                      '${usernameController.text} * ${lotsNotifierLmt.value}',
                                  stockQty: lotsNotifierLmt.value.toString(),
                                );
                              } else {
                                waringToast(
                                  context,
                                  'You Cant Sale Stock Your Price is not in Range!',
                                );
                              }
                              // if (isMarketOpen) {

                              // } else {
                              //   showDialog(
                              //     context: context,
                              //     builder: (context) => const WarningAlertBox(
                              //       title: 'Warning',
                              //       message:
                              //           'Market Closed You Cant Sale Stocks!',
                              //     ),
                              //   );
                              // }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffd00000),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.sell,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text("SELL").textStyleH1W(),
                                  ],
                                ),
                                Text(
                                  (() {
                                    final double price =
                                        double.tryParse(
                                          usernameController.text,
                                        ) ??
                                        orderSellPrice;
                                    // final int lots = lotsNotifierLmt.value;
                                    // final double total = price * lots;
                                    return '${price.toStringAsFixed(2)}';
                                  })(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.045,
                                    fontFamily: FontFamily.globalFontFamily,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                  SizedBox(width: screenWidth * 0.02),
                  isBuyClicked
                      ? SizedBox(
                          width: screenWidth / 2.5,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greyColor,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'PROCESSING...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.045,
                                fontFamily: FontFamily.globalFontFamily,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SizedBox(
                          width: screenWidth / 2.5,
                          child: ElevatedButton(
                            onPressed: () {
                              if (double.parse(usernameController.text) >
                                      double.parse(ohlc.salePrice.toString()) ||
                                  double.parse(usernameController.text) <
                                      double.parse(ohlc.buyPrice.toString())) {
                                buyStock(
                                  activity: 'buy-stock-order',
                                  context: context,
                                  symbolKey: widget.params.symbolKey,
                                  categoryName: 'MCX',
                                  stockPrice:
                                      '${usernameController.text} * ${lotsNotifierLmt.value}',
                                  stockQty: lotsNotifierLmt.value.toString(),
                                );
                              } else {
                                waringToast(
                                  context,
                                  'You Cant Buy Stock Your Price is not in Range!',
                                );
                              }
                              // if (isMarketOpen) {

                              // } else {
                              //   showDialog(
                              //     context: context,
                              //     builder: (context) => const WarningAlertBox(
                              //       title: 'Warning',
                              //       message:
                              //           'Market Closed You Cant Buy Stocks!',
                              //     ),
                              //   );
                              // }
                              // dynamic canBuy = (ohlc.buyPrice) *
                              //     (lotsNotifierLmt.value) *
                              //     response.lotSize;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff208b3a),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text("BUY").textStyleH1W(),
                                  ],
                                ),
                                Text(
                                  (() {
                                    final double price =
                                        double.tryParse(
                                          usernameController.text,
                                        ) ??
                                        orderBuyPrice;
                                    // final int lots = lotsNotifierLmt.value;
                                    // final double total = price * lots;
                                    return '${price.toStringAsFixed(2)}';
                                  })(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.045,
                                    fontFamily: FontFamily.globalFontFamily,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Container(
              margin: EdgeInsets.only(top: 10.w),
              padding: EdgeInsets.all(10.r),
              // width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: lvoryWhiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60,
                          margin: EdgeInsets.only(right: 4.w),
                          width: screenWidth * 0.20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.blink(
                              baseValue: ohlc.lastPrice,
                              compValue: ohlc.salePrice,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Sell Price",
                                style: const TextStyle(
                                  color: zBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.globalFontFamily,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                response.ohlc.salePrice.toString(),
                                style: const TextStyle(
                                  color: zBlack,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.globalFontFamily,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // _buildInfoBox(
                        //     "Bid", ohlc.salePrice.toString(), screenWidth),
                        Container(
                          height: 60,
                          // margin: EdgeInsets.only(right: 4.w),
                          width: screenWidth * 0.25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.blink(
                              baseValue: ohlc.lastPrice,
                              compValue: ohlc.buyPrice,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Buy Price",
                                style: const TextStyle(
                                  color: zBlack,
                                  fontSize: 12,
                                  fontFamily: FontFamily.globalFontFamily,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                response.ohlc.buyPrice.toString(),
                                style: const TextStyle(
                                  color: zBlack,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.globalFontFamily,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        _buildInfoBox(
                          "Ltp",
                          ohlc.lastPrice.toString(),
                          screenWidth,
                        ),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoBox(
                          "Open",
                          ohlc.open.toString(),
                          screenWidth,
                        ),

                        _buildInfoBox(
                          "Close",
                          ohlc.close.toString().toString(),
                          screenWidth,
                        ),

                        _buildInfoBox(
                          "ATP",
                          response.averageTradePrice,
                          screenWidth,
                        ),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoBox(
                          "High",
                          ohlc.high.toString().toString(),
                          screenWidth,
                        ),

                        _buildInfoBox("Low", ohlc.low.toString(), screenWidth),

                        _buildInfoBox(
                          "Volume",
                          ohlc.volume.toString(),
                          screenWidth,
                        ),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoBox(
                          "Upper ckt",
                          response.upperCKT,
                          screenWidth,
                        ),

                        _buildInfoBox(
                          "Lower ckt",
                          response.lowerCKT,
                          screenWidth,
                        ),

                        Container(
                          height: 60,
                          width: screenWidth * 0.20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.valueColor(response.change),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Change",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: FontFamily.globalFontFamily,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                response.change.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.globalFontFamily,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // _buildInfoBox("Change", response.change, screenWidth),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoBox(
                          "Last Buy",
                          response.lastBuy.price,
                          screenWidth,
                        ),

                        _buildInfoBox(
                          "Last Sell",
                          response.lastSell.price,
                          screenWidth,
                        ),

                        _buildInfoBox(
                          "Lot Size",
                          response.lotSize.toString(),
                          screenWidth,
                        ),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // _buildInfoBox("Buyer", 'N/A', screenWidth),

                        // _buildInfoBox("Seller", 'N/A', screenWidth),
                        _buildInfoBox(
                          "Open Interest",
                          response.openInterest,
                          screenWidth,
                        ),

                        // _buildInfoBox("CLOSE", ohlc.close.toString(), screenWidth),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, dynamic value, double screenWidth) {
    return Container(
      height: 60,
      width: screenWidth * 0.20,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label).textStyleH2S(),
          const SizedBox(height: 4),
          Text(value.toString()).textStyleH1(),
        ],
      ),
    );
  }
}
