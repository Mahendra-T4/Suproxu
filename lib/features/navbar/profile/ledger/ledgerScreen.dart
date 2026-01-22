import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';

class LedgerReportScreen extends StatefulWidget {
  const LedgerReportScreen({super.key});

  static const String routeName = '/ledger-report-screen';

  @override
  _LedgerReportScreenState createState() => _LedgerReportScreenState();
}

class _LedgerReportScreenState extends State<LedgerReportScreen>
    with SingleTickerProviderStateMixin {
  String? selectedDateRange = "27 Jul, 2024 - 28 Jul, 2024";

  // late Animation<double> _fadeAnimation;

  late ProfileBloc _profileBloc;

  late Timer _timer;
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
  void initState() {
    super.initState();

    _profileBloc = ProfileBloc();
    _profileBloc.add(FetchLedgerRecordsEvent());
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        initUser();
      } else {
        timer.cancel();
      }
    });

    initUser();
  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: InternetConnectionService().connectionStream,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return const NoInternetConnection(); // Show your offline UI
        }
        return Container(
          color: greyColor,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: zBlack,
              appBar: customAppBarWithTitle(
                context: context,
                title: 'Ledger',
                isShowNotify: true,
              ),
              body: BlocConsumer(
                bloc: _profileBloc,
                listener: (context, state) {
                  if (state is FetchLedgerRecordFailedStatus) {
                    failedToast(context, state.error.toString());
                  }
                },
                builder: (context, state) {
                  switch (state.runtimeType) {
                    case const (ProfileLoadingState):
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );

                    case const (FetchLedgerRecordSuccessStatus):
                      final ledgerEntity =
                          (state as FetchLedgerRecordSuccessStatus)
                              .ledgerEntity;
                      return ledgerEntity.status == 1
                          ? ListView.builder(
                              shrinkWrap: true,
                              // padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: ledgerEntity.record!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.r),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildTradeHeader(
                                            qnty: int.parse(
                                              ledgerEntity
                                                  .record![index]
                                                  .tradeID
                                                  .toString(),
                                            ),
                                            date: ledgerEntity
                                                .record![index]
                                                .currentDate
                                                .toString(),
                                            time: ledgerEntity
                                                .record![index]
                                                .time
                                                .toString(),
                                          ),
                                          SizedBox(height: 16.h),
                                          _buildTradeDetails(
                                            symbolName: ledgerEntity
                                                .record![index]
                                                .symbolName
                                                .toString(),
                                            symbolPrice: ledgerEntity
                                                .record![index]
                                                .stockPrice!
                                                .toDouble(),
                                            mathod: ledgerEntity
                                                .record![index]
                                                .orderMethod
                                                .toString(),
                                            category: ledgerEntity
                                                .record![index]
                                                .dataRelatedTo
                                                .toString(),
                                          ),
                                          // SizedBox(height: 16.h),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ledgerEntity.message.toString(),
                                    style: TextStyle(
                                      color: kWhiteColor,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                    case const (FetchLedgerRecordFailedStatus):
                      return const SizedBox.shrink();
                    default:
                      return const Center(child: Text('State not found'));
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTradeHeader({
    required int qnty,
    required String date,
    required String time,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTradeStatus('# $qnty', Colors.green),
        Text('$date - $time').textStyleH2(),
      ],
    );
  }

  Widget _buildTradeDetails({
    required String symbolName,
    required double symbolPrice,
    required String mathod,
    required String category,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(symbolName).textStyleH1()],
            ),
            Text(symbolPrice.toString()).textStyleH1(),
          ],
        ),
        SizedBox(height: 12.h),
        _buildInfoRow('Category:', category.toString()),
        _buildInfoRow('Method:', mathod.toString()),
        // _buildInfoRow('Method:', mathod.toString()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isProfit = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label).textStyleH2(), Text(value).textStyleH2()],
      ),
    );
  }

  Widget _buildTopButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(width: 1, color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(text, textAlign: TextAlign.center).textStyleH1(),
    );
  }

  Widget _buildTradeStatus(String text, Color color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            // fontFamily: 'JetBrainsMono',
          ),
        ),
      ),
    );
  }
}
