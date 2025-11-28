import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';

class MCXSymbolWebSocketState {
  final bool isLoading;
  final String? errorMessage;
  final GetStockRecordEntity? data;
  final bool isConnected;

  const MCXSymbolWebSocketState({
    this.isLoading = true,
    this.errorMessage,
    this.data,
    this.isConnected = false,
  });
}
