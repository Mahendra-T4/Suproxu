import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:suproxu/Assets/assets.dart';
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
import 'package:suproxu/features/navbar/home/model/buy_sale_entity.dart';
import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';
import 'package:suproxu/features/navbar/home/model/symbol_page_param.dart';
import 'package:suproxu/features/navbar/home/nse-future/models/nfo.dart';
import 'package:suproxu/features/navbar/home/websocket/nfo_symbol_ws.dart';
import 'package:suproxu/features/navbar/profile/notification/notificationScreen.dart';

class NseFutureSymbolPage extends StatefulWidget {
  const NseFutureSymbolPage({super.key, required this.params});
  final SymbolScreenParams params;
  static const String routeName = '/nse-future-symbol-page';

  @override
  State<NseFutureSymbolPage> createState() => _NseFutureSymbolPageState();
}

class _NseFutureSymbolPageState extends State<NseFutureSymbolPage> {
  late final NFOSymbolWebSocket _socketService;
  GetStockRecordEntity _stockRecord = GetStockRecordEntity();
  String? errorMessage;

  final ValueNotifier<int> lotsNotifierMrk = ValueNotifier<int>(1);
  final ValueNotifier<int> lotsNotifierLmt = ValueNotifier<int>(1);
  final TextEditingController _lotsMktController = TextEditingController(
    text: '1',
  );
  final TextEditingController _lotsOdrController = TextEditingController(
    text: '1',
  );

  bool isMarketOpen = true;
  final TextEditingController _usernameController = TextEditingController(
    text: '0',
  );
  int lots = 1; // Variable to track the lot count
  int selecteddTab = 0;
  late Timer _timer;
  bool isBuyClicked = false;
  bool isSellClicked = false;
  var ohlcNFO;
  var recordNFO;

  final client = http.Client();
  final url = Uri.parse(superTradeBaseApiEndPointUrl);

  NFO nfo = NFO();

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
              'dataRelatedTo': 'NFO',
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
              _stockRecord = data;
              recordNFO = data.response.first;
              ohlcNFO = data.response.first.ohlc;
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
      if (!mounted) return;
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
          'stockPrice': stockPrice,
          "deviceID": deviceID.toString(),
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
                  jsonResponse['stateus'] == 1
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
                    style: const TextStyle(fontSize: 16),
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
                      style: TextStyle(color: Colors.black, fontSize: 20),
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
  }

  Future<void> saleStock({
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
        if (!mounted) return;
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
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
  }

  dynamic uBalance;
  initUser() async {
    DatabaseService databaseService = DatabaseService();
    final userBalance = await databaseService.getUserData(key: userBalanceKey);
    if (!mounted) return;
    setState(() {
      uBalance = userBalance;
    });
  }

  // void _checkMarketStatus() {
  //   final now = DateTime.now();
  //   final marketOpenTime = DateTime(now.year, now.month, now.day, 9, 15);
  //   final marketCloseTime = DateTime(now.year, now.month, now.day, 15, 30);

  //   // Make sure the system is not on Saturday or Sunday
  //   final isWeekday =
  //       now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;

  //   final newMarketStatus = isWeekday &&
  //       now.isAfter(marketOpenTime) &&
  //       now.isBefore(marketCloseTime);

  //   if (isMarketOpen != newMarketStatus) {
  //     if (!mounted) return;
  //     setState(() {
  //       isMarketOpen = newMarketStatus;
  //     });
  //   }

  //   print('Now: $now');
  //   print('Market Open Time: $marketOpenTime');
  //   print('Market Close Time: $marketCloseTime');
  //   print('Market Status: $isMarketOpen');
  // }

  @override
  void initState() {
    // First, ensure any previous socket is fully cleaned up

    _socketService = NFOSymbolWebSocket(
      symbolKey: widget.params.symbolKey,
      onDataReceived: (data) {
        if (mounted) {
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
            _stockRecord = data;
            recordNFO = data.response.first;
            ohlcNFO = data.response.first.ohlc;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            errorMessage = error;
          });
        }
      },
      onConnected: () {
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
        }
      },
      onDisconnected: () {
        if (mounted) {
          setState(() {
            errorMessage = "Connection lost. Attempting to reconnect...";
          });
        }
      },
    );
    _socketService.connect();
    _fetchInitialDataViaHttp(); // Fetch data immediately via HTTP while WebSocket connects
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      initUser();
      AuthService().checkUserValidation();
      // _checkMarketStatus();
    });

    lotsNotifierMrk.addListener(() {
      if (lotsNotifierMrk.value > 0) {
        _lotsMktController.text = lotsNotifierMrk.value.toString();
      }
    });

    lotsNotifierLmt.addListener(() {
      if (lotsNotifierLmt.value > 0) {
        _lotsOdrController.text = lotsNotifierLmt.value.toString();
      }
    });

    initUser();
    // _checkMarketStatus();
    AuthService().checkUserValidation();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    lotsNotifierMrk.dispose();
    lotsNotifierLmt.dispose();
    _lotsMktController.dispose();
    _lotsOdrController.dispose();
    _usernameController.dispose();
    try {
      _socketService.disconnect();
    } catch (_) {}
    super.dispose();
  }

  String _formatNumber(dynamic number) {
    if (number == null) return 'N/A';
    return NumberFormat('#,##,##0.00').format(number);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: zBlack,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            context.pop(context);
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
      body: Builder(
        builder: (context) {
          if (_stockRecord.status != 1) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _stockRecord.message.toString(),
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (_stockRecord.response.isEmpty && errorMessage == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to server...'),
                ],
              ),
            );
          }

          final record = _stockRecord.response.first;
          final ohlc = record.ohlc;

          return Column(
            children: [
              SizedBox(height: screenHeight * 0.01),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          onTap: () => setState(() => selecteddTab = 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.018,
                            ),
                            decoration: BoxDecoration(
                              // color: selecteddTab == 16
                              //     ? Colors.green
                              //     : Colors.transparent,
                              gradient: selecteddTab == 0
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [marketColor, marketColor],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: selecteddTab == 0
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
                                  color: selecteddTab == 0
                                      ? Colors.white
                                      : zBlack,
                                  size: 20,
                                ),
                                SizedBox(width: 8.h),
                                Text(
                                  "MARKET",
                                  style: TextStyle(
                                    color: selecteddTab == 0
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    // fontFamily: 'JetBrainsMono',
                                    letterSpacing: 2,
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
                          onTap: () => setState(() => selecteddTab = 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.018,
                            ),
                            decoration: BoxDecoration(
                              color: selecteddTab == 1
                                  ? const Color(0xFF2C2C2E)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              gradient: selecteddTab == 1
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [orderColor, orderColor],
                                    )
                                  : null,
                              boxShadow: selecteddTab == 1
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
                                  color: selecteddTab == 1
                                      ? Colors.white
                                      : zBlack,
                                  size: 20,
                                ),
                                SizedBox(width: 8.h),
                                Text(
                                  "ORDER",
                                  style: TextStyle(
                                    color: selecteddTab == 1
                                        ? Colors.white
                                        : zBlack,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    fontFamily: 'JetBrainsMono',
                                    letterSpacing: 2,
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
              Expanded(
                child: selecteddTab == 0
                    ? Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(height: screenHeight * 0.02),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: marketColor,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("UNIT").textStyleH11(),
                                    ValueListenableBuilder<int>(
                                      valueListenable: lotsNotifierMrk,
                                      builder: (context, lots, child) {
                                        return Row(
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => lots > 1
                                                    ? lotsNotifierMrk.value--
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: kWhiteColor,
                                                    size: screenWidth * 0.05,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth * 0.20,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _lotsMktController,
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.045,
                                                  color: kWhiteColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 12,
                                                          ),
                                                      border: InputBorder.none,
                                                      isDense: true,
                                                    ),
                                                onChanged: (value) {
                                                  if (value.isNotEmpty) {
                                                    final newLots =
                                                        int.tryParse(value) ??
                                                        1;
                                                    if (newLots > 0) {
                                                      lotsNotifierMrk.value =
                                                          newLots;
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                            // Container(
                                            //   width: screenWidth * 0.15,
                                            //   margin:
                                            //       const EdgeInsets.symmetric(
                                            //           horizontal: 16),
                                            //   padding:
                                            //       const EdgeInsets.symmetric(
                                            //           vertical: 8,
                                            //           horizontal: 12),
                                            //   decoration: BoxDecoration(
                                            //     borderRadius:
                                            //         BorderRadius.circular(12),
                                            //     color: Colors.grey
                                            //         .withOpacity(0.2),
                                            //   ),
                                            //   child: Text(
                                            //     "$lots",
                                            //     style: TextStyle(
                                            //       fontSize: screenWidth * 0.045,
                                            //       color: zBlack,
                                            //       fontWeight: FontWeight.bold,
                                            //     ),
                                            //     textAlign: TextAlign.center,
                                            //   ),
                                            // ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () =>
                                                    lotsNotifierMrk.value++,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: kWhiteColor,
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
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            color: Color(0xffd00000),
                                            // gradient: const LinearGradient(
                                            //   begin: Alignment.topLeft,
                                            //   end: Alignment.bottomRight,
                                            //   colors: [
                                            //     Color(0xFFFF3B30),
                                            //     Color(0xFFFF3B30),
                                            //   ],
                                            // ),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: const Color(0xFFFF3B30)
                                            //         .withOpacity(0.3),
                                            //     spreadRadius: 1,
                                            //     blurRadius: 8,
                                            //     offset: const Offset(0, 4),
                                            //   ),
                                            // ],
                                            border: Border.all(
                                              color: Colors.red.withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              onTap: () {
                                                saleStock(
                                                  activity: 'sale-stock',
                                                  context: context,
                                                  symbolKey:
                                                      widget.params.symbolKey,
                                                  categoryName: 'NFO',
                                                  stockPrice:
                                                      '${ohlc.salePrice} * ${lotsNotifierMrk.value}',
                                                  stockQty: lotsNotifierMrk
                                                      .value
                                                      .toString(),
                                                );
                                                // if (isMarketOpen) {

                                                // } else {
                                                //   showDialog(
                                                //     context: context,
                                                //     builder: (context) =>
                                                //         const WarningAlertBox(
                                                //       title: 'Warning',
                                                //       message:
                                                //           'Market Closed You Cant Sale Stocks!',
                                                //     ),
                                                //   );
                                                // }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: screenHeight * 0.02,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.sell,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        const Text(
                                                          "SELL",
                                                        ).textStyleH1W(),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "₹${formatDoubleNumber(record.ohlc.salePrice)}",
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            color: Color(0xff208b3a),
                                            // gradient: const LinearGradient(
                                            //   begin: Alignment.topLeft,
                                            //   end: Alignment.bottomRight,
                                            //   colors: [
                                            //     Colors.green,
                                            //     Colors.green,
                                            //   ],
                                            // ),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: const Color(0xFF34C759)
                                            //         .withOpacity(0.3),
                                            //     spreadRadius: 1,
                                            //     blurRadius: 8,
                                            //     offset: const Offset(0, 4),
                                            //   ),
                                            // ],
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              onTap: () {
                                                buyStock(
                                                  context: context,
                                                  activity: 'buy-stock',
                                                  symbolKey:
                                                      widget.params.symbolKey,
                                                  categoryName: 'NFO',
                                                  stockPrice:
                                                      '${ohlc.buyPrice} * ${lotsNotifierMrk.value}',
                                                  stockQty: lotsNotifierMrk
                                                      .value
                                                      .toString(),
                                                );
                                                // if (isMarketOpen) {

                                                // } else {
                                                //   showDialog(
                                                //     context: context,
                                                //     builder: (context) =>
                                                //         const WarningAlertBox(
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.shopping_cart,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        const Text(
                                                          "BUY",
                                                        ).textStyleH1W(),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "₹${formatDoubleNumber(record.ohlc.buyPrice)}",
                                                    ).textStyleH1W(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.03),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 10.w,
                                  bottom: 10.w,
                                ),
                                // padding: EdgeInsets.all(10.r),
                                // width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  color: Colors.white,
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black.withOpacity(0.1),
                                  //     blurRadius: 10,
                                  //     offset: const Offset(0, 5),
                                  //   ),
                                  // ],
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 60,
                                            margin: EdgeInsets.only(right: 4.w),
                                            width: screenWidth * 0.20,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white.blink(
                                                baseValue: ohlc.lastPrice,
                                                compValue: ohlc.salePrice,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Sell Price',
                                                  style: TextStyle(
                                                    color: zBlack,
                                                    fontSize:
                                                        screenWidth * 0.03,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  ohlc.salePrice.toString(),
                                                  style: TextStyle(
                                                    color: zBlack,
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'JetBrainsMono',
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // _buildInfoBox(
                                          //     "Bid\n${ohlc.lastPrice}",
                                          //     screenWidth,
                                          //     screenHeight),
                                          Container(
                                            height: 60,
                                            // margin: EdgeInsets.only(right: 4.w),
                                            width: screenWidth * 0.20,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white.blink(
                                                baseValue: ohlc.lastPrice,
                                                compValue: ohlc.buyPrice,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Buy Price',
                                                  style: TextStyle(
                                                    color: zBlack,
                                                    fontSize:
                                                        screenWidth * 0.03,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  ohlc.buyPrice.toString(),
                                                  style: TextStyle(
                                                    color: zBlack,
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'JetBrainsMono',
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // _buildInfoBox(
                                          //     "Ask\n${ohlc.buyPrice}",
                                          //     screenWidth,
                                          //     screenHeight),
                                          _buildInfoBox(
                                            "Last\n${ohlc.lastPrice}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoBox(
                                            "Open\n${ohlc.open}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Close\n${ohlc.close}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Atp\n${record.averageTradePrice}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoBox(
                                            "High\n${ohlc.high}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Low\n${ohlc.low}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Volume\n${ohlc.volume}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoBox(
                                            "Upper ckt\n${record.upperCKT}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Lower ckt\n${record.lowerCKT}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          Container(
                                            height: screenHeight * 0.08,
                                            width: screenWidth * 0.20,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Change',
                                                  style: TextStyle(
                                                    color:
                                                        record.change
                                                            .toString()
                                                            .contains('-')
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  record.change.toString(),
                                                  style: TextStyle(
                                                    color:
                                                        record.change
                                                            .toString()
                                                            .contains('-')
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'JetBrainsMono',
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // _buildInfoBox(
                                          //     "Change\n${record.change}",
                                          //     screenWidth,
                                          //     screenHeight),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoBox(
                                            "Last Buy\n${record.lastBuy.price}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Last Sell\n${record.lastSell.price}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "LotSize\n${record.lotSize}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // _buildInfoBox("Buyer\nN/A",
                                          //     screenWidth, screenHeight),
                                          // _buildInfoBox("Seller\nN/A",
                                          //     screenWidth, screenHeight),
                                          _buildInfoBox(
                                            "Open Interest\n${record.openInterest}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    //! LIMIT
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(height: screenHeight * 0.02),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: orderColor,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("UNIT").textStyleH11(),
                                    ValueListenableBuilder<int>(
                                      valueListenable: lotsNotifierLmt,
                                      builder: (context, lots, child) {
                                        return Row(
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => lots > 1
                                                    ? lotsNotifierLmt.value--
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: kWhiteColor,
                                                    size: screenWidth * 0.05,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth * 0.20,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _lotsOdrController,
                                                textAlign: TextAlign.center,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.045,
                                                  color: kWhiteColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 12,
                                                          ),
                                                      border: InputBorder.none,
                                                      isDense: true,
                                                    ),
                                                onChanged: (value) {
                                                  if (value.isNotEmpty) {
                                                    final newLots =
                                                        int.tryParse(value) ??
                                                        1;
                                                    if (newLots > 0) {
                                                      lotsNotifierLmt.value =
                                                          newLots;
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                            // Container(
                                            //   width: screenWidth * 0.15,
                                            //   margin:
                                            //       const EdgeInsets.symmetric(
                                            //           horizontal: 16),
                                            //   padding:
                                            //       const EdgeInsets.symmetric(
                                            //           vertical: 8,
                                            //           horizontal: 12),
                                            //   decoration: BoxDecoration(
                                            //     borderRadius:
                                            //         BorderRadius.circular(12),
                                            //     color: Colors.grey
                                            //         .withOpacity(0.2),
                                            //   ),
                                            //   child: Text(
                                            //     "$lots",
                                            //     style: TextStyle(
                                            //       fontSize: screenWidth * 0.045,
                                            //       color: zBlack,
                                            //       fontWeight: FontWeight.bold,
                                            //     ),
                                            //     textAlign: TextAlign.center,
                                            //   ),
                                            // ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () =>
                                                    lotsNotifierLmt.value++,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: kWhiteColor,
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
                              // Divider(
                              //   indent: 3,
                              //   endIndent: 3,
                              //   height: screenHeight * 0.03,
                              //   color: Colors.white,
                              // ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: kWhiteColor,
                                ),
                                child: TextFormField(
                                  controller: _usernameController,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 18,
                                    color: zBlack,
                                    letterSpacing: 2,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    // labelText: "Price",
                                    // labelStyle: TextStyle(
                                    //   color: Colors.grey[400],
                                    //   fontSize: screenWidth * 0.04,
                                    //   fontWeight: FontWeight.w500,
                                    // ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10.0,
                                        left: 16,
                                      ),
                                      child: Text(
                                        'Price :  ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 18,
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
                                    fillColor: kWhiteColor,
                                  ),
                                  keyboardType: TextInputType.number,
                                  cursorColor: const Color(0xFF00C853),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  isSellClicked
                                      ? const CircularProgressIndicator.adaptive()
                                      : Container(
                                          width: screenWidth / 2.5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            color: Color(0xffd00000),
                                            // gradient: LinearGradient(
                                            //   begin: Alignment.topLeft,
                                            //   end: Alignment.bottomRight,
                                            //   colors: [
                                            //     const Color(
                                            //       0xFFFF3B30,
                                            //     ).withOpacity(0.8),
                                            //     const Color(
                                            //       0xFFFF3B30,
                                            //     ).withOpacity(0.6),
                                            //   ],
                                            // ),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: const Color(0xFFFF3B30)
                                            //         .withOpacity(0.3),
                                            //     spreadRadius: 1,
                                            //     blurRadius: 8,
                                            //     offset: const Offset(0, 4),
                                            //   ),
                                            // ],
                                            border: Border.all(
                                              color: Colors.red.withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              onTap: () {
                                                if (double.parse(
                                                          _usernameController
                                                              .text,
                                                        ) >
                                                        double.parse(
                                                          ohlc.salePrice
                                                              .toString(),
                                                        ) ||
                                                    double.parse(
                                                          _usernameController
                                                              .text,
                                                        ) <
                                                        double.parse(
                                                          ohlc.buyPrice
                                                              .toString(),
                                                        )) {
                                                  saleStock(
                                                    context: context,
                                                    activity:
                                                        'sale-stock-order',
                                                    symbolKey:
                                                        widget.params.symbolKey,
                                                    categoryName: 'NFO',
                                                    stockPrice:
                                                        '${_usernameController.text} * ${lotsNotifierLmt.value}',
                                                    stockQty: lotsNotifierLmt
                                                        .value
                                                        .toString(),
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
                                                //     builder: (context) =>
                                                //         const WarningAlertBox(
                                                //       title: 'Warning',
                                                //       message:
                                                //           'Market Closed You Cant Sale Stocks!',
                                                //     ),
                                                //   );
                                                // }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: screenHeight * 0.02,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.sell,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          "SELL",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                screenWidth *
                                                                0.04,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'JetBrainsMono',
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      (() {
                                                        final double price =
                                                            double.tryParse(
                                                              _usernameController
                                                                  .text,
                                                            ) ??
                                                            0.0;
                                                        // final int lots =
                                                        //     lotsNotifierLmt
                                                        //         .value;
                                                        // final double total =
                                                        //     price * lots;
                                                        return price
                                                            .toStringAsFixed(2);
                                                      })(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            screenWidth * 0.045,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'JetBrainsMono',
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  SizedBox(width: screenWidth * 0.03),
                                  isBuyClicked
                                      ? const CircularProgressIndicator.adaptive()
                                      : Container(
                                          width: screenWidth / 2.5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            color: Color(0xff208b3a),
                                            // gradient: LinearGradient(
                                            //   begin: Alignment.topLeft,
                                            //   end: Alignment.bottomRight,
                                            //   colors: [
                                            //     const Color(
                                            //       0xFF34C759,
                                            //     ).withOpacity(0.8),
                                            //     const Color(
                                            //       0xFF34C759,
                                            //     ).withOpacity(0.6),
                                            //   ],
                                            // ),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: const Color(0xFF34C759)
                                            //         .withOpacity(0.3),
                                            //     spreadRadius: 1,
                                            //     blurRadius: 8,
                                            //     offset: const Offset(0, 4),
                                            //   ),
                                            // ],
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              onTap: () {
                                                if (double.parse(
                                                          _usernameController
                                                              .text,
                                                        ) >
                                                        double.parse(
                                                          ohlc.salePrice
                                                              .toString(),
                                                        ) ||
                                                    double.parse(
                                                          _usernameController
                                                              .text,
                                                        ) <
                                                        double.parse(
                                                          ohlc.buyPrice
                                                              .toString(),
                                                        )) {
                                                  buyStock(
                                                    context: context,
                                                    activity: 'buy-stock-order',
                                                    symbolKey:
                                                        widget.params.symbolKey,
                                                    categoryName: 'NFO',
                                                    stockPrice:
                                                        '${_usernameController.text} * ${lotsNotifierLmt.value}',
                                                    stockQty: lotsNotifierLmt
                                                        .value
                                                        .toString(),
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
                                                //     builder: (context) =>
                                                //         const WarningAlertBox(
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.shopping_cart,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          "BUY",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                screenWidth *
                                                                0.04,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'JetBrainsMono',
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      (() {
                                                        final double price =
                                                            double.tryParse(
                                                              _usernameController
                                                                  .text,
                                                            ) ??
                                                            0.0;
                                                        // final int lots =
                                                        //     lotsNotifierLmt
                                                        //         .value;
                                                        // final double total =
                                                        //     price * lots;
                                                        return price
                                                            .toStringAsFixed(2);
                                                      })(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            screenWidth * 0.045,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'JetBrainsMono',
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.03),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 10.w,
                                  bottom: 10.w,
                                ),
                                // padding: EdgeInsets.all(10.r),
                                // width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  color: Colors.white,
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 60,
                                            margin: EdgeInsets.only(right: 4.w),
                                            width: screenWidth * 0.25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white.blink(
                                                baseValue: ohlc.lastPrice,
                                                compValue: ohlc.salePrice,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Sell Price',
                                                  style: TextStyle(
                                                    color: zBlack,
                                                    fontSize:
                                                        screenWidth * 0.03,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  ohlc.salePrice.toString(),
                                                  style: TextStyle(
                                                    color: zBlack,
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'JetBrainsMono',
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // _buildInfoBox(
                                          //     "Bid\n${ohlc.lastPrice}",
                                          //     screenWidth,
                                          //     screenHeight),
                                          Container(
                                            height: 60,
                                            // margin: EdgeInsets.only(right: 4.w),
                                            width: screenWidth * 0.25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white.blink(
                                                baseValue: ohlc.lastPrice,
                                                compValue: ohlc.buyPrice,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Buy Price',
                                                  style: TextStyle(
                                                    color: zBlack,
                                                    fontSize:
                                                        screenWidth * 0.03,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  ohlc.buyPrice.toString(),
                                                  style: TextStyle(
                                                    color: zBlack,
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'JetBrainsMono',
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // _buildInfoBox(
                                          //     "Bid\n${ohlc.lastPrice}",
                                          //     screenWidth,
                                          //     screenHeight),
                                          // _buildInfoBox(
                                          //     "Ask\n${ohlc.lastPrice}",
                                          //     screenWidth,
                                          //     screenHeight),
                                          _buildInfoBox(
                                            "Last\n${ohlc.lastPrice}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoBox(
                                            "Open\n${ohlc.open}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Close\n${ohlc.close}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Atp\n${record.averageTradePrice}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoBox(
                                            "High\n${ohlc.high}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Low\n${ohlc.low}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Volume\n${ohlc.volume}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoBox(
                                            "Upper ckt\n${ohlc.open}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Lower ckt\n${ohlc.close}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          Container(
                                            height: screenHeight * 0.08,
                                            width: screenWidth * 0.20,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Change',
                                                  style: TextStyle(
                                                    color:
                                                        record.change
                                                            .toString()
                                                            .contains('-')
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  record.change.toString(),
                                                  style: TextStyle(
                                                    color:
                                                        record.change
                                                            .toString()
                                                            .contains('-')
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'JetBrainsMono',
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // _buildInfoBox(
                                          //     "Change\n${record.change}",
                                          //     screenWidth,
                                          //     screenHeight),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoBox(
                                            "Last Buy\n${record.lastBuy.price}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "Last Sell\n${record.lastSell.price}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                          _buildInfoBox(
                                            "LotSize\n${record.lotSize}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // _buildInfoBox("Buyer\nN/A",
                                          //     screenWidth, screenHeight),
                                          // _buildInfoBox("Seller\nN/A",
                                          //     screenWidth, screenHeight),
                                          _buildInfoBox(
                                            "Open Interest\n${record.openInterest}",
                                            screenWidth,
                                            screenHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoBox(String text, double screenWidth, double screenHeight) {
    final List<String> parts = text.split('\n');
    final String label = parts[0];
    final String value = parts.length > 1 ? parts[1] : '';

    return Container(
      height: screenHeight * 0.08,
      width: screenWidth * 0.20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label).textStyleH2(),
          SizedBox(height: 4.h),
          Text(value).textStyleH1(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
