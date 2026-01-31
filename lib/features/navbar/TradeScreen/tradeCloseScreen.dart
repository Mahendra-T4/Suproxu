// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/features/navbar/TradeScreen/bloc/trade_bloc.dart';

import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol.dart';
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';

import '../home/model/symbol_page_param.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_symbol_param.dart';

class ClosedOrdersTab extends StatefulWidget {
  const ClosedOrdersTab({super.key});

  @override
  State<ClosedOrdersTab> createState() => _ClosedOrdersTabState();
}

class _ClosedOrdersTabState extends State<ClosedOrdersTab> {
  late TradeBloc _tradeBloc;

  @override
  void initState() {
    _tradeBloc = TradeBloc();
    _tradeBloc.add(ClosedStockTradeEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _tradeBloc,
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (TradeLoadingState):
            return const Center(child: CircularProgressIndicator.adaptive());
          case const (ClosedTradeLoadedSuccessState):
            final closedTrade =
                (state as ClosedTradeLoadedSuccessState).closedTradeEntity;
            return closedTrade.status == 1
                ? ListView.builder(
                    shrinkWrap: true,
                    // padding:
                    //     EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: closedTrade.record!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          if (closedTrade.record![index].dataRelatedTo ==
                              'MCX') {
                            GoRouter.of(context).pushNamed(
                              MCXSymbolRecordPage.routeName,
                              extra: MCXSymbolParams(
                                symbol: closedTrade.record![index].symbolName
                                    .toString(),
                                index: index,
                                symbolKey: closedTrade.record![index].symbolKey
                                    .toString(),
                              ),
                            );
                          } else if (closedTrade.record![index].dataRelatedTo ==
                              'NFO') {
                            GoRouter.of(context).pushNamed(
                              NseFutureSymbolPage.routeName,
                              extra: SymbolScreenParams(
                                symbol: closedTrade.record![index].symbolName
                                    .toString(),
                                index: index,
                                symbolKey: closedTrade.record![index].symbolKey
                                    .toString(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 15),
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          child: Column(
                            spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width / 2.6,
                                    child: Text(
                                      closedTrade.record![index].symbolName
                                          .toString(),
                                    ).textStyleH1(),
                                  ),
                                  Row(
                                    spacing: 4,
                                    children: [
                                      Container(
                                        // margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '${closedTrade.record![index].profitLoss}/${closedTrade.record![index].brokerageValue}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,

                                            fontFamily: FontFamily.globalFontFamily,
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
                                      Container(
                                        // margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          // vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.green,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          'Qty ${closedTrade.record![index].stockQty}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: FontFamily.globalFontFamily,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Sold by Trader',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: kGoldenBraunColor,
                                           fontFamily: FontFamily.globalFontFamily,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          // vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.redAccent,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '${closedTrade.record![index].salePrice}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                             fontFamily: FontFamily.globalFontFamily,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Bought by Trader',
                                      ).textStyleH3(),
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          // vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.green,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '${closedTrade.record![index].buyPrice}',
                                          style: const TextStyle(
                                            // fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            // fontFamily: 'JetBrainsMono',
                                            color: Colors.green,
                                             fontFamily: FontFamily.globalFontFamily,
                                          ),
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
                                    '${closedTrade.record![index].closeDate}',
                                  ).textStyleH2(),
                                  // Text(
                                  //   'Holding Mar.Ref: 10000',
                                  //   style: TextStyle(
                                  //       fontWeight: FontWeight.w400,
                                  //       fontSize: 12),
                                  // ),
                                ],
                              ),
                              const Divider(thickness: 1.5, color: zBlack),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      closedTrade.message.toString(),
                      style: TextStyle(
                        color: zBlack,
                        fontSize: 15,
                         fontFamily: FontFamily.globalFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
          case const (ClosedTradeFailedErrorState):
            return Center(
              child: Text(
                (state as ClosedTradeFailedErrorState).error,
                style: TextStyle(color: Colors.red, fontFamily: FontFamily.globalFontFamily, fontSize: 16.sp),
              ),
            );
          default:
            return const Center(
              child: Text(
                'State not found',
                style: TextStyle(color: Colors.white, fontFamily: FontFamily.globalFontFamily,),
              ),
            );
        }
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final String stockName;
  final String expiryDate;
  final String soldBy;
  final String boughtBy;
  final String market;
  final String qty;
  final String totalBuyPrice;
  final String totalSalePrice;
  final String closeMargin;
  final dynamic brockrage;

  const OrderCard({
    super.key,
    required this.stockName,
    required this.expiryDate,
    required this.soldBy,
    required this.boughtBy,
    required this.market,
    required this.qty,
    required this.totalBuyPrice,
    required this.totalSalePrice,
    required this.closeMargin,
    required this.brockrage,
  });

  parseDigits(String value) {
    return double.tryParse(value)?.toStringAsFixed(2) ?? value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
        border: Border.all(color: Colors.grey[800]!, width: 1),
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
                  children: [
                    _buildStockIcon(),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stockName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                             fontFamily: FontFamily.globalFontFamily,
                          ),
                        ),
                        Text(
                          expiryDate,
                          style: TextStyle(
                            color: kGoldenBraunColor,
                            fontSize: 12.sp,
                             fontFamily: FontFamily.globalFontFamily,
                          ),
                        ),
                      ],
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
                _buildBrokrage(),
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
           fontFamily: FontFamily.globalFontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTradeDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTradeInfo("Sold", soldBy, Colors.red),
        _buildTradeInfo("Bought", boughtBy, Colors.green),
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
            color: color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.globalFontFamily,
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
          style: TextStyle(
            color: kGoldenBraunColor,
            fontFamily: FontFamily.globalFontFamily,
            fontSize: 14.sp,
          ),
        ),
        Text(
          parseDigits(closeMargin),
          style: TextStyle(
            color: closeMargin.contains('-') ? Colors.redAccent : Colors.green,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: FontFamily.globalFontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildBrokrage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Brokerage",
          style: TextStyle(
            color: kGoldenBraunColor,
            fontFamily: FontFamily.globalFontFamily,
            fontSize: 14.sp,
          ),
        ),
        Text(
          brockrage.toString(),
          style: TextStyle(
            color: closeMargin.contains('-') ? Colors.redAccent : Colors.green,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: FontFamily.globalFontFamily,
          ),
        ),
      ],
    );
  }
}
