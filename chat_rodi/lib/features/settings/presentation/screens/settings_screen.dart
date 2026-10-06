import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/theme_provider.dart';

const _fallbackModel = 'rodium-chat-v1';

final availableModelsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final models = await ref.watch(apiClientProvider).getModels();
    return models.isNotEmpty ? models : const <String>[_fallbackModel];
  } catch (_) {
    return const <String>[_fallbackModel];
  }
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
                  leading: Icon(user == null ? Icons.person_outline : Icons.verified_user_outlined, color: const Color(0xFFFF6600)),
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
                      backgroundColor: const Color(0xFFFF6600),
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
          _Section(title: 'Sécurité & Clé API', children: [
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: const Text('Clé API (BYOK)'),
              subtitle: const Text('Consulter le statut ou modifier la clé enregistrée'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/'),
            ),
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
