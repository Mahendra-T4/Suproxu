import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol.dart';
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';
import 'package:suproxu/features/navbar/home/repository/buy_sale_repo.dart';
import 'package:suproxu/features/navbar/home/model/close_stock_param.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/features/navbar/Portfolio/bloc/portfolio_bloc.dart';
import 'package:suproxu/features/navbar/Portfolio/provider/active_port_provider.dart';
import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';
import 'package:suproxu/features/navbar/home/repository/trade_repository.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';

import '../home/model/symbol_page_param.dart';

class PortfolioActiveTab extends ConsumerStatefulWidget {
  const PortfolioActiveTab({super.key});

  @override
  ConsumerState<PortfolioActiveTab> createState() => _PortfolioActiveTabState();
}

class _PortfolioActiveTabState extends ConsumerState<PortfolioActiveTab>
    with SingleTickerProviderStateMixin {
  late PortfolioBloc _portfolioBloc;
  late ProfileBloc _profileBloc;
  late AnimationController _animationController;
  final Set<int> loadingIndices = {};
  final Set<int> lockedIndices = {}; // Track locked items

  late Animation<double> _fadeAnimation;
  // BalanceEntity balance = BalanceEntity();

  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _portfolioBloc = PortfolioBloc();
    _portfolioBloc.add(ActivePortfolioDataFetchingEvent());
    _profileBloc = ProfileBloc();
    _profileBloc.add(LoadUserWalletDataEvent());

    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        initUser();
      } else {
        timer.cancel();
      }
    });

    initUser();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    // _fetchData(); // Initial fetch
  }

  var getStockData;

  @override
  void dispose() {
    // _portfolioBloc.close();
    if (_timer.isActive) {
      _timer.cancel();
    }
    _animationController.dispose();
    super.dispose();
  }

  Color contColor(dynamic open, dynamic last) {
    final value = (open ?? 0) - (last ?? 0);
    return value >= 0 ? Colors.green : Colors.red;
  }

  GetStockRecordEntity getStockRecordEntity = GetStockRecordEntity();

  Future<GetStockRecordEntity> getStockRecords(
    String symbolKey,
    String categoryName,
  ) async {
    final client = http.Client();
    final url = Uri.parse(superTradeBaseApiEndPointUrl);
    DatabaseService databaseService = DatabaseService();
    final uKey = await databaseService.getUserData(key: userIDKey);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final deviceID = androidInfo.id.toString();
    try {
      final response = await client.post(
        url,
        body: {
          'activity': "get-stock-record",
          'userKey': uKey.toString(),
          'symbolKey': symbolKey.toString(),
          "deviceID": deviceID.toString(),
          'dataRelatedTo': categoryName,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log('SymbolKey =>>$symbolKey');
        getStockRecordEntity = GetStockRecordEntity.fromJson(jsonResponse);
        log('MCX Symbol Response =>> ${response.body}');
        log('Get Stock Record message => ${getStockRecordEntity.message}');
      } else {
        log('failed to load $categoryName data from server');
      }
    } catch (e) {
      log('Get Stock Record Error =>> $e');
    }
    return getStockRecordEntity;
  }

  double? parsedUBalance;
  dynamic canBuy;
  final client = http.Client();
  final url = Uri.parse(superTradeBaseApiEndPointUrl);
  dynamic profitLoss;

  bool isLoading = true;

  dynamic uBalance;
  initUser() async {
    DatabaseService databaseService = DatabaseService();
    final userBalance = await databaseService.getUserData(key: userBalanceKey);
    if (mounted) {
      setState(() {
        uBalance = userBalance;
      });
    } else {
      uBalance = userBalance;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProvider = ref.watch(activePortfolioProvider);
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 8.h),
              activeProvider.when(
                skipLoadingOnRefresh: true,
                data: (data) {
                  // Calculate total profit and loss for all records
                  final profitandLoss =
                      data.response?.fold<double>(
                        0.0,
                        (sum, element) =>
                            sum + (element.liveData?.profitLoss ?? 0.0),
                      ) ??
                      0.0;
                  final m2m = data.activeStatics?.m2m ?? 0.0;
                  final availebleMargin =
                      data.activeStatics?.marginAvailable ?? 0.0;
                  return Column(
                    children: [
                      SizedBox(
                        // height: 100,
                        child: Center(
                          child: _userWallet(
                            profitandLoss,
                            data.status!,
                            m2m,
                            availebleMargin,
                            data.activeStatics?.requiredHoldingMargin ?? 0.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      data.status == 1
                          ? SizedBox(
                              height: 485,
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(bottom: 70),
                                itemCount: data.response!.length,
                                itemBuilder: (context, index) {
                                  return AbsorbPointer(
                                    absorbing: lockedIndices.contains(index),
                                    child: Opacity(
                                      opacity: lockedIndices.contains(index)
                                          ? 0.6
                                          : 1.0,
                                      child: InkWell(
                                        onTap: () {
                                          if (lockedIndices.contains(index))
                                            return;
                                          if (data
                                                  .response![index]
                                                  .dataRelatedTo ==
                                              'MCX') {
                                            GoRouter.of(context).pushNamed(
                                              MCXSymbolRecordPage.routeName,
                                              extra: SymbolScreenParams(
                                                symbol: data
                                                    .response![index]
                                                    .symbolName
                                                    .toString(),
                                                index: index,
                                                symbolKey: data
                                                    .response![index]
                                                    .symbolKey
                                                    .toString(),
                                              ),
                                            );
                                          } else if (data
                                                  .response![index]
                                                  .dataRelatedTo ==
                                              'NFO') {
                                            GoRouter.of(context).pushNamed(
                                              NseFutureSymbolPage.routeName,
                                              extra: SymbolScreenParams(
                                                symbol: data
                                                    .response![index]
                                                    .symbolKey
                                                    .toString(),
                                                index: index,
                                                symbolKey: data
                                                    .response![index]
                                                    .symbolKey
                                                    .toString(),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                          ),
                                          alignment: Alignment.center,
                                          child: Column(
                                            spacing: 4,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            MediaQuery.sizeOf(
                                                              context,
                                                            ).width /
                                                            2,
                                                        child: Text(
                                                          data
                                                              .response![index]
                                                              .symbolName
                                                              .toString(),
                                                        ).textStyleH1(),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    (() {
                                                      if (data
                                                              .response![index]
                                                              .tradeMethod !=
                                                          1) {
                                                        return 'Sold ${data.response![index].stockQty.toString()} X ${data.response![index].tradePrice}';
                                                      } else {
                                                        return 'Bought ${data.response![index].stockQty.toString()} X ${data.response![index].tradePrice}';
                                                      }
                                                    })(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: FontFamily
                                                          .globalFontFamily,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      // fontFamily:
                                                      // 'JetBrainsMono',
                                                      color:
                                                          data
                                                                  .response![index]
                                                                  .tradeMethod !=
                                                              1
                                                          ? Colors.red
                                                          : Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const SizedBox.shrink(),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Profit & Loss: ',
                                                      ).textStyleH3(),
                                                      Text(
                                                        data
                                                            .response![index]
                                                            .liveData!
                                                            .profitLoss
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontFamily: FontFamily
                                                              .globalFontFamily,
                                                          color:
                                                              data
                                                                  .response![index]
                                                                  .liveData!
                                                                  .profitLoss
                                                                  .toString()
                                                                  .contains('-')
                                                              ? Colors.red
                                                              : Colors.green,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          // fontFamily:
                                                          //     'JetBrainsMono',
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Margin: ${data.response![index].margin.toString()}',
                                                  ).textStyleH3(),
                                                  Text(
                                                    'CMP ${data.response![index].liveData?.currentMarketPrice.toString()}',
                                                  ).textStyleH3(),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Holding Margin: ${data.response![index].marginHolding.toString()}',
                                                  ).textStyleH3(),
                                                  Text(
                                                    'M2M: ${data.response![index].liveData!.tradeM2M.toString()}',
                                                  ).textStyleH3(),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  loadingIndices.contains(index)
                                                      ? Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: 25,
                                                          width: 120,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 7,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12.r,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Processing...',
                                                            style: TextStyle(
                                                              fontFamily: FontFamily
                                                                  .globalFontFamily,
                                                            ),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.r,
                                                              ),
                                                          onTap: () async {
                                                            // Don't proceed if already locked
                                                            if (lockedIndices
                                                                .contains(
                                                                  index,
                                                                )) {
                                                              return;
                                                            }

                                                            setState(() {
                                                              loadingIndices
                                                                  .add(index);
                                                              lockedIndices.add(
                                                                index,
                                                              ); // Lock the item
                                                            });

                                                            try {
                                                              final getData = await TradeRepository.getStockRecords(
                                                                data
                                                                    .response![index]
                                                                    .symbolKey
                                                                    .toString(),
                                                                data
                                                                    .response![index]
                                                                    .dataRelatedTo
                                                                    .toString(),
                                                              );

                                                              if (getData
                                                                  .response
                                                                  .isEmpty) {
                                                                setState(() {
                                                                  loadingIndices
                                                                      .remove(
                                                                        index,
                                                                      );
                                                                  // lockedIndices
                                                                  //     .remove(index); // Unlock on error
                                                                });
                                                                failedToast(
                                                                  context,
                                                                  'No stock records available',
                                                                );
                                                                return;
                                                              }

                                                              final param = CloseStockParam(
                                                                symbolKey: data
                                                                    .response![index]
                                                                    .symbolKey
                                                                    .toString(),
                                                                categoryName: data
                                                                    .response![index]
                                                                    .dataRelatedTo
                                                                    .toString(),
                                                                stockPrice:
                                                                    data.response![index].tradeMethod ==
                                                                        1
                                                                    ? getData
                                                                          .response[0]
                                                                          .ohlc
                                                                          .salePrice
                                                                          .toString()
                                                                    : getData
                                                                          .response[0]
                                                                          .ohlc
                                                                          .buyPrice
                                                                          .toString(),
                                                                stockQty: data
                                                                    .response![index]
                                                                    .stockQty
                                                                    .toString(),
                                                                context:
                                                                    context,
                                                              );

                                                              final result = await ref.read(
                                                                data.response![index].tradeMethod ==
                                                                        1
                                                                    ? saleStockProvider(
                                                                        param,
                                                                      ).future
                                                                    : buyStockProvider(
                                                                        param,
                                                                      ).future,
                                                              );

                                                              if (result
                                                                      .status ==
                                                                  1) {
                                                                if (mounted) {
                                                                  // First trigger the portfolio update
                                                                  _portfolioBloc
                                                                      .add(
                                                                        ActivePortfolioDataFetchingEvent(),
                                                                      );

                                                                  // Remove loading and locked states
                                                                  setState(() {
                                                                    loadingIndices
                                                                        .remove(
                                                                          index,
                                                                        );
                                                                    lockedIndices
                                                                        .remove(
                                                                          index,
                                                                        ); // Unlock immediately on success
                                                                  });

                                                                  // Wait a moment to ensure delete is processed
                                                                  await Future.delayed(
                                                                    const Duration(
                                                                      milliseconds:
                                                                          500,
                                                                    ),
                                                                  );

                                                                  // Then remove the item if still mounted
                                                                  if (mounted) {
                                                                    setState(() {
                                                                      data.response!
                                                                          .removeAt(
                                                                            index,
                                                                          );
                                                                    });
                                                                  }
                                                                }
                                                                failedToast(
                                                                  context,
                                                                  result.message
                                                                      .toString(),
                                                                );
                                                              } else {
                                                                setState(() {
                                                                  loadingIndices
                                                                      .remove(
                                                                        index,
                                                                      );
                                                                  lockedIndices
                                                                      .remove(
                                                                        index,
                                                                      ); // Unlock on failure too
                                                                });
                                                              }
                                                            } catch (e) {
                                                              log(
                                                                'Error closing trade: $e',
                                                              );
                                                              setState(() {
                                                                loadingIndices
                                                                    .remove(
                                                                      index,
                                                                    );
                                                                lockedIndices
                                                                    .remove(
                                                                      index,
                                                                    ); // Always unlock on error
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 25,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 7,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12.r,
                                                                      ),
                                                                ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.close,
                                                                  size: 16.r,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 10.w,
                                                                ),
                                                                const Text(
                                                                  'CLOSE TRADE',
                                                                ).textStyleH2W(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                              const Divider(
                                                color: zBlack,
                                                thickness: 1.5,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height / 4.5,
                                ),
                                Center(
                                  child: Text(
                                    data.message.toString(),
                                    style: TextStyle(
                                      color: zBlack,
                                      fontSize: 15,
                                      fontFamily: FontFamily.globalFontFamily,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  );
                },
                error: (error, stackTrace) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Center(child: Text(error.toString()))],
                ),
                loading: () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height / 3.5),
                    const Center(child: CircularProgressIndicator.adaptive()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userWallet(
    double profitLoss,
    int status,
    dynamic m2m,
    dynamic availableMargin,
    dynamic requiredHoldingMargin,
  ) => BlocConsumer(
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
          return const Center(child: CircularProgressIndicator.adaptive());
        case const (LoadUserWalletDataSuccessStatus):
          final wallet =
              (state as LoadUserWalletDataSuccessStatus).balanceEntity;

          return wallet.status == 1
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  padding: EdgeInsets.all(10.r),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Colors.grey[200]!.withOpacity(0.7),
                    border: Border.all(color: Colors.black, width: 1),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 22,
                              horizontal: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildWalletInfoColumn(
                                      'Ledger Balance',
                                      wallet.record!.first.availableBalance
                                          .toString(),
                                      textColor: Colors.black87,
                                    ),
                                    Container(
                                      height: 40.h,
                                      width: 1.w,
                                      color: Colors.black,
                                    ),
                                    _buildWalletInfoColumn(
                                      'Available Margin',
                                      status == 1
                                          ? availableMargin
                                                .toStringAsFixed(2)
                                                .toString()
                                          : wallet
                                                .record!
                                                .first
                                                .availableBalance,
                                      textColor: Colors.black87,
                                    ),
                                  ],
                                ),
                                Divider(height: 30.h, color: Colors.black),
                                // SizedBox(height: 16.h),
                                // Divider(
                                //     height: 1, color: Colors.grey.withOpacity(0.2)),
                                // SizedBox(height: 16.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildWalletInfoColumnPL(
                                      'Active P&L',
                                      profitLoss.toStringAsFixed(2).toString(),
                                      textColor: profitLoss >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 30),
                                      height: 40.h,
                                      width: 1.w,
                                      color: Colors.black,
                                    ),
                                    _buildWalletInfoColumn(
                                      'M 2 M                   ',
                                      status == 1
                                          ? m2m.toStringAsFixed(2).toString()
                                          : wallet
                                                .record!
                                                .first
                                                .availableBalance,
                                      textColor: Colors.black87,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: aquaGreyColor.withOpacity(.4),
                        ),
                        child: Row(
                          // spacing: 10,
                          children: [
                            Text(
                              'Required Holding Margin : ',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                fontFamily: FontFamily.globalFontFamily,
                              ),
                            ),
                            Text(
                              requiredHoldingMargin.toString(),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                fontFamily: FontFamily.globalFontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    wallet.message.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
        case const (LoadUserWalletDataFailedStatus):
          return const SizedBox.shrink();
        default:
          return Center(
            child: Text(
              'State Not Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
      }
    },
  );

  Widget _buildWalletInfoColumn(
    String label,
    String value, {
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value).textStyleH1Custom(zBlack),
        SizedBox(height: 4.h),
        Text(label).textStyleH2G(),
      ],
    );
  }

  Widget _buildWalletInfoColumnPL(
    String label,
    String value, {
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value).textStyleH1CPL(),
        SizedBox(height: 4.h),
        Text(label).textStyleH2G(),
      ],
    );
  }

  Widget _buildTradeDetails({
    // required String symbolName,
    // required double symbolPrice,
    required String mathod,
    required String profitandLoss,
    required String qnt,
    required String category,
    required String margin,
    required String marginHolding,
    required String currentPrice,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        _buildInfoRow('Current Market Price:', currentPrice.toString()),
        _buildInfoRowProfit('Profit and Loss:', profitandLoss.toString()),
        _buildInfoRow('Category:', category.toString()),
        _buildInfoRow('Margin:', margin.toString()),
        _buildInfoRow('Margin Holding:', marginHolding.toString()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isProfit = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label).textStyleH1(),
          Text(
            value,
            style: TextStyle(
              color: isProfit ? Colors.green : Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowProfit(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          ),
          Text(
            value,
            style: TextStyle(
              color: value.contains('-') ? Colors.red : Colors.green,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
