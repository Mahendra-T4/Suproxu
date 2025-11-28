// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';

import 'package:suproxu/core/widgets/warning_alert_box.dart';
import 'package:suproxu/features/navbar/home/bloc/home_bloc.dart';
import 'package:suproxu/features/navbar/home/repository/trade_repository.dart';
import 'package:suproxu/features/navbar/widgets/cancel_order_sale.dart';

class CancelOrderBuy extends StatefulWidget {
  const CancelOrderBuy({Key? key, required this.params, this.refresh})
      : super(key: key);
  final CancelOrderParams params;
  final VoidCallback? refresh;

  @override
  State<CancelOrderBuy> createState() => _CancelOrderSBuyState();
}

class _CancelOrderSBuyState extends State<CancelOrderBuy> {
  late HomeBloc _homeBloc;
  dynamic uBalance;
  late Timer _timer;

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
  void initState() {
    _homeBloc = HomeBloc();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        initUser();
      } else {
        timer.cancel();
      }
    });

    initUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      listener: (context, state) {},
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is HomeLoadingState2) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        return SizedBox(
          width: MediaQuery.sizeOf(context).height * 0.6,
          child: ElevatedButton.icon(
            onPressed: () async {
              //! dummy value
              final data = await TradeRepository.getStockRecords(
                  widget.params.symbolKey.toString(),
                  widget.params.dataRelatedTo.toString());
              // Fix: Use data.response.first.lotSize to avoid RangeError
              dynamic canBuy = (widget.params.stockPrice) *
                  (widget.params.availableQty) *
                  (data.response.first.lotSize);

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
                    symbolKey: widget.params.symbolKey.toString(),
                    categoryName: widget.params.dataRelatedTo,
                    context: context,
                    stockPrice: widget.params.stockPrice.toString(),
                    stockQty: widget.params.availableQty.toString(),
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
                  color: Colors.white),
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
