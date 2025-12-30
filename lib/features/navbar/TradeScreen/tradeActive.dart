import 'dart:async';
import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/widgets/warning_alert_box.dart';
import 'package:suproxu/features/navbar/TradeScreen/bloc/trade_bloc.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/close_all_order_model.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/param.dart';
import 'package:suproxu/features/navbar/TradeScreen/repositories/trade_repo.dart';
import 'package:suproxu/features/navbar/home/bloc/home_bloc.dart';
import 'package:suproxu/features/navbar/home/mcx/McxSymbolsScreen.dart';
import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol.dart';
import 'package:suproxu/features/navbar/home/nse-future/fnoSymbolScreen.dart'
    hide SymbolScreenParams;
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';
import 'package:suproxu/features/navbar/home/repository/trade_repository.dart';

import '../home/model/symbol_page_param.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_symbol_param.dart';

final closeAllOrdersProvider =
    FutureProvider.family<CloseAllOrderModel, CloseOrderParam>(
      (ref, param) => TradeStockRepository.closeAllOrders(param: param),
    );

class Tradeactive extends StatefulWidget {
  const Tradeactive({super.key});

  @override
  State<Tradeactive> createState() => _TradeactiveState();
}

class _TradeactiveState extends State<Tradeactive>
    with SingleTickerProviderStateMixin {
  //* new one
  final Set<int> loadingIndices = {}; // Add this line
  bool _isClosingAllMCXOrders = false;
  bool _isClosingAllNFOOrders = false;
  bool isLockedButton = false;
  bool get isProcessing => _isClosingAllMCXOrders || _isClosingAllNFOOrders;

  late TradeBloc _tradeBloc;
  late HomeBloc _homeBloc;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final client = http.Client();
  final url = Uri.parse(superTradeBaseApiEndPointUrl);
  dynamic uBalance;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _tradeBloc = TradeBloc();
    _homeBloc = HomeBloc();
    _tradeBloc.add(ActiveStockTradeEvent(activity: 'active-stock'));

    // Setup periodic updates
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
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
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCloseAllButton(String type) {
    return Consumer(
      builder: (context, WidgetRef ref, child) {
        return AbsorbPointer(
          absorbing: isProcessing,
          child: Opacity(
            opacity: isProcessing ? 0.6 : 1.0,
            child: InkWell(
              onTap: () async {
                if (!mounted) return;
                setState(() {
                  if (type == 'MCX') {
                    _isClosingAllMCXOrders = true;
                  } else {
                    _isClosingAllNFOOrders = true;
                  }
                  isLockedButton = true;
                });
                try {
                  await ref
                      .read(
                        closeAllOrdersProvider(
                          CloseOrderParam(
                            context: context,
                            dataRelatedTo: type,
                          ),
                        ).future,
                      )
                      .then(
                        (_) => _tradeBloc.add(
                          ActiveStockTradeEvent(activity: 'active-stock'),
                        ),
                      );
                } catch (e) {
                  if (!mounted) return;
                  log(name: 'Close All $type Orders Error', e.toString());
                } finally {
                  if (mounted) {
                    setState(() {
                      if (type == 'MCX') {
                        _isClosingAllMCXOrders = false;
                      } else {
                        _isClosingAllNFOOrders = false;
                      }
                      isLockedButton = false;
                    });
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Close All $type Orders',
                  style: TextStyle(color: kWhiteColor),
                ).textStyleH2W(),
              ),
            ),
          ),
        );
      },
    );
  }

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
    return ProviderScope(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: zBlack,
          // appBar: _buildAppBar(),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                BlocBuilder(
                  bloc: _tradeBloc,
                  builder: (context, state) {
                    if (state is ActiveTradeLoadedSuccessState &&
                        state.activeTrade.status == 1) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCloseAllButton('MCX'),
                            _buildCloseAllButton('NFO'),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Expanded(
                  child: BlocBuilder(
                    bloc: _tradeBloc,
                    builder: (context, state) {
                      if (state is TradeLoadingState) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      } else if (state is ActiveTradeLoadedSuccessState) {
                        final activeTradeEntity = state.activeTrade;
                        return activeTradeEntity.status == 1
                            ? AbsorbPointer(
                                absorbing: isProcessing,
                                child: Opacity(
                                  opacity: isProcessing ? 0.6 : 1.0,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(top: 10),
                                    itemCount: activeTradeEntity.record!.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          if (activeTradeEntity
                                                  .record![index]
                                                  .dataRelatedTo ==
                                              'MCX') {
                                            GoRouter.of(context).pushNamed(
                                              MCXSymbolRecordPage.routeName,
                                              extra: MCXSymbolParams(
                                                symbol: activeTradeEntity
                                                    .record![index]
                                                    .symbolName
                                                    .toString(),
                                                index: index,
                                                symbolKey: activeTradeEntity
                                                    .record![index]
                                                    .symbolKey
                                                    .toString(),
                                              ),
                                            );
                                          } else if (activeTradeEntity
                                                  .record![index]
                                                  .dataRelatedTo ==
                                              'NFO') {
                                            GoRouter.of(context).pushNamed(
                                              NseFutureSymbolPage.routeName,
                                              extra: SymbolScreenParams(
                                                symbol: activeTradeEntity
                                                    .record![index]
                                                    .symbolKey
                                                    .toString(),
                                                index: index,
                                                symbolKey: activeTradeEntity
                                                    .record![index]
                                                    .symbolKey
                                                    .toString(),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          // margin: const EdgeInsets.only(top: 10),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    // margin: const EdgeInsets.only(left: 10),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          // vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            activeTradeEntity
                                                                    .record![index]
                                                                    .tradeMethod ==
                                                                1
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${activeTradeEntity.record![index].orderMethod} X ${activeTradeEntity.record![index].availableQty}',
                                                      style: TextStyle(
                                                        color:
                                                            activeTradeEntity
                                                                    .record![index]
                                                                    .tradeMethod ==
                                                                1
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    // margin: const EdgeInsets.only(left: 10),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          // vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: Colors.red,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      activeTradeEntity
                                                          .record![index]
                                                          .stockPrice
                                                          .toString(),
                                                    ).textStyleH2R(),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
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
                                                        1.8,
                                                    child: Text(
                                                      activeTradeEntity
                                                          .record![index]
                                                          .symbolName
                                                          .toString(),
                                                    ).textStyleH1(),
                                                  ),
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
                                                          child: const Text(
                                                            'Processing...',
                                                          ),
                                                        )
                                                      : InkWell(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.r,
                                                              ),
                                                          onTap: () async {
                                                            setState(() {
                                                              loadingIndices.add(
                                                                index,
                                                              ); // Add loading state for this specific button
                                                            });

                                                            try {
                                                              final getData = await TradeRepository.getStockRecords(
                                                                activeTradeEntity
                                                                    .record![index]
                                                                    .symbolKey
                                                                    .toString(),
                                                                activeTradeEntity
                                                                    .record![index]
                                                                    .dataRelatedTo
                                                                    .toString(),
                                                              );

                                                              if (!mounted)
                                                                return;

                                                              if (!getData
                                                                  .response
                                                                  .isNotEmpty) {
                                                                throw Exception(
                                                                  'No stock records found',
                                                                );
                                                              }

                                                              if (activeTradeEntity
                                                                      .record![index]
                                                                      .tradeMethod ==
                                                                  1) {
                                                                _homeBloc.add(
                                                                  SaleStocksEvent(
                                                                    symbolKey: activeTradeEntity
                                                                        .record![index]
                                                                        .symbolKey
                                                                        .toString(),
                                                                    categoryName: activeTradeEntity
                                                                        .record![index]
                                                                        .dataRelatedTo
                                                                        .toString(),
                                                                    context:
                                                                        context,
                                                                    stockPrice: getData
                                                                        .response[0]
                                                                        .ohlc
                                                                        .salePrice
                                                                        .toString(),
                                                                    stockQty: activeTradeEntity
                                                                        .record![index]
                                                                        .availableQty
                                                                        .toString(),
                                                                  ),
                                                                );
                                                                setState(() {
                                                                  loadingIndices
                                                                      .remove(
                                                                        index,
                                                                      );
                                                                  activeTradeEntity
                                                                      .record!
                                                                      .removeAt(
                                                                        index,
                                                                      ); // Add loading state for this specific button
                                                                });

                                                                _tradeBloc.add(
                                                                  ActiveStockTradeEvent(
                                                                    activity:
                                                                        'active-stock',
                                                                  ),
                                                                );
                                                              } else {
                                                                _homeBloc.add(
                                                                  BuyStocksEvent(
                                                                    symbolKey: activeTradeEntity
                                                                        .record![index]
                                                                        .symbolKey
                                                                        .toString(),
                                                                    categoryName: activeTradeEntity
                                                                        .record![index]
                                                                        .dataRelatedTo
                                                                        .toString(),
                                                                    context:
                                                                        context,
                                                                    stockPrice: getData
                                                                        .response[0]
                                                                        .ohlc
                                                                        .buyPrice
                                                                        .toString(),
                                                                    stockQty: activeTradeEntity
                                                                        .record![index]
                                                                        .availableQty
                                                                        .toString(),
                                                                  ),
                                                                );
                                                                setState(() {
                                                                  loadingIndices
                                                                      .remove(
                                                                        index,
                                                                      );
                                                                  activeTradeEntity
                                                                      .record!
                                                                      .removeAt(
                                                                        index,
                                                                      ); // Add loading state for this specific button
                                                                });

                                                                _tradeBloc.add(
                                                                  ActiveStockTradeEvent(
                                                                    activity:
                                                                        'active-stock',
                                                                  ),
                                                                );
                                                              }

                                                              // Wait for the HomeBloc action to complete
                                                              await _homeBloc
                                                                  .stream
                                                                  .firstWhere(
                                                                    (state) =>
                                                                        state
                                                                            is! HomeLoadingState,
                                                                  );

                                                              // Clear loading state
                                                              setState(() {
                                                                loadingIndices
                                                                    .remove(
                                                                      index,
                                                                    );
                                                              });

                                                              // Trigger refresh of trade list

                                                              // // Clear loading state and refresh data
                                                              // setState(() {
                                                              //   loadingIndices
                                                              //       .remove(index);
                                                              // });

                                                              // Refresh the trade list
                                                            } catch (e) {
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Error: $e',
                                                                    ),
                                                                  ),
                                                                );
                                                                setState(() {
                                                                  loadingIndices
                                                                      .remove(
                                                                        index,
                                                                      );
                                                                });
                                                              }
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
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    (() {
                                                      if (activeTradeEntity
                                                              .record![index]
                                                              .tradeMethod ==
                                                          1) {
                                                        return 'Sold by Trader';
                                                      } else {
                                                        return 'Bought by Trader';
                                                      }
                                                    })(),
                                                  ).textStyleH3(),
                                                  Text(
                                                    'Margin : ${activeTradeEntity.record![index].margin}',
                                                  ).textStyleH3(),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${activeTradeEntity.record![index].currentDate} & ${activeTradeEntity.record![index].time}',
                                                  ).textStyleH3(),
                                                  Text(
                                                    'Holding Mar Req : ${activeTradeEntity.record![index].marginHolding}',
                                                  ).textStyleH3(),
                                                ],
                                              ),
                                              const Divider(
                                                thickness: 1.5,
                                                color: zBlack,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        activeTradeEntity.message.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                      } else if (state is ActiveTradeFailedErrorState) {
                        return Center(child: Text(state.error));
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  activeCloseTradeSaleButton({
    required int status,
    required String symbolKey,
    required String dataRelatedTo,
    required dynamic stockPrice,
    required int tradeMethod,
    required int availableQty,
  }) {
    return BlocConsumer(
      listener: (context, state) {},
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is HomeLoadingState) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return SizedBox(
          width: MediaQuery.sizeOf(context).height * 0.6,
          child: ElevatedButton.icon(
            onPressed: () async {
              //! dummy value
              final data = await TradeRepository.getStockRecords(
                symbolKey.toString(),
                dataRelatedTo.toString(),
              );
              // Fix: Use data.response.first.lotSize to avoid RangeError
              dynamic canBuy =
                  (stockPrice) *
                  (availableQty) *
                  (data.response.isNotEmpty ? data.response.first.lotSize : 1);

              // Ensure uBalance is parsed to a num (double) for comparison
              final double parsedUBalance = uBalance is String
                  ? double.tryParse(uBalance) ?? 0.0
                  : (uBalance ?? 0.0);

              if (canBuy > parsedUBalance) {
                showDialog(
                  context: context,
                  builder: (context) => const WarningAlertBox(
                    title: 'Warning',
                    message: 'You Cant Sale Stock Your Balance is Low!',
                  ),
                );
              } else {
                _homeBloc.add(
                  SaleStocksEvent(
                    symbolKey: symbolKey.toString(),
                    categoryName: dataRelatedTo,
                    context: context,
                    stockPrice: stockPrice.toString(),
                    stockQty: availableQty.toString(),
                  ),
                );
              }
            },
            icon: Icon(Icons.close, size: 18.r, color: Colors.white),
            label: Text(
              'CLOSE TRADE',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        );
      },
    );
  }

  activeCloseTradeBuyButton({
    required int status,
    required String symbolKey,
    required String dataRelatedTo,
    required dynamic stockPrice,
    required int tradeMethod,
    required int availableQty,
  }) {
    return BlocConsumer(
      listener: (context, state) {},
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is HomeLoadingState) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return SizedBox(
          width: MediaQuery.sizeOf(context).height * 0.6,
          child: ElevatedButton.icon(
            onPressed: () async {
              //! dummy value
              final data = await TradeRepository.getStockRecords(
                symbolKey.toString(),
                dataRelatedTo.toString(),
              );
              // Fix: Use data.response.first.lotSize to avoid RangeError
              dynamic canBuy =
                  (stockPrice) *
                  (availableQty) *
                  (data.response.isNotEmpty ? data.response.first.lotSize : 1);

              // Ensure uBalance is parsed to a num (double) for comparison
              final double parsedUBalance = uBalance is String
                  ? double.tryParse(uBalance) ?? 0.0
                  : (uBalance ?? 0.0);

              if (canBuy > parsedUBalance) {
                showDialog(
                  context: context,
                  builder: (context) => const WarningAlertBox(
                    title: 'Warning',
                    message: 'You Cant Sale Stock Your Balance is Low!',
                  ),
                );
              } else {
                _homeBloc.add(
                  BuyStocksEvent(
                    symbolKey: symbolKey.toString(),
                    categoryName: dataRelatedTo,
                    context: context,
                    stockPrice: stockPrice.toString(),
                    stockQty: availableQty.toString(),
                  ),
                );
              }
            },
            icon: Icon(Icons.close, size: 18.r, color: Colors.white),
            label: Text(
              'CLOSE TRADE',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
