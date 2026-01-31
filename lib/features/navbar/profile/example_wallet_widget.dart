// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/features/navbar/Portfolio/provider/active_port_provider.dart';

class WalletWidget extends StatefulWidget {
  final double screenWidth;
  const WalletWidget({
    Key? key,
    required this.screenWidth,
  }) : super(key: key);

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef ref, child) {
        // Watch the stream provider
        final walletAsync = ref.watch(activePortfolioProvider);

        // Handle the different states using when
        return walletAsync.when(
          data: (wallet) {
            // When data is available
            return modernStatCard2(
              icon: Icons.show_chart_rounded,
              label: "Profit & Loss",
              value: wallet.status == 1
                  ? wallet.activeStatics!.activeProfitLoss.toString()
                  : '0.0',
              color: Colors.purpleAccent,
              screenWidth: widget.screenWidth,
            );
          },
          loading: () {
            // While loading
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stack) {
            // On error
            return Center(
              child: Text('Error: $error'),
            );
          },
        );
      },
    );
  }

  Widget modernStatCard2({
    required IconData icon,
    required String label,
    required dynamic value,
    required Color color,
    required double screenWidth,
  }) {
    return Container(
      // width: screenWidth * 0.25,
      padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.03, horizontal: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: color.withOpacity(0.18),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: screenWidth * 0.08),
          SizedBox(height: screenWidth * 0.01),
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: screenWidth * 0.045,
               fontFamily: FontFamily.globalFontFamily,
              fontWeight: FontWeight.bold,
              // fontFamily: 'JetBrainsMono',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenWidth * 0.005),
          Text(
            label,
            textAlign: TextAlign.center,
          ).textStyleH2W(),
        ],
      ),
    );
  }
}
