import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suproxu/features/navbar/home/model/buy_sale_entity.dart';
import 'package:suproxu/features/navbar/home/model/sale_buy_param_model.dart';
import 'package:suproxu/features/navbar/home/repository/buy_sale_repo.dart';

final buyStockProvider = FutureProvider.family<BuySaleEntity, SaleBuy>(
    (ref, SaleBuy) async => StockBuyAndSaleRepository.buyStock(
        symbolKey: SaleBuy.symbolKey.toString(),
        categoryName: SaleBuy.categoryName.toString(),
        stockPrice: SaleBuy.stockPrice.toString(),
        stockQty: SaleBuy.stockQty.toString(),
        context: SaleBuy.context));
