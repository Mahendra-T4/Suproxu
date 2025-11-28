import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/widgets/warning_alert_box.dart';
import 'package:suproxu/features/navbar/home/bloc/home_bloc.dart';

class OptimizedCancelOrderParams {
  final int status;
  final String symbolKey;
  final String dataRelatedTo;
  final dynamic stockPrice;
  final String tradeMethod;
  final int availableQty;
  final dynamic stockRecord; // Pre-loaded stock record to avoid API calls
  

  OptimizedCancelOrderParams({
    required this.status,
    required this.symbolKey,
    required this.dataRelatedTo,
    required this.stockPrice,
    required this.tradeMethod,
    required this.availableQty,
    required this.stockRecord,
   
  });
}

class OptimizedCancelOrder extends StatefulWidget {
  const OptimizedCancelOrder({
    Key? key,
    required this.params,
    this.refresh,
  }) : super(key: key);

  final OptimizedCancelOrderParams params;
  final VoidCallback? refresh;

  @override
  State<OptimizedCancelOrder> createState() => _OptimizedCancelOrderState();
}

class _OptimizedCancelOrderState extends State<OptimizedCancelOrder> {
  late HomeBloc _homeBloc;
  bool _isProcessing = false;

  @override
  void initState() {
    _homeBloc = HomeBloc();
    super.initState();
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  Future<void> _handleCancelOrder() async {
    if (_isProcessing) return; // Prevent multiple taps

    setState(() {
      _isProcessing = true;
    });

    try {
      // Get user balance immediately from database (cached)
      DatabaseService databaseService = DatabaseService();
      final userBalance =
          await databaseService.getUserData(key: userBalanceKey);

      // Calculate required amount using pre-loaded stock record
      final dynamic canBuy = (widget.params.stockPrice) *
          (widget.params.availableQty) *
          (widget.params.stockRecord?.lotSize ?? 1);

      // Parse user balance
      final double parsedUBalance = userBalance is String
          ? double.tryParse(userBalance) ?? 0.0
          : (userBalance ?? 0.0);

      // Check balance
      if (canBuy > parsedUBalance) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => const WarningAlertBox(
              title: 'Warning',
              message: 'You cannot close this trade. Your balance is low!',
            ),
          );
        }
        return;
      }

      // Immediate UI feedback - call refresh first
      if (widget.refresh != null) {
        widget.refresh!();
      }

      // Then process the trade in background
      if (widget.params.tradeMethod == '1') {
        _homeBloc.add(
          SaleStocksEvent(
            symbolKey: widget.params.symbolKey,
            categoryName: widget.params.dataRelatedTo,
            context: context,
            stockPrice: widget.params.stockPrice.toString(),
            stockQty: widget.params.availableQty.toString(),
          ),
        );
      } else {
        _homeBloc.add(
          BuyStocksEvent(
            symbolKey: widget.params.symbolKey,
            categoryName: widget.params.dataRelatedTo,
            context: context,
            stockPrice: widget.params.stockPrice.toString(),
            stockQty: widget.params.availableQty.toString(),
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      bloc: _homeBloc,
      listener: (context, state) {
        // Handle state changes if needed
        if (state is BuyStockLFailedErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      },
      child: SizedBox(
        width: MediaQuery.sizeOf(context).height * 0.6,
        child: ElevatedButton.icon(
          onPressed: _isProcessing ? null : _handleCancelOrder,
          icon: _isProcessing
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.close, size: 18.r, color: Colors.white),
          label: Text(
            _isProcessing ? 'PROCESSING...' : 'CLOSE TRADE',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isProcessing ? Colors.grey.shade600 : Colors.grey.shade700,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ),
    );
  }
}
