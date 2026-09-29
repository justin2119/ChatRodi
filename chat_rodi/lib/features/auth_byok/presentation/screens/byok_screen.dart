import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/byok_viewmodel.dart';

/// Ecran de configuration initiale de la cle API RodiumAi.
///
/// La cle reste dans le champ de saisie puis dans le stockage securise ; elle
/// n'est jamais copiee dans l'etat Riverpod.
class ByokScreen extends ConsumerStatefulWidget {
  /// Cree l'ecran BYOK.
  const ByokScreen({super.key});

  @override
  ConsumerState<ByokScreen> createState() => _ByokScreenState();
}

class _ByokScreenState extends ConsumerState<ByokScreen> {
  /// Palette sombre officielle RodiumAi.
  static const Color _background = Color(0xFF0D0D0D);
  static const Color _primary = Color(0xFFFF6600);
  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Colors.white70;

  /// Controleur local du champ, pour ne pas exposer le secret dans le provider.
  final TextEditingController _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Recherche une eventuelle cle existante des l'ouverture de l'ecran.
    Future<void>.microtask(
      () => ref.read(byokViewModelProvider.notifier).checkExistingKey(),
    );
  }

  @override
  void dispose() {
    // Libere les ressources associees au champ.
    _keyController.dispose();
    super.dispose();
  }

  /// Colle le contenu du presse-papiers dans le champ.
  Future<void> _pasteKey() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final value = clipboard?.text;
    if (value == null || !mounted) return;
    final key = value.trim();
    _keyController
      ..text = key
      ..selection = TextSelection.collapsed(offset: key.length);
  }

  /// Demande au ViewModel d'enregistrer la cle saisie.
  Future<void> _saveKey() async {
    await ref.read(byokViewModelProvider.notifier).saveKey(_keyController.text);
  }

  /// Affiche des conseils sans quitter l'application.
  void _showKeyHelp() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'O\u00f9 trouver ma cl\u00e9 API ?',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Connectez-vous \u00e0 votre compte RodiumAi, ouvrez la section de gestion des cl\u00e9s API, puis copiez une cl\u00e9 active. Ne partagez jamais cette cl\u00e9 avec qui que ce soit.',
                style: TextStyle(color: _textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un bouton principal commun aux deux etats.
  Widget _gradientButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withValues(alpha: 0.5),
          foregroundColor: _textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _textPrimary,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  /// Presente l'ecran d'enregistrement ou l'ecran de succes.
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(byokViewModelProvider);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: _background,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: const Text(
          'Configuration initiale',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: state.isKeySaved && state.errorMessage == null
                  ? _buildSuccess()
                  : _buildEntry(state),
            ),
          ),
        ),
      ),
    );
  }

  /// Etat initial : saisie, aide, erreurs et note de securite.
  Widget _buildEntry(ByokState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline, color: _primary, size: 38),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Ajoutez votre cl\u00e9 API RodiumAi',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pour acc\u00e9der aux mod\u00e8les d\u2019IA et utiliser toutes les fonctionnalit\u00e9s, veuillez entrer votre cl\u00e9 API RodiumAi. Elle sera stock\u00e9e uniquement sur votre appareil de mani\u00e8re s\u00e9curis\u00e9e.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.55),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _keyController,
          obscureText: state.isObscured,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            labelText: 'Cl\u00e9 API RodiumAi',
            hintText: 'rd_sk....',
            labelStyle: const TextStyle(color: _textSecondary),
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: _surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Coller',
                  onPressed: _pasteKey,
                  icon: const Icon(Icons.content_paste_rounded),
                  color: _textSecondary,
                ),
                IconButton(
                  tooltip: state.isObscured ? 'Afficher la cl\u00e9' : 'Masquer la cl\u00e9',
                  onPressed: () => ref
                      .read(byokViewModelProvider.notifier)
                      .toggleObscure(),
                  icon: Icon(state.isObscured
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded),
                  color: _textSecondary,
                ),
              ],
            ),
          ),
          onSubmitted: (_) => _saveKey(),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: _showKeyHelp,
            style: TextButton.styleFrom(
              foregroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: const Text('O\u00f9 trouver ma cl\u00e9 API ?'),
          ),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            state.errorMessage!,
            style: const TextStyle(color: Color(0xFFFCA5A5)),
          ),
        ],
        const SizedBox(height: 14),
        _gradientButton(
          label: 'Continuer',
          onPressed: state.isLoading ? null : _saveKey,
          isLoading: state.isLoading,
        ),
        const SizedBox(height: 22),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, color: Colors.white54, size: 17),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Votre cl\u00e9 est stock\u00e9e dans un espace s\u00e9curis\u00e9 sur votre appareil.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Etat de confirmation affiche apres l'enregistrement reussi.
  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _primary, size: 54),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Cl\u00e9 API enregistr\u00e9e !',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Votre cl\u00e9 RodiumAi est maintenant s\u00e9curis\u00e9e sur votre appareil. Vous pouvez commencer \u00e0 utiliser l\u2019assistant IA.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.55),
        ),
        const SizedBox(height: 32),
        _gradientButton(
          label: 'Acc\u00e9der \u00e0 l\u2019application',
          onPressed: () => context.go('/chat'),
        ),
      ],
    );
  }
}
