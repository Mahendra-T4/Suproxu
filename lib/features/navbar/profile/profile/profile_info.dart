import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});
  static const String routeName = '/profile-info';

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  late ProfileBloc _profileBloc;
  @override
  void initState() {
    _profileBloc = ProfileBloc();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    _profileBloc.add(FetchUserProfileInfoEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: zBlack,
      appBar: customAppBarWithTitle(
        context: context,
        title: 'Profile Info',
        isShowNotify: true,
      ),
      body: BlocBuilder(
        bloc: _profileBloc,
        builder: (context, state) {
          switch (state.runtimeType) {
            case ProfileLoadingState:
              return const Center(child: CircularProgressIndicator());
            case FetchUserProfileInfoSuccessStatus:
              final successState =
                  (state as FetchUserProfileInfoSuccessStatus).profileInfoModel;
              return successState.status == 1
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              // margin: const EdgeInsets.all(10.0),
                              padding: const EdgeInsets.all(10.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // spacing: 8,
                                children: [
                                  const Text(
                                    'NSE Trade Enabled',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Brokerage:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: kGoldenBraunColor,
                                        ),
                                      ),
                                      Text(
                                        successState.nseDetails!.nseBrokerage
                                            .toString(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Divider(color: kGoldenBraunColor),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Margin Intraday:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: kGoldenBraunColor,
                                        ),
                                      ),
                                      Text(
                                        successState.nseDetails!.nseInterday
                                            .toString(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Divider(color: kGoldenBraunColor),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Margin Holding:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: kGoldenBraunColor,
                                        ),
                                      ),
                                      Text(
                                        successState.nseDetails!.nseHolding
                                            .toString(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Divider(color: kGoldenBraunColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              // margin: const EdgeInsets.all(10.0),
                              padding: const EdgeInsets.all(10.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // spacing: 8,
                                children: [
                                  const Text(
                                    'MCX Trade Enabled',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // MCX Brokerage
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Brokerage:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: kGoldenBraunColor,
                                        ),
                                      ),
                                      Text(
                                        state
                                            .profileJsonData!['mcxDetails']['mcxBrokerage']
                                            .toString(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Divider(color: kGoldenBraunColor),
                                    ],
                                  ),
                                  // Margin Holdings
                                  Text(
                                    'Margin Intraday:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kGoldenBraunColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width,
                                    child: Text(state.marginUsed.toString()),
                                  ),

                                  Divider(color: kGoldenBraunColor),

                                  Text(
                                    'Margin Holding:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kGoldenBraunColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width,
                                    child: Text(state.marginHolding.toString()),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        successState.message.toString(),
                        style:  TextStyle(
                          color: kWhiteColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
            case FetchUserProfileInfoFailedStatus:
              final error = (state as FetchUserProfileInfoFailedStatus).error;
              return Text(error);

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
