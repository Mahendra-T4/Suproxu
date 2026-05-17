import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suproxu/features/Rules/model/rules_model.dart';
import 'package:suproxu/features/Rules/repositories/rules_repo.dart';

final rulesProvider = StateNotifierProvider<RulesNotifier, RulesState>(
  (ref) => RulesNotifier(),
);

class RulesState {
  final RulesModel rulesModel;
  final bool isLoading;
  final String? errorMessage;

  RulesState({
    required this.rulesModel,
    this.isLoading = false,
    this.errorMessage,
  });

  RulesState copyWith({
    RulesModel? rulesModel,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RulesState(
      rulesModel: rulesModel ?? this.rulesModel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RulesNotifier extends StateNotifier<RulesState> {
  RulesNotifier()
    : super(
        RulesState(
          rulesModel: RulesModel(),
          isLoading: false,
          errorMessage: null,
        ),
      );
  // RulesNotifier(super.state);

  Future<void> loadRules() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final rules = await RulesRepository().fetchRules();
      state = state.copyWith(rulesModel: rules, isLoading: false);
    } catch (e) {
      print(e);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
