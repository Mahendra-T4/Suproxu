import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';
import 'package:suproxu/features/navbar/profile/model/withdraw_req_model.dart';
import 'package:suproxu/features/navbar/profile/repository/withdraw_repo.dart';

final withRequestProvider = FutureProvider.family<WithdrawRequest, String>(
  (ref, amount) async =>
      WithdrawRepository.requestWithdraw(amount: amount.toString()),
);

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});
  static const String routeName = '/withdraw';

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  late ProfileBloc _profileBloc;
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    _profileBloc = ProfileBloc();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    _profileBloc.add(FetchingWithdrawListEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: customAppBarWithTitle(
        context: context,
        title: 'Withdraw',
        isShowNotify: true,
      ),
      body: BlocBuilder(
        bloc: _profileBloc,
        builder: (context, state) {
          if (state is ProfileLoadingState) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (state is FetchingWithdrawListSuccessStatus) {
            return state.withdrawList.status == 1
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.withdrawList.record!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.withdrawList.record![index].transactionDate
                                  .toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              state
                                  .withdrawList
                                  .record![index]
                                  .transactionAmount
                                  .toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kGoldenBraunColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      state.withdrawList.message.toString(),
                      style: TextStyle(
                        color: zBlack,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
          } else if (state is FetchingWithdrawListFailedStatus) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else {
            return const Center(child: Text('No transactions found'));
          }
        },
      ),
      // Optional: Add a FloatingActionButton for adding new transactions
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWithdrawDialog(context),
        backgroundColor: kGoldenBraunColor,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Withdraw Request",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter withdraw amount',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: kGoldenBraunColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    withdrawRequestButton(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget withdrawRequestButton() {
    return Consumer(
      builder: (context, ref, child) {
        return InkWell(
          onTap: () async {
            try {
              final withdrawRequest = await ref.read(
                withRequestProvider(amountController.text).future,
              );
              if (withdrawRequest.status == 1) {
                _profileBloc.add(FetchingWithdrawListEvent());
                successToastMsg(context, withdrawRequest.message.toString());
                amountController.clear();
              } else {
                failedToast(context, withdrawRequest.message.toString());
              }
            } catch (error) {
              if (mounted) {
                failedToast(context, error.toString());
              }
            }
            GoRouter.of(context).pop();
          },
          child: Container(
            height: 50,
            width: 120,
            decoration: BoxDecoration(
              color: kGoldenBraunColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Request',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
