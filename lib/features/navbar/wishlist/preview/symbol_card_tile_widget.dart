import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/core/constants/color.dart';

class SymbolCardTileWidget extends StatefulWidget {
  SymbolCardTileWidget({super.key});
  static const String routeName = '/symbol-card-tile';

  @override
  State<SymbolCardTileWidget> createState() => _SymbolCardTileWidgetState();
}

class _SymbolCardTileWidgetState extends State<SymbolCardTileWidget> {
  bool isChecked = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Symbol Card Tile')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      // flex: 2,
                      child: Text(
                        'Gold',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        spacing: 15,
                        children: [
                          Text(
                            '₹ 4,500',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '500',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('2026-01-12 12:00:00'),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isChecked = !isChecked;
                        });
                      },
                      icon: isChecked
                          ? Image.asset(
                              Assets.assetsImagesCheckbox,
                              width: 26,
                              height: 26,
                            )
                          : Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color: Colors.lightGreen.withOpacity(0.5),
                                border: Border.all(color: greyColor, width: 2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                    ),
                  ],
                ),
                Divider(color: greyColor, thickness: 1, height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
