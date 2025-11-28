import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static const String routeName = '/notification-screen';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    _profileBloc.add(FetchingNotificationFromServerEvent());
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
    _profileBloc.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: InternetConnectionService().connectionStream,
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return NoInternetConnection(); // Show your offline UI
          }
          return Container(
            color: greyColor,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: zBlack, // Dark premium background
                appBar: customAppBarWithTitle(
                    context: context,
                    title: 'Notification',
                    isShowNotify: false),
                body: BlocConsumer(
                    bloc: _profileBloc,
                    listener: (context, state) {
                      if (state is ProfileFailedErrorStateForNotification) {
                        final error = state.error;
                        failedToast(context, error.toString());
                      }
                    },
                    builder: (_, state) {
                      switch (state.runtimeType) {
                        case const (ProfileLoadingState):
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        case const (ProfileLoadedSuccessStateForNotification):
                          final successState =
                              state as ProfileLoadedSuccessStateForNotification;
                          return successState.notificationEntity.notification !=
                                  null
                              ? FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: successState.notificationEntity
                                        .notification!.length,
                                    itemBuilder: (context, index) {
                                      // final notification = notifications[index];
                                      return InkWell(
                                        onTap: () {
                                          // Navigator.pushNamed(context,
                                          //     NotificationDetailsView.routeName,
                                          //     arguments: NotifyParams(
                                          //         title: 'Notification',
                                          //         contents: successState
                                          //             .notificationEntity
                                          //             .notification!
                                          //             .first
                                          //             .notificationMsg
                                          //             .toString()));
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: kWhiteColor),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Leading Icon
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent
                                                      .withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.notifications,
                                                  color: Colors.blueAccent,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Notification Content
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      successState
                                                          .notificationEntity
                                                          .notification![index]
                                                          .notificationMsg
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        color: zBlack,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      successState
                                                          .notificationEntity
                                                          .notification![index]
                                                          .notificationDate
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: zBlack,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    successState.notificationEntity.message
                                        .toString(),
                                    style: const TextStyle(
                                      color: zBlack,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                        case const (ProfileFailedErrorStateForNotification):
                          return const SizedBox.shrink();
                        default:
                          return const Center(
                            child: Text("State not found"),
                          );
                      }
                    }),
              ),
            ),
          );
        });
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
