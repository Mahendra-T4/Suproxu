import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/features/navbar/Portfolio/model/active_portfolio_socket_model.dart';
import 'package:suproxu/features/navbar/Portfolio/provider/active_port_provider.dart';
import 'package:suproxu/features/navbar/Portfolio/websocket/active_portfolio_socket.dart';
import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol.dart';
import 'package:suproxu/features/navbar/home/model/close_stock_param.dart';
import 'package:suproxu/features/navbar/home/model/symbol_page_param.dart';
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';
import 'package:suproxu/features/navbar/home/repository/buy_sale_repo.dart';
import 'package:suproxu/features/navbar/home/repository/trade_repository.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_symbol_param.dart';

class PortfolioActiveTab extends ConsumerStatefulWidget {
  const PortfolioActiveTab({super.key});

  @override
  ConsumerState<PortfolioActiveTab> createState() => _PortfolioActiveTabState();
}

class _PortfolioActiveTabState extends ConsumerState<PortfolioActiveTab>
    with SingleTickerProviderStateMixin {
  late ActivePortfolioSocket _activePortfolioSocket;
  ActivePortfolioSocketModel data = ActivePortfolioSocketModel();
  bool _isLoading = true;
  late AnimationController _animationController;
  final Set<int> loadingIndices = {};
  final Set<int> lockedIndices = {}; // Track locked items
  late Timer _refreshTimer;
  late Timer pageLoaderTimer;

  @override
  void initState() {
    super.initState();

    _activePortfolioSocket = ActivePortfolioSocket(
      onDataReceived: (newData) {
        log('Portfolio WebSocket Data Received: $newData');
        setState(() {
          data = newData;
          setState(() {
            _isLoading = false;
          });
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
    // pageLoaderTimer = Timer(const Duration(seconds: 2), () {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });

    _refreshTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        _refreshWishlistData();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void deactivate() {
    super.deactivate();
    // Disconnect socket when page is not active
    _activePortfolioSocket.disconnect();
    log('Portfolio socket deactivated and disconnected');
  }

  @override
  void activate() {
    super.activate();
    // Reconnect socket when page becomes active
    _activePortfolioSocket.connect();
    log('Portfolio socket activated and reconnected');
  }

  Future<void> _refreshWishlistData() async {
    debugPrint('Refreshing MCX Wishlist Data');

    if (mounted && _activePortfolioSocket.socket.connected) {
      debugPrint('Socket connected - data will auto-refresh');
    } else if (mounted) {
      _activePortfolioSocket.connect();
    }
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _activePortfolioSocket.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(aquaGreyColor),
              ),
            )
          : data.status != 1
          ? Center(child: Text('No active trades available').textStyleH2G())
          : Builder(
              builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _userWallet(
                        (data.accountStatics?.activeProfitLoss ?? 0).toDouble(),
                        (data.accountStatics?.m2m ?? 0).toDouble(),
                        (data.accountStatics?.marginAvailable ?? 0).toDouble(),
                        (data.accountStatics?.requiredHoldingMargin ?? 0)
                            .toDouble(),
                        (data.accountStatics?.ledgerBalance ?? 0).toDouble(),
                      ),

                      ListView.builder(
                        padding: const EdgeInsets.only(bottom: 70, top: 10),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.response?.length ?? 0,
                        itemBuilder: (context, index) {
                          final item = data.response![index];
                          return AbsorbPointer(
                            absorbing: lockedIndices.contains(index),
                            child: Opacity(
                              opacity: lockedIndices.contains(index)
                                  ? 0.6
                                  : 1.0,
                              child: InkWell(
                                onTap: () {
                                  if (lockedIndices.contains(index)) return;
                                  if (item.dataRelatedTo == 'MCX') {
                                    GoRouter.of(context).pushNamed(
                                      MCXSymbolRecordPage.routeName,
                                      extra: MCXSymbolParams(
                                        symbol: item.symbolName.toString(),
                                        index: index,
                                        symbolKey: item.symbolKey.toString(),
                                      ),
                                    );
                                  } else if (item.dataRelatedTo == 'NFO') {
                                    GoRouter.of(context).pushNamed(
                                      NseFutureSymbolPage.routeName,
                                      extra: SymbolScreenParams(
                                        symbol: item.symbolName.toString(),
                                        index: index,
                                        symbolKey: item.symbolKey.toString(),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width /
                                                2,
                                            child: Text(
                                              item.symbolName.toString(),
                                            ).textStyleH1(),
                                          ),
                                          Text(
                                            item.tradeMethod != 1
                                                ? 'Sold ${item.qty} X ${item.tradePrice}'
                                                : 'Bought ${item.qty} X ${item.tradePrice}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily:
                                                  FontFamily.globalFontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: item.tradeMethod != 1
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox.shrink(),
                                          Row(
                                            children: [
                                              const Text(
                                                'Profit & Loss: ',
                                              ).textStyleH3(),
                                              Text(
                                                item.profitLoss.toString(),
                                                style: TextStyle(
                                                  fontFamily: FontFamily
                                                      .globalFontFamily,
                                                  color:
                                                      item.profitLoss
                                                          .toString()
                                                          .contains('-')
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Margin: ${item.margin}',
                                          ).textStyleH3(),
                                          Text(
                                            'CMP ${item.currentMarketPrice}',
                                          ).textStyleH3(),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Holding Margin: ${item.marginHolding}',
                                          ).textStyleH3(),
                                          Text(
                                            'M2M: ${item.tradeM2M}',
                                          ).textStyleH3(),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          loadingIndices.contains(index)
                                              ? Container(
                                                  alignment: Alignment.center,
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
                                                    if (lockedIndices.contains(
                                                      index,
                                                    )) {
                                                      return;
                                                    }
                                                    setState(() {
                                                      loadingIndices.add(index);
                                                      lockedIndices.add(index);
                                                    });
                                                    try {
                                                      final getData =
                                                          await TradeRepository.getStockRecords(
                                                            item.symbolKey
                                                                .toString(),
                                                            item.dataRelatedTo
                                                                .toString(),
                                                          );
                                                      if (getData
                                                          .response
                                                          .isEmpty) {
                                                        setState(() {
                                                          loadingIndices.remove(
                                                            index,
                                                          );
                                                        });
                                                        failedToast(
                                                          context,
                                                          'No stock records available',
                                                        );
                                                        return;
                                                      }
                                                      final param = CloseStockParam(
                                                        symbolKey: item
                                                            .symbolKey
                                                            .toString(),
                                                        categoryName: item
                                                            .dataRelatedTo
                                                            .toString(),
                                                        stockPrice:
                                                            item.tradeMethod ==
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
                                                        stockQty: item.qty
                                                            .toString(),
                                                        context: context,
                                                      );
                                                      final result = await ref.read(
                                                        item.tradeMethod == 1
                                                            ? saleStockProvider(
                                                                param,
                                                              ).future
                                                            : buyStockProvider(
                                                                param,
                                                              ).future,
                                                      );
                                                      if (result.status == 1) {
                                                        if (mounted) {
                                                          setState(() {
                                                            loadingIndices
                                                                .remove(index);
                                                            lockedIndices
                                                                .remove(index);
                                                            // Remove the closed trade from the local list instantly
                                                            data.response
                                                                ?.removeAt(
                                                                  index,
                                                                );
                                                          });
                                                          successToastMsg(
                                                            context,
                                                            result.message
                                                                .toString(),
                                                          );
                                                          await Future.delayed(
                                                            const Duration(
                                                              milliseconds: 300,
                                                            ),
                                                          );
                                                          if (mounted) {
                                                            ref.invalidate(
                                                              activePortfolioProvider,
                                                            );
                                                          }
                                                        }
                                                      } else {
                                                        setState(() {
                                                          loadingIndices.remove(
                                                            index,
                                                          );
                                                          lockedIndices.remove(
                                                            index,
                                                          );
                                                        });
                                                        failedToast(
                                                          context,
                                                          result.message
                                                              .toString(),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      log(
                                                        'Error closing trade: $e',
                                                      );
                                                      setState(() {
                                                        loadingIndices.remove(
                                                          index,
                                                        );
                                                        lockedIndices.remove(
                                                          index,
                                                        );
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 25,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 7,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.redAccent,
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
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 10.w),
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
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _userWallet(
    double profitLoss,

    dynamic m2m,
    dynamic availableMargin,
    dynamic requiredHoldingMargin,
    dynamic ledgerBalance,
  ) => Container(
    margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10),
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
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWalletInfoColumn(
                        'Ledger Balance',
                        ledgerBalance.toStringAsFixed(2).toString(),
                        textColor: Colors.black87,
                      ),
                      Container(height: 40.h, width: 1.w, color: Colors.black),
                      _buildWalletInfoColumn(
                        'Available Margin',
                        availableMargin.toStringAsFixed(2).toString(),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWalletInfoColumnPL(
                        'Active P&L',
                        profitLoss.toStringAsFixed(2).toString(),
                        textColor: profitLoss >= 0 ? Colors.green : Colors.red,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 30),
                        height: 40.h,
                        width: 1.w,
                        color: Colors.black,
                      ),
                      _buildWalletInfoColumn(
                        'M 2 M                   ',
                        m2m.toStringAsFixed(2).toString(),
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
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  fontSize: 15.5,
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
}
