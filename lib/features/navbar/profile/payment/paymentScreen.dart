import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';
import 'package:suproxu/features/navbar/profile/diposit/depositeScreen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  static const String routeName = '/payment-screen';

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late ProfileBloc _profileBloc;
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime toDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? payStatus;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    _profileBloc.add(LoadTransactionRequestListEvent());
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

  Future<void> pickFromDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != fromDate) {
      setState(() {
        fromDate = selectedDate!;
      });
    }
  }

  Future<void> pickToDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate,
      lastDate: DateTime(2100),
    );

    if (selectedDate != toDate) {
      setState(() {
        toDate = selectedDate!;
      });
    }
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
              backgroundColor: kWhiteColor,
              appBar: customAppBarWithTitle(
                context: context,
                title: 'Payment',
                isShowNotify: true,
              ),
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Expanded(
                      child: BlocBuilder(
                        bloc: _profileBloc,
                        builder: (_, state) {
                          switch (state.runtimeType) {
                            case const (ProfileLoadingState):
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            case const (TransactionListSuccessfulLoadedState):
                              final snapshot =
                                  state as TransactionListSuccessfulLoadedState;
                              return snapshot.transRequestListEntity.status == 1
                                  ? ListView.builder(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        right: 10,
                                      ),
                                      itemCount: snapshot
                                          .transRequestListEntity
                                          .record!
                                          .length,
                                      itemBuilder: (context, index) {
                                        final transaction = snapshot
                                            .transRequestListEntity
                                            .record![index];
                                        return TransactionItem(
                                          transactionId: transaction.utrNumber
                                              .toString(),
                                          date: transaction.transactionDate
                                              .toString(),
                                          status: transaction.transactionStatus
                                              .toString(),
                                          amount: transaction.transactionAmount!
                                              .toDouble(),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                        snapshot.transRequestListEntity.message
                                            .toString(),
                                        style: TextStyle(
                                          color: zBlack,
                                          fontFamily:
                                              FontFamily.globalFontFamily,
                                        ),
                                      ),
                                    );
                            case const (TransactionListFailedErrorState):
                              return const SizedBox.shrink();
                            default:
                              return const Center(
                                child: Text(
                                  'State Not found',
                                  style: TextStyle(
                                    fontFamily: FontFamily.globalFontFamily,
                                  ),
                                ),
                              );
                          }
                        },
                      ),
                    ),

                    // Footer Buttons
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pushNamed(DepositScreen.routeName);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const DepositScreen(),
                          //   ),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGoldenBraunColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: const Text("DEPOSIT").textStyleH1W(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String transactionId;
  final String date;
  final String status;
  final double amount;

  const TransactionItem({
    super.key,
    required this.transactionId,
    required this.date,
    required this.status,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Txn #",
                style: TextStyle(
                  fontSize: 14,
                  color: zBlack,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.globalFontFamily,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transactionId,
                style: const TextStyle(
                  fontSize: 16,
                  color: zBlack,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontFamily.globalFontFamily,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Status",
                style: TextStyle(
                  fontSize: 14,
                  color: zBlack,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.globalFontFamily,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                StringExtension(status).capitalize(),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: FontFamily.globalFontFamily,
                  color: status == "pending"
                      ? Colors.orangeAccent
                      : Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Right Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Date and Time",
                style: TextStyle(
                  fontSize: 14,
                  color: zBlack,
                  fontFamily: FontFamily.globalFontFamily,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  color: zBlack,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontFamily.globalFontFamily,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Amount",
                style: TextStyle(
                  fontSize: 14,
                  color: zBlack,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.globalFontFamily,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "₹$amount",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontFamily.globalFontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
