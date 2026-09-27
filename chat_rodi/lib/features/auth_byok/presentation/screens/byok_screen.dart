import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/byok_viewmodel.dart';

/// Écran de configuration initiale de la clé API RodiumAi.
///
/// La clé reste dans le champ de saisie puis dans le stockage sécurisé ; elle
/// n'est jamais copiée dans l'état Riverpod.
class ByokScreen extends ConsumerStatefulWidget {
  /// Crée l'écran BYOK.
  const ByokScreen({super.key});

  @override
  ConsumerState<ByokScreen> createState() => _ByokScreenState();
}

class _ByokScreenState extends ConsumerState<ByokScreen> {
  /// Palette sombre et accent émeraude de l'écran.
  static const Color _deepSlate = Color(0xFF0F172A);
  static const Color _emerald = Color(0xFF00C9A7);
  static const Color _surface = Color(0xFF1E293B);
  static const Color _textPrimary = Color(0xFFF8FAFC);
  static const Color _textSecondary = Color(0xFF94A3B8);

  /// Contrôleur local du champ, pour ne pas exposer le secret dans le provider.
  final TextEditingController _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Recherche une éventuelle clé existante dès l'ouverture de l'écran.
    Future<void>.microtask(
      () => ref.read(byokViewModelProvider.notifier).checkExistingKey(),
    );
  }

  @override
  void dispose() {
    // Libère les ressources associées au champ.
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

  /// Demande au ViewModel d'enregistrer la clé saisie.
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
                'Où trouver ma clé API ?',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Connectez-vous à votre compte RodiumAi, ouvrez la section de gestion des clés API, puis copiez une clé active. Ne partagez jamais cette clé avec qui que ce soit.',
                style: TextStyle(color: _textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un bouton principal à dégradé, commun aux deux états.
  Widget _gradientButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_emerald, const Color(0xFF00A887)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: _deepSlate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _deepSlate,
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
      ),
    );
  }

  /// Présente l'écran d'enregistrement ou l'écran de succès.
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(byokViewModelProvider);

    return Scaffold(
      backgroundColor: _deepSlate,
      appBar: AppBar(
        // Règle de style : la barre d'application doit rester parfaitement carrée.
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: _deepSlate,
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

  /// État initial : saisie, aide, erreurs et note de sécurité.
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
            child: const Icon(Icons.lock_outline, color: _emerald, size: 38),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Ajoutez votre clé API RodiumAi',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pour accéder aux modèles d’IA et utiliser toutes les fonctionnalités, veuillez entrer votre clé API RodiumAi. Elle sera stockée uniquement sur votre appareil de manière sécurisée.',
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
            labelText: 'Clé API RodiumAi',
            hintText: 'rd_sk....',
            labelStyle: const TextStyle(color: _textSecondary),
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
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
                  tooltip: state.isObscured ? 'Afficher la clé' : 'Masquer la clé',
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
            style: TextButton.styleFrom(foregroundColor: _emerald),
            child: const Text('Où trouver ma clé API ?'),
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
            Icon(Icons.shield_outlined, color: Color(0xFF64748B), size: 17),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Votre clé est stockée dans un espace sécurisé sur votre appareil.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// État de confirmation affiché après l'enregistrement réussi.
  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: _emerald.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _emerald, size: 54),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Clé API enregistrée !',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Votre clé RodiumAi est maintenant sécurisée sur votre appareil. Vous pouvez commencer à utiliser l’assistant IA.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.55),
        ),
        const SizedBox(height: 32),
        _gradientButton(
          label: 'Accéder à l’application',
          onPressed: () => context.go('/chat'),
        ),
      ],
    );
  }
}
