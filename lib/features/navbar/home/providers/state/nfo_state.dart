 import 'package:suproxu/features/navbar/home/model/nfo_entity.dart';

class NFOState {
  final bool isLoading;
  final String? errorMessage;
  final NFODataEntity nfoData;
  final bool isConnected;

  NFOState(
      {this.isLoading = true,
      this.errorMessage,
      required this.nfoData,
      this.isConnected = false});

  NFOState copyWith({
    final bool? isLoading,
    final String? errorMessage,
    final NFODataEntity? nfoData,
    final bool? isConnected,
  }) =>
      NFOState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        nfoData: nfoData ?? this.nfoData,
        isConnected: isConnected ?? this.isConnected,
      );
}
