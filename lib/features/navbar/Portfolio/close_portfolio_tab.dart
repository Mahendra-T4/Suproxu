// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/features/navbar/Portfolio/bloc/portfolio_bloc.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';

class PortfolioCloseTab extends StatefulWidget {
  const PortfolioCloseTab({super.key});

  @override
  State<PortfolioCloseTab> createState() => _PortfolioCloseTabState();
}

class _PortfolioCloseTabState extends State<PortfolioCloseTab> {
  late PortfolioBloc _portfolioBloc;
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    _portfolioBloc = PortfolioBloc();
    _profileBloc = ProfileBloc();
    _portfolioBloc.add(ClosePortfolioDataFetchingEvent());
    _profileBloc.add(LoadUserWalletDataEvent());
    super.initState();
  }

  // Modern stat tile for glassmorphic card
  Widget _statTile({
    // required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
        ).textStyleH1C(label == 'Ledger Balance' ? Colors.black : color),
        Text(label).textStyleH2C(kGoldenBraunColor),
      ],
    );
  }

  Widget _statTileBro({
    // required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value).textStyleH1C(color),
        Text(label).textStyleH2C(kGoldenBraunColor),
      ],
    );
  }

  Widget get _userWallet => BlocBuilder(
    bloc: _profileBloc,
    builder: (context, state) {
      switch (state.runtimeType) {
        case const (ProfileLoadingState):
          return Center(child: const Text('Loading...').textStyleH1());
        case const (LoadUserWalletDataSuccessStatus):
          final wallet =
              (state as LoadUserWalletDataSuccessStatus).balanceEntity;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            padding: EdgeInsets.all(10.r),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Colors.grey[200]!.withOpacity(.7),
              border: Border.all(width: 1, color: Colors.black),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.1),
              //     blurRadius: 10,
              //     offset: const Offset(0, 5),
              //   ),
              // ],
            ),
            child: ClipRRect(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statTile(
                            // icon: Icons.account_balance_wallet_rounded,
                            label: 'Ledger Balance',
                            value: wallet.record!.first.availableBalance
                                .toString(),
                            color: Colors.greenAccent,
                          ),
                          Container(height: 40, width: 1, color: zBlack),
                          _statTile(
                            // icon: Icons.show_chart_rounded,
                            label: 'Profit & Loss      ',
                            value: wallet.record!.first.profitLoss.toString(),
                            color:
                                wallet.record!.first.profitLoss
                                    .toString()
                                    .contains('-')
                                ? Colors.redAccent
                                : Colors.green,
                          ),
                        ],
                      ),
                      Divider(color: zBlack, thickness: 1, height: 25.h),
                      // const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statTileBro(
                            // icon: Icons.receipt_long_rounded,
                            label: 'Total Brokerage',
                            value: wallet.record!.first.brokerageValue
                                .toString(),
                            color: zBlack,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 37),
                            height: 40,
                            width: 1,
                            color: zBlack,
                          ),
                          _statTile(
                            // icon: Icons.pie_chart_rounded,
                            label: 'Net Profit / Loss  ',
                            value: wallet.record!.first.netProfit.toString(),
                            color:
                                wallet.record!.first.netProfit
                                    .toString()
                                    .contains('-')
                                ? Colors.redAccent
                                : Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        // Modern stat tile for glassmorphic card

        case const (LoadUserWalletDataFailedStatus):
          final error = (state as LoadUserWalletDataFailedStatus).error;
          return Center(child: Text(error));
        default:
          return const Center(child: Text('State Not Found'));
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        _userWallet,
        SizedBox(height: 10.h),
        BlocBuilder(
          bloc: _portfolioBloc,
          builder: (context, state) {
            switch (state.runtimeType) {
              case const (PortfolioLoadingState):
                return Column(
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height / 3),
                    const Center(child: CircularProgressIndicator.adaptive()),
                  ],
                );
              case const (ClosedPortfolioLoadedSuccessState):
                final closedTrade = (state as ClosedPortfolioLoadedSuccessState)
                    .closePortfolioStockEntity;
                return closedTrade.status == 1
                    ? Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          // padding: EdgeInsets.only(top: 15.h),
                          itemCount: closedTrade.record!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              // margin: const EdgeInsets.only(top: 5),
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              alignment: Alignment.center,
                              child: Column(
                                spacing: 4,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width /
                                                2.9,
                                            child: Text(
                                              closedTrade
                                                  .record![index]
                                                  .symbolName
                                                  .toString(),
                                            ).textStyleH1(),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        // spacing: 4,
                                        children: [
                                          Container(
                                            // margin: const EdgeInsets.only(
                                            //     right: 4),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              // vertical: 2.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color:
                                                    closedTrade
                                                        .record![index]
                                                        .profitLoss
                                                        .toString()
                                                        .contains('-')
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${closedTrade.record![index].profitLoss} / ${closedTrade.record![index].brokerageValue}',
                                              style: TextStyle(
                                                // fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                // fontFamily: 'JetBrainsMono',
                                                color:
                                                    closedTrade
                                                        .record![index]
                                                        .profitLoss
                                                        .toString()
                                                        .contains('-')
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            // margin: const EdgeInsets.only(left: 10),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              // vertical: 2.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.green,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Qty ${closedTrade.record![index].stockQty}',
                                              style: const TextStyle(
                                                // fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                // fontFamily: 'JetBrainsMono',
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Text(
                                      //   'Qty : ${closedTrade.record![index].stockQty}',
                                      //   style: const TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.w500,
                                      //     fontFamily: 'JetBrainsMono',
                                      //     color: Colors.red,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Avg Sale: ${closedTrade.record![index].salePrice}',
                                      ).textStyleH3(),
                                      Text(
                                        'Avg Buy: ${closedTrade.record![index].buyPrice}',
                                      ).textStyleH3(),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Net Profit/Loss: ',
                                          ).textStyleH3(),
                                          Text(
                                            closedTrade
                                                .record![index]
                                                .profitLoss
                                                .toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              // fontFamily: 'JetBrainsMono',
                                              color:
                                                  closedTrade
                                                      .record![index]
                                                      .profitLoss
                                                      .toString()
                                                      .contains('-')
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Brokerage: ',
                                          ).textStyleH3(),
                                          Text(
                                            '${closedTrade.record![index].brokerageValue}',
                                          ).textStyleH3R(),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(color: zBlack, thickness: 1.5),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height / 4.5,
                            ),
                            Text(
                              closedTrade.message.toString(),
                              style: const TextStyle(
                                color: zBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
              case const (ClosedPortfolioFailedErrorState):
                return Center(
                  child: Text(
                    (state as ClosedPortfolioFailedErrorState).error,
                    style: TextStyle(color: Colors.red, fontSize: 16.sp),
                  ),
                );
              default:
                return const Center(
                  child: Text(
                    'State not found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
            }
          },
        ),
      ],
    );
  }

  // Widget _buildTradesList() {
  //   return Expanded(
  //     child: ListView.builder(
  //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //       itemCount: 4,
  //       itemBuilder: (context, index) {
  //         return OrderCard(
  //           stockName: index == 0 ? "CRUDEOIL" : "SILVER",
  //           expiryDate: "19-AUG-2024",
  //           soldBy: "6406",
  //           boughtBy: "6405",
  //           market: index % 2 == 0 ? "MARKET" : "ORDER",
  //           qty: "1",
  //           margin: index % 2 == 0 ? "+100/-192.18" : "-17880/-1492.524",
  //         );
  //       },
  //     ),
  //   );
  // }
}

class OrderCard extends StatelessWidget {
  final String stockName;
  final String profitLoss;
  final String soldBy;
  final String boughtBy;
  final String market;
  final String brokerage;
  final String qty;
  final String totalBuyPrice;
  final String totalSalePrice;
  final String closeMargin;

  const OrderCard({
    super.key,
    required this.stockName,
    required this.profitLoss,
    required this.soldBy,
    required this.boughtBy,
    required this.market,
    required this.brokerage,
    required this.qty,
    required this.totalBuyPrice,
    required this.totalSalePrice,
    required this.closeMargin,
  });

  parseDigits(String value) {
    return double.tryParse(value)?.toStringAsFixed(2) ?? value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [
        //     Colors.grey[900]!.withOpacity(0.95),
        //     Colors.grey[850]!.withOpacity(0.95),
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        color: Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStockIcon(),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stockName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _buildMarketTag(),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildTradeDetails(),
                SizedBox(height: 16.h),
                _buildTradeDetails1(),
                SizedBox(height: 16.h),
                _buildProfitLoss(),
                _buildBrockrage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockIcon() {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.show_chart, color: Colors.blue, size: 20.r),
    );
  }

  Widget _buildMarketTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        market,
        style: TextStyle(
          color: Colors.green,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTradeDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTradeInfo("Avg Sale", soldBy, Colors.red),
        _buildTradeInfo("Avg Buy", boughtBy, Colors.green),
        _buildTradeInfo("Qty", qty, Colors.blue),
      ],
    );
  }

  Widget _buildTradeDetails1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTradeInfo(
          "Total Sale Price",
          parseDigits(totalSalePrice),
          Colors.red,
        ),
        _buildTradeInfo(
          "Total Buy Price",
          parseDigits(totalBuyPrice),
          Colors.green,
        ),
        _buildTradeInfo("Profit&Loss", parseDigits(profitLoss), Colors.red),
        // _buildTradeInfo("Qty", qty, Colors.blue),
      ],
    );
  }

  Widget _buildTradeInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfitLoss() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Close Margin",
          style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        ),
        Text(
          parseDigits(closeMargin),
          style: TextStyle(
            color: closeMargin.contains('-') ? Colors.redAccent : Colors.green,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBrockrage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Brokerage",
          style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        ),
        Text(
          brokerage,
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
