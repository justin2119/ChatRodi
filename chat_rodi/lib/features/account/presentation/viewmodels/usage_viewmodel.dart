import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModelUsage {
  const ModelUsage({required this.name, required this.tokens, required this.color});

  final String name;
  final int tokens;
  final int color;
}

class UsageState {
  const UsageState({
    this.isLoading = false,
    this.tokensUsed = 0,
    this.quota = 100000,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.imageTokens = 0,
    this.textTokens = 0,
    this.dailyTokens = 0,
    this.weeklyTokens = 0,
    this.models = const [],
  });

  final bool isLoading;
  final int tokensUsed;
  final int quota;
  final int promptTokens;
  final int completionTokens;
  final int imageTokens;
  final int textTokens;
  final int dailyTokens;
  final int weeklyTokens;
  final List<ModelUsage> models;

  double get quotaProgress => quota == 0 ? 0 : (tokensUsed / quota).clamp(0.0, 1.0);
}

class UsageViewModel extends StateNotifier<UsageState> {
  UsageViewModel() : super(const UsageState()) {
    fetchUsage();
  }

  Future<void> fetchUsage() async {
    state = const UsageState(isLoading: true);
    // Placeholder usage until a usage endpoint is configured.
    state = UsageState(
      tokensUsed: 42850,
      quota: 100000,
      promptTokens: 28100,
      completionTokens: 14750,
      imageTokens: 8200,
      textTokens: 34650,
      dailyTokens: 6840,
      weeklyTokens: 28460,
      models: const [
        ModelUsage(name: 'GPT-4o', tokens: 19200, color: 0xFF6750A4),
        ModelUsage(name: 'Claude 3.5 Sonnet', tokens: 14650, color: 0xFF00897B),
        ModelUsage(name: 'Gemini 1.5 Pro', tokens: 9000, color: 0xFFEF6C00),
      ],
    );
  }
}

final usageViewModelProvider = StateNotifierProvider<UsageViewModel, UsageState>(
  (ref) => UsageViewModel(),
);
