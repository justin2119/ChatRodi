import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/byok_viewmodel.dart';

/// Ecran de configuration initiale de la cle API RodiumAi.
/// La cle reste dans le champ de saisie puis dans le stockage securise ; elle n'est jamais copiee dans l'etat Riverpod.
class ByokScreen extends ConsumerStatefulWidget {
  const ByokScreen({super.key});
  @override
  ConsumerState<ByokScreen> createState() => _ByokScreenState();
}

class _ByokScreenState extends ConsumerState<ByokScreen> {
  static const Color _primary = Color(0xFFFF6600);
  final TextEditingController _keyController = TextEditingController();
  @override
  void initState() { super.initState(); Future<void>.microtask(() => ref.read(byokViewModelProvider.notifier).checkExistingKey()); }
  @override
  void dispose() { _keyController.dispose(); super.dispose(); }
  Future<void> _pasteKey() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final value = clipboard?.text;
    if (value == null || !mounted) return;
    final key = value.trim();
    _keyController..text = key..selection = TextSelection.collapsed(offset: key.length);
  }
  Future<void> _saveKey() async { await ref.read(byokViewModelProvider.notifier).saveKey(_keyController.text); }
  void _showKeyHelp() {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(context: context, backgroundColor: colors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 32), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('O\\u00f9 trouver ma cl\\u00e9 API ?', style: TextStyle(color: scheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text('Connectez-vous \\u00e0 votre compte RodiumAi, ouvrez la section de gestion des cl\\u00e9s API, puis copiez une cl\\u00e9 active. Ne partagez jamais cette cl\\u00e9 avec qui que ce soit.', style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5)),
      ])));
    });
  }
  Widget _gradientButton(BuildContext context, {required String label, required VoidCallback? onPressed, bool isLoading = false}) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(height: 56, child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: _primary, disabledBackgroundColor: _primary.withValues(alpha: 0.5), foregroundColor: colors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))), child: isLoading ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onPrimary)) : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))));
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(byokViewModelProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), backgroundColor: theme.scaffoldBackgroundColor, foregroundColor: colors.onSurface, elevation: 0, title: const Text('Configuration initiale', style: TextStyle(fontWeight: FontWeight.w700))),
      body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 28, 24, 32), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: state.isKeySaved && state.errorMessage == null ? _buildSuccess(context) : _buildEntry(context, state))))),
    );
  }
  Widget _buildEntry(BuildContext context, ByokState state) {
    final colors = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: Container(width: 84, height: 84, decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle), child: const Icon(Icons.lock_outline, color: _primary, size: 38))),
      const SizedBox(height: 24),
      Text('Ajoutez votre cl\\u00e9 API RodiumAi', textAlign: TextAlign.center, style: TextStyle(color: colors.onSurface, fontSize: 23, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Text('Pour acc\\u00e9der aux mod\\u00e8les d\\u2019IA et utiliser toutes les fonctionnalit\\u00e9s, veuillez entrer votre cl\\u00e9 API RodiumAi. Elle sera stock\\u00e9e uniquement sur votre appareil de mani\\u00e8re s\\u00e9curis\\u00e9e.', textAlign: TextAlign.center, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14, height: 1.55)),
      const SizedBox(height: 30),
      TextField(controller: _keyController, obscureText: state.isObscured, autocorrect: false, enableSuggestions: false, style: TextStyle(color: colors.onSurface), decoration: InputDecoration(labelText: 'Cl\\u00e9 API RodiumAi', hintText: 'rd_sk....', labelStyle: TextStyle(color: colors.onSurfaceVariant), hintStyle: TextStyle(color: colors.onSurfaceVariant), filled: true, fillColor: colors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: colors.outline)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: _primary, width: 1.5)), suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: 'Coller', onPressed: _pasteKey, icon: const Icon(Icons.content_paste_rounded), color: colors.onSurfaceVariant), IconButton(tooltip: state.isObscured ? 'Afficher la cl\\u00e9' : 'Masquer la cl\\u00e9', onPressed: () => ref.read(byokViewModelProvider.notifier).toggleObscure(), icon: Icon(state.isObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded), color: colors.onSurfaceVariant)])), onSubmitted: (_) => _saveKey()),
      Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: _showKeyHelp, style: TextButton.styleFrom(foregroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))), child: const Text('O\\u00f9 trouver ma cl\\u00e9 API ?'))),
      if (state.errorMessage != null) ...[const SizedBox(height: 4), Text(state.errorMessage!, style: TextStyle(color: colors.error))],
      const SizedBox(height: 14), _gradientButton(context, label: 'Continuer', onPressed: state.isLoading ? null : _saveKey, isLoading: state.isLoading), const SizedBox(height: 22),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shield_outlined, color: colors.onSurfaceVariant, size: 17), const SizedBox(width: 8), Flexible(child: Text('Votre cl\\u00e9 est stock\\u00e9e dans un espace s\\u00e9curis\\u00e9 sur votre appareil.', textAlign: TextAlign.center, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)))]),
    ]);
  }
  Widget _buildSuccess(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: Container(width: 92, height: 92, decoration: BoxDecoration(color: _primary.withValues(alpha: 0.12), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: _primary, size: 54))),
      const SizedBox(height: 26), Text('Cl\\u00e9 API enregistr\\u00e9e !', textAlign: TextAlign.center, style: TextStyle(color: colors.onSurface, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12), Text('Votre cl\\u00e9 RodiumAi est maintenant s\\u00e9curis\\u00e9e sur votre appareil. Vous pouvez commencer \\u00e0 utiliser l\\u2019assistant IA.', textAlign: TextAlign.center, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14, height: 1.55)),
      const SizedBox(height: 32), _gradientButton(context, label: 'Acc\\u00e9der \\u00e0 l\\u2019application', onPressed: () => context.go('/chat')),
    ]);
  }
}
