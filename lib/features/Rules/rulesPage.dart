import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:suproxu/features/Rules/provider/rules_provider.dart';

class Rulespage extends ConsumerStatefulWidget {
  const Rulespage({super.key});
  

  @override
  ConsumerState<Rulespage> createState() => _RulespageState();
}

class _RulespageState extends ConsumerState<Rulespage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rulesProvider);
    return Scaffold(
      backgroundColor: Colors.black, // Background color
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.rulesModel.pageTitle ?? 'No Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.rulesModel.pageDescription ?? 'No Description',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          }
        },
      ),
      // body: SafeArea(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       // Logo and Header
      //       Padding(
      //         padding: const EdgeInsets.symmetric(vertical: 40.0),
      //         child: Column(
      //           children: [
      //             const SizedBox(height: 10),
      //             const Padding(
      //               padding: EdgeInsets.only(left: 20, right: 20),
      //               child: Text(
      //                 "Trade Responsibly in Futures & Options",
      //                 textAlign: TextAlign.center,
      //                 style: TextStyle(
      //                   color: Colors.orange,
      //                   fontSize: 16,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(height: 40),
      //             Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 54),
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   const Text(
      //                     "Risk Disclosures on Derivatives:",
      //                     style: TextStyle(
      //                       color: Colors.white,
      //                       fontSize: 16,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                   const SizedBox(height: 10),
      //                   Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       buildBulletPoint(
      //                         "There are many variations of passages of Lorem Ipsum available",
      //                       ),
      //                       buildBulletPoint(
      //                         "but the majority have suffered alteration in some form, by injected",
      //                       ),
      //                       buildBulletPoint(
      //                         "If you are going to use a passage of Lorem Ipsum, you need to be.",
      //                       ),
      //                       buildBulletPoint(
      //                         "sure there isn't anything embarrassing hidden in the middle of text",
      //                       ),
      //                     ],
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             const SizedBox(height: 50),
      //             Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 60.0),
      //               child: Column(
      //                 children: [
      //                   ElevatedButton(
      //                     style: ElevatedButton.styleFrom(
      //                       backgroundColor: Colors.green,
      //                       shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(50),
      //                       ),
      //                       minimumSize: const Size(
      //                         double.infinity,
      //                         50,
      //                       ), // Full-width button
      //                     ),
      //                     onPressed: () {
      //                       // Navigator.pushReplacement(
      //                       //   context,
      //                       //   MaterialPageRoute(
      //                       //       builder: (context) => const GlobalNavBar()),
      //                       // );
      //                     },
      //                     child: const Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         Text(
      //                           "Accept all Rules",
      //                           style: TextStyle(
      //                             color: Colors.white,
      //                             fontSize: 16,
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                         SizedBox(width: 10),
      //                         Icon(Icons.arrow_forward, color: Colors.white),
      //                       ],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
    );
  }

  Widget buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.white, fontSize: 22)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
