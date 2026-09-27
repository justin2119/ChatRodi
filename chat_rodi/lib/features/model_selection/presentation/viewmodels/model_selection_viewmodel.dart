import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/model_local_data.dart';
import '../../domain/models/ai_model.dart';

/// État de recherche, filtre et sélection dans le catalogue de modèles.
class ModelSelectionState {
  const ModelSelectionState({
    this.searchQuery = '',
    this.selectedFilter = 'Tous',
    this.selectedModelId = 'rodium-smart',
  });

  final String searchQuery;
  final String selectedFilter;
  final String selectedModelId;

  List<AiModel> get filteredModels {
    final query = searchQuery.trim().toLowerCase();
    return ModelLocalData.models.where((model) {
      final matchesQuery = query.isEmpty ||
          model.name.toLowerCase().contains(query) ||
          model.provider.toLowerCase().contains(query) ||
          model.description.toLowerCase().contains(query);
      final matchesFilter = selectedFilter == 'Tous' ||
          model.capabilities.contains(selectedFilter);
      return matchesQuery && matchesFilter;
    }).toList(growable: false);
  }

  ModelSelectionState copyWith({
    String? searchQuery,
    String? selectedFilter,
    String? selectedModelId,
  }) => ModelSelectionState(
    searchQuery: searchQuery ?? this.searchQuery,
    selectedFilter: selectedFilter ?? this.selectedFilter,
    selectedModelId: selectedModelId ?? this.selectedModelId,
  );
}

/// Gère les interactions de sélection des modèles sans génération de code.
class ModelSelectionViewModel extends StateNotifier<ModelSelectionState> {
  ModelSelectionViewModel() : super(const ModelSelectionState());

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void setFilter(String filter) =>
      state = state.copyWith(selectedFilter: filter);

  void selectModel(String modelId) =>
      state = state.copyWith(selectedModelId: modelId);
}

final modelSelectionViewModelProvider =
    StateNotifierProvider<ModelSelectionViewModel, ModelSelectionState>(
  (ref) => ModelSelectionViewModel(),
);
