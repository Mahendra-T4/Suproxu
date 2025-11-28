import 'package:flutter/material.dart';

class SaleBuy {
  final String symbolKey;
  final String categoryName;
  final String stockPrice;
  final String stockQty;
  final BuildContext context;

  SaleBuy(
      {required this.symbolKey,
      required this.categoryName,
      required this.stockPrice,
      required this.stockQty,
      
      required this.context});
}
