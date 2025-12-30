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
