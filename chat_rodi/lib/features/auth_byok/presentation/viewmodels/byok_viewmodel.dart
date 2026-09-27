import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/byok_storage_service.dart';

/// État immuable de l'écran de configuration de la clé BYOK.
///
/// La clé elle-même n'est pas incluse dans l'état pour éviter de dupliquer le
/// secret en mémoire au-delà du champ de saisie et du stockage sécurisé.
class ByokState {
  /// Crée un état avec des valeurs initiales adaptées à l'écran.
  const ByokState({
    this.isLoading = false,
    this.isKeySaved = false,
    this.errorMessage,
    this.isObscured = true,
  });

  /// Signale une lecture ou écriture actuellement en cours.
  final bool isLoading;

  /// Indique si une clé existe déjà dans le stockage sécurisé.
  final bool isKeySaved;

  /// Message d'erreur destiné à être présenté à la personne.
  final String? errorMessage;

  /// Indique si le texte de la clé doit rester masqué à l'écran.
  final bool isObscured;

  /// Produit un nouvel état en conservant les propriétés non modifiées.
  ByokState copyWith({
    bool? isLoading,
    bool? isKeySaved,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isObscured,
  }) {
    return ByokState(
      isLoading: isLoading ?? this.isLoading,
      isKeySaved: isKeySaved ?? this.isKeySaved,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isObscured: isObscured ?? this.isObscured,
    );
  }
}

/// Gère la lecture et l'enregistrement de la clé BYOK pour l'interface.
class ByokViewModel extends StateNotifier<ByokState> {
  /// Le service injecté utilise le stockage sécurisé de la plateforme.
  ByokViewModel(this._storageService) : super(const ByokState());

  final ByokStorageService _storageService;

  /// Vérifie de manière asynchrone si une clé est déjà enregistrée.
  Future<void> checkExistingKey() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final exists = await _storageService.hasApiKey();
      state = state.copyWith(isLoading: false, isKeySaved: exists);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de vérifier la clé enregistrée.',
      );
    }
  }

  /// Enregistre une clé non vide sans la conserver dans l'état Riverpod.
  Future<void> saveKey(String key) async {
    final normalizedKey = key.trim();
    if (normalizedKey.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isKeySaved: false,
        errorMessage: 'Veuillez saisir votre clé API.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _storageService.saveApiKey(normalizedKey);
      // Le succès reste sur l'écran de confirmation ; la navigation est
      // déclenchée par le bouton de l'écran, pas par le ViewModel.
      state = state.copyWith(isLoading: false, isKeySaved: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'La clé API n’a pas pu être enregistrée.',
      );
    }
  }

  /// Bascule entre l'affichage masqué et visible du champ de saisie.
  void toggleObscure() {
    state = state.copyWith(isObscured: !state.isObscured);
  }
}

/// Fournisseur Riverpod classique du contrôleur et de son état.
final byokViewModelProvider =
    StateNotifierProvider<ByokViewModel, ByokState>((ref) {
  return ByokViewModel(ref.watch(byokStorageServiceProvider));
});
