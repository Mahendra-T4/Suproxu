import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/features/navbar/TradeScreen/bloc/trade_bloc.dart';
import 'package:suproxu/features/navbar/TradeScreen/model/cancel_order_entity.dart';
import 'package:suproxu/features/navbar/TradeScreen/repositories/trade_repo.dart';
import 'package:suproxu/features/navbar/home/mcx/McxSymbolsScreen.dart';
import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol.dart';
import 'package:suproxu/features/navbar/home/nse-future/fnoSymbolScreen.dart'
    hide SymbolScreenParams;
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';

import '../home/model/symbol_page_param.dart' show SymbolScreenParams;
import 'package:suproxu/features/navbar/wishlist/model/mcx_symbol_param.dart';

final cancelTradeProvider = FutureProvider.family<CancelOrderEntity, String>(
  (ref, tradeKey) async =>
      TradeStockRepository.cancelPendingTrade(tradeKey: tradeKey),
);

class PendingTab extends StatefulWidget {
  const PendingTab({super.key});

  @override
  State<PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<PendingTab>
    with SingleTickerProviderStateMixin {
  late TradeBloc _tradeBloc;

  Set<int> loadingIndices = {}; // To track loading state of buttons

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tradeBloc = TradeBloc();

    _tradeBloc.add(PendingStockTradeEvent());

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kWhiteColor,
        // appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: BlocBuilder(
            bloc: _tradeBloc,
            builder: (context, state) {
              if (state is TradeLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PendingTradeLoadedSuccessState) {
                final pendingTradeEntity = state.pendingTradeEntity;
                return pendingTradeEntity.status == 1
                    ? ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 16.w),
                        itemCount: pendingTradeEntity.record!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (pendingTradeEntity
                                      .record![index]
                                      .dataRelatedTo ==
                                  'MCX') {
                                context.pushNamed(
                                  MCXSymbolRecordPage.routeName,
                                  extra: MCXSymbolParams(
                                    symbol: pendingTradeEntity
                                        .record![index]
                                        .symbolName
                                        .toString(),
                                    index: index,
                                    symbolKey: pendingTradeEntity
                                        .record![index]
                                        .symbolKey
                                        .toString(),
                                  ),
                                );
                              } else if (pendingTradeEntity
                                      .record![index]
                                      .dataRelatedTo ==
                                  'NFO') {
                                context.pushNamed(
                                  NseFutureSymbolPage.routeName,
                                  extra: SymbolScreenParams(
                                    symbol: pendingTradeEntity
                                        .record![index]
                                        .symbolName
                                        .toString(),
                                    index: index,
                                    symbolKey: pendingTradeEntity
                                        .record![index]
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        // margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          // vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.red),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '${pendingTradeEntity.record![index].orderMethod} X ${pendingTradeEntity.record![index].availableQty}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'JetBrainsMono',
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        // margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          // vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.red),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          pendingTradeEntity
                                              .record![index]
                                              .stockPrice
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'JetBrainsMono',
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                            1.8,
                                        child: Text(
                                          pendingTradeEntity
                                              .record![index]
                                              .symbolName
                                              .toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'JetBrainsMono',
                                            fontSize: 15,
                                            color: kGoldenBraunColor,
                                          ),
                                        ),
                                      ),
                                      cancelOrderBtn(
                                        tradeKey: pendingTradeEntity
                                            .record![index]
                                            .tradeKey
                                            .toString(),
                                        index: index,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        (() {
                                          if (pendingTradeEntity
                                                  .record![index]
                                                  .tradeMethod ==
                                              1) {
                                            return 'Sold by Trader';
                                          } else {
                                            return 'Order by Trader';
                                          }
                                        })(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'JetBrainsMono',
                                          color: kGoldenBraunColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${pendingTradeEntity.record![index].currentDate} & ${pendingTradeEntity.record![index].time}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'JetBrainsMono',
                                          color: kGoldenBraunColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          pendingTradeEntity.message.toString(),
                          style: const TextStyle(
                            color: zBlack,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
              } else if (state is ActiveTradeFailedErrorState) {
                return Center(child: Text(state.error));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }

  cancelOrderBtn({required String tradeKey, required int index}) {
    return Consumer(
      builder: (context, ref, child) {
        // final cancelOrderAsyncValue = ref.watch(cancelTradeProvider(tradeKey));
        final isLoading = loadingIndices.contains(index);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: isLoading
                ? BorderRadius.circular(17.r)
                : BorderRadius.circular(12.r),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () async {
                    if (!isLoading) {
                      try {
                        setState(() => loadingIndices.add(index));

                        // Invalidate the provider to force a refresh
                        ref.invalidate(cancelTradeProvider(tradeKey));

                        final result = await ref.read(
                          cancelTradeProvider(tradeKey).future,
                        );

                        if (result.status == 1) {
                          successToastMsg(context, result.message.toString());

                          // Refresh the pending trades list
                          _tradeBloc.add(PendingStockTradeEvent());
                        } else {
                          failedToast(context, result.message.toString());
                        }
                      } catch (e) {
                        failedToast(context, 'Failed to cancel order: $e');
                      } finally {
                        if (mounted) {
                          setState(() => loadingIndices.remove(index));
                        }
                      }
                    }
                  },
                  child: const Text(
                    'CANCEL ORDER',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
