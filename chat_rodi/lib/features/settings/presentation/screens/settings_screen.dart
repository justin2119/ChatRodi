import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/security/byok_storage_service.dart';
import '../../../../core/theme/theme_provider.dart';

const _fallbackModel = 'rodium-chat-v1';
const _brandOrange = Color(0xFFFF6600);

final availableModelsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final models = await ref.watch(apiClientProvider).getModels();
    return models.isNotEmpty ? models : const <String>[_fallbackModel];
  } catch (_) {
    return const <String>[_fallbackModel];
  }
});

final byokApiKeyProvider = FutureProvider<String?>((ref) async {
  return ref.watch(byokStorageServiceProvider).getApiKey();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedModel = ref.watch(defaultModelProvider);
    final modelsAsync = ref.watch(availableModelsProvider);
    final temperature = ref.watch(temperatureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _Section(title: 'Compte & Authentification', children: [
            StreamBuilder<AuthState>(
              stream: Supabase.instance.client.auth.onAuthStateChange,
              initialData: AuthState(AuthChangeEvent.initialSession, Supabase.instance.client.auth.currentSession),
              builder: (context, snapshot) {
                final user = snapshot.data?.session?.user ?? Supabase.instance.client.auth.currentUser;
                return ListTile(
                  leading: Icon(user == null ? Icons.person_outline : Icons.verified_user_outlined, color: _brandOrange),
                  title: Text(user?.email ?? 'Non connecté'),
                  subtitle: Text(user == null ? 'Accès invité' : 'Compte connecté'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      if (user == null) {
                        context.push('/auth');
                      } else {
                        await Supabase.instance.client.auth.signOut();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: Text(user == null ? 'Se connecter' : 'Se déconnecter'),
                  ),
                );
              },
            ),
          ]),
          _Section(title: 'Général', children: [
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Thème'),
              subtitle: Text(_themeLabel(themeMode)),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                borderRadius: BorderRadius.circular(16),
                items: const [
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Clair')),
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Système')),
                ],
                onChanged: (value) {
                  if (value != null) ref.read(themeModeProvider.notifier).setThemeMode(value);
                },
              ),
            ),
          ]),
          _Section(title: 'Modèle & IA', children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: modelsAsync.when(
                loading: () => InputDecorator(
                  decoration: const InputDecoration(labelText: 'Modèle par défaut'),
                  child: Text(selectedModel),
                ),
                error: (_, __) => DropdownButtonFormField<String>(
                  value: _fallbackModel,
                  decoration: const InputDecoration(labelText: 'Modèle par défaut'),
                  items: const [DropdownMenuItem(value: _fallbackModel, child: Text(_fallbackModel))],
                  onChanged: (value) {
                    if (value != null) ref.read(defaultModelProvider.notifier).state = value;
                  },
                ),
                data: (models) {
                  final options = models.isEmpty ? const <String>[_fallbackModel] : models;
                  final value = options.contains(selectedModel) ? selectedModel : options.first;
                  if (value != selectedModel) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(defaultModelProvider.notifier).state = value;
                    });
                  }
                  return DropdownButtonFormField<String>(
                    value: value,
                    decoration: const InputDecoration(labelText: 'Modèle par défaut'),
                    items: options.map((model) => DropdownMenuItem(value: model, child: Text(model))).toList(),
                    onChanged: (model) {
                      if (model != null) ref.read(defaultModelProvider.notifier).state = model;
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Température'),
              subtitle: Text(temperature.toStringAsFixed(1)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Slider(
                value: temperature,
                min: 0,
                max: 1,
                divisions: 20,
                label: temperature.toStringAsFixed(2),
                onChanged: (value) => ref.read(temperatureProvider.notifier).state = value,
              ),
            ),
          ]),
          _Section(title: 'Sécurité & Clé API', children: const [
            _ApiKeyManagement(),
          ]),
          _Section(title: 'À propos & Version', children: const [
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('ChatRodi'),
              subtitle: Text('Version 1.0.0+1'),
            ),
          ]),
        ],
      ),
    );
  }

  static String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => 'Sombre',
        ThemeMode.light => 'Clair',
        ThemeMode.system => 'Système',
      };
}

class _ApiKeyManagement extends ConsumerStatefulWidget {
  const _ApiKeyManagement();

  @override
  ConsumerState<_ApiKeyManagement> createState() => _ApiKeyManagementState();
}

class _ApiKeyManagementState extends ConsumerState<_ApiKeyManagement> {
  bool _showKey = false;
  bool _busy = false;

  Future<void> _editKey() async {
    final key = await showDialog<String>(
      context: context,
      builder: (_) => const _EditApiKeyDialog(),
    );
    if (key == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(byokStorageServiceProvider).saveApiKey(key);
      ref.invalidate(byokApiKeyProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clé mise à jour avec succès')),
      );
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’enregistrer la clé API.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _revokeKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Révoquer la clé API ?'),
        content: const Text('La clé enregistrée sera supprimée de cet appareil. Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Révoquer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(byokStorageServiceProvider).deleteApiKey();
      ref.invalidate(byokApiKeyProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clé révoquée')),
      );
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer la clé API.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyAsync = ref.watch(byokApiKeyProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Gestion de la clé API', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        keyAsync.when(
          loading: () => const LinearProgressIndicator(color: _brandOrange),
          error: (_, __) => const Text('Impossible de lire la clé enregistrée.'),
          data: (key) => Row(children: [
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Clé API BYOK'),
                child: Text(key == null || key.isEmpty
                    ? 'Aucune clé enregistrée'
                    : _showKey ? key : '••••••••••••••••'),
              ),
            ),
            if (key != null && key.isNotEmpty)
              IconButton(
                tooltip: _showKey ? 'Masquer la clé' : 'Afficher la clé',
                onPressed: () => setState(() => _showKey = !_showKey),
                icon: Icon(_showKey ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 8, children: [
          ElevatedButton.icon(
            onPressed: _busy ? null : _editKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: Text(keyAsync.valueOrNull == null ? 'Ajouter une clé' : 'Modifier la clé'),
          ),
          if (keyAsync.valueOrNull?.isNotEmpty == true)
            OutlinedButton.icon(
              onPressed: _busy ? null : _revokeKey,
              style: OutlinedButton.styleFrom(
                foregroundColor: _brandOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Révoquer'),
            ),
        ]),
        if (_busy) const Padding(
          padding: EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(color: _brandOrange),
        ),
      ]),
    );
  }
}

class _EditApiKeyDialog extends StatefulWidget {
  const _EditApiKeyDialog();

  @override
  State<_EditApiKeyDialog> createState() => _EditApiKeyDialogState();
}

class _EditApiKeyDialogState extends State<_EditApiKeyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Clé API BYOK'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            obscureText: _obscure,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Nouvelle clé API',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Afficher la clé' : 'Masquer la clé',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Saisissez une clé API.';
              if (value.trim().length < 8) return 'La clé doit contenir au moins 8 caractères.';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, _controller.text.trim());
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: children),
            ),
          ],
        ),
      );
}
