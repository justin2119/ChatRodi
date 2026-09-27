import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/byok_viewmodel.dart';

/// Écran permettant de saisir et d'enregistrer une clé API RodiumAi.
///
/// L'interface emploie une palette sombre, avec l'émeraude comme couleur
/// d'action. La clé est conservée dans le stockage sécurisé par le ViewModel.
class ByokScreen extends ConsumerStatefulWidget {
  /// Crée l'écran BYOK.
  const ByokScreen({super.key});

  @override
  ConsumerState<ByokScreen> createState() => _ByokScreenState();
}

class _ByokScreenState extends ConsumerState<ByokScreen> {
  /// Couleur de fond profonde utilisée sur l'écran.
  static const Color _deepSlate = Color(0xFF0F172A);

  /// Couleur émeraude de RodiumAi pour les actions importantes.
  static const Color _emerald = Color(0xFF00C9A7);

  /// Couleur des surfaces et champs sur le fond sombre.
  static const Color _surface = Color(0xFF1E293B);

  /// Couleur de texte principale offrant un contraste élevé.
  static const Color _textPrimary = Color(0xFFF8FAFC);

  /// Contrôleur local du champ ; le ViewModel ne stocke jamais le secret.
  final TextEditingController _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Lance la vérification dès l'ouverture afin d'actualiser l'indicateur.
    Future<void>.microtask(
      () => ref.read(byokViewModelProvider.notifier).checkExistingKey(),
    );
  }

  @override
  void dispose() {
    // Libère le contrôleur lorsque l'écran quitte l'arbre des widgets.
    _keyController.dispose();
    super.dispose();
  }

  /// Colle le texte du presse-papiers dans le champ de clé.
  Future<void> _pasteKey() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final value = clipboard?.text;
    if (value == null || !mounted) return;
    _keyController
      ..text = value.trim()
      ..selection = TextSelection.collapsed(offset: value.trim().length);
  }

  /// Enregistre la clé puis ouvre la conversation si l'opération réussit.
  Future<void> _saveAndContinue() async {
    await ref.read(byokViewModelProvider.notifier).saveKey(_keyController.text);
    if (!mounted) return;

    final state = ref.read(byokViewModelProvider);
    if (state.isKeySaved && state.errorMessage == null) {
      // L'application utilise GoRouter ; la route de conversation est /chat.
      context.go('/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(byokViewModelProvider);

    return Scaffold(
      backgroundColor: _deepSlate,
      appBar: AppBar(
        // Une forme explicitement rectangulaire garantit une barre carrée.
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: _deepSlate,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: const Text(
          'RodiumAi',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icône décorative qui souligne le caractère privé de la clé.
                  const Icon(Icons.key_rounded, color: _emerald, size: 48),
                  const SizedBox(height: 24),
                  const Text(
                    'Votre clé, votre contrôle.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ajoutez votre clé API RodiumAi pour commencer à discuter. '
                    'Elle est stockée de façon sécurisée sur cet appareil.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFCBD5E1), height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  // Le contour et le fond distinguent visuellement le champ.
                  TextField(
                    controller: _keyController,
                    obscureText: state.isObscured,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: const TextStyle(color: _textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Clé API',
                      hintText: 'Collez votre clé API ici',
                      labelStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: _surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _emerald, width: 1.5),
                      ),
                      // Les deux actions restent accessibles au bord du champ.
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Coller',
                            onPressed: _pasteKey,
                            icon: const Icon(Icons.content_paste_rounded),
                            color: const Color(0xFFCBD5E1),
                          ),
                          IconButton(
                            tooltip: state.isObscured
                                ? 'Afficher la clé'
                                : 'Masquer la clé',
                            onPressed: () => ref
                                .read(byokViewModelProvider.notifier)
                                .toggleObscure(),
                            icon: Icon(state.isObscured
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded),
                            color: const Color(0xFFCBD5E1),
                          ),
                        ],
                      ),
                    ),
                    onSubmitted: (_) => _saveAndContinue(),
                  ),
                  // Les erreurs ne contiennent jamais la valeur du secret.
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Color(0xFFFCA5A5)),
                    ),
                  ],
                  if (state.isKeySaved && state.errorMessage == null) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Une clé est déjà enregistrée sur cet appareil.',
                      style: TextStyle(color: _emerald),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // L'indicateur empêche les doubles soumissions pendant
                  // l'écriture asynchrone dans le stockage sécurisé.
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: state.isLoading ? null : _saveAndContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: _emerald,
                        foregroundColor: _deepSlate,
                        disabledBackgroundColor: _emerald.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: _deepSlate,
                              ),
                            )
                          : const Text(
                              'Valider et continuer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Votre clé n’est jamais affichée dans les journaux de '
                    'l’application.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
