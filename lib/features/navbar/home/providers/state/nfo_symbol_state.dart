import 'package:suproxu/features/navbar/home/model/get_stock_record_entity.dart';

class NfoSymbolStatus {
  bool isLoading;
  String? errorMessage;
  GetStockRecordEntity? record;
  bool isConnected;

  NfoSymbolStatus({
    this.isLoading = false,
    this.errorMessage,
    this.record,
    this.isConnected = false,
  });

  NfoSymbolStatus copyWith({
    bool? isLoading,
    String? errorMessage,
    GetStockRecordEntity? record,
    bool? isConnected,
  }) {
    return NfoSymbolStatus(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      record: record ?? this.record,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
