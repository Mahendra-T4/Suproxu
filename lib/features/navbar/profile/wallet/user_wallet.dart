import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/service/Auth/user_validation.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';
import 'dart:async';

class UserWalletPage extends StatefulWidget {
  const UserWalletPage({super.key});
  static const String routeName = '/user-wallet';

  @override
  State<UserWalletPage> createState() => _UserWalletPageState();
}

class _UserWalletPageState extends State<UserWalletPage> {
  late ProfileBloc _profileBloc;
  Timer? _validationTimer;
  StreamSubscription<void>? _logoutSub;
  @override
  void initState() {
    _profileBloc = ProfileBloc();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    _profileBloc.add(FetchingBalanceLogEvent());

    // Start periodic validation timer (every 10 seconds)
    _validationTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!mounted) return;
      try {
        await AuthService().validateAndLogout(context);
      } catch (e) {
        debugPrint('UserWallet auth validation error: $e');
      }
    });
    // Subscribe to global logout events to cleanup immediately
    _logoutSub = AuthService().onLogout.listen((_) {
      _validationTimer?.cancel();
      debugPrint('UserWallet: handled global logout cleanup');
    });

    super.initState();
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    _logoutSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: customAppBarWithTitle(
        context: context,
        title: 'User Wallet',
        isShowNotify: true,
      ),
      body: BlocBuilder(
        bloc: _profileBloc,
        builder: (context, state) {
          if (state is ProfileLoadingState) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (state is FetchingBalanceLogSuccessStatus) {
            return state.balanceLogModel.status == 1
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.balanceLogModel.record?.length,
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
                              state
                                  .balanceLogModel
                                  .record![index]
                                  .transactionDate
                                  .toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              state
                                  .balanceLogModel
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
                      state.balanceLogModel.message.toString(),
                      style: TextStyle(fontSize: 16, color: zBlack),
                    ),
                  );
          } else if (state is FetchingBalanceLogFailedStatus) {
            return Center(child: Text(state.error));
          }
          return const SizedBox.shrink(); // Default case
        },
      ),
    );
  }
}
