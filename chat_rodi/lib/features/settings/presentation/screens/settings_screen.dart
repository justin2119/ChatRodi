import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/theme_provider.dart';

const _fallbackModel = 'rodium-chat-v1';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedModel = ref.watch(defaultModelProvider);
    final model = selectedModel.trim().isEmpty || selectedModel == 'Auto'
        ? _fallbackModel
        : selectedModel;
    final temperature = ref.watch(temperatureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Param\u00e8tres')),
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
                  title: Text(user?.email ?? 'Non connect\u00e9'),
                  subtitle: Text(user == null ? 'Acc\u00e8s invit\u00e9' : 'Compte connect\u00e9'),
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
                    child: Text(user == null ? 'Se connecter' : 'Se d\u00e9connecter'),
                  ),
                );
              },
            ),
          ]),
          _Section(title: 'G\u00e9n\u00e9ral', children: [
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Th\u00e8me'),
              subtitle: Text(_themeLabel(themeMode)),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                borderRadius: BorderRadius.circular(16),
                items: const [
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Clair')),
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Syst\u00e8me')),
                ],
                onChanged: (value) {
                  if (value != null) ref.read(themeModeProvider.notifier).setThemeMode(value);
                },
              ),
            ),
          ]),
          _Section(title: 'Mod\u00e8le & IA', children: [
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('Mod\u00e8le par d\u00e9faut'),
              subtitle: Text(model),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editModel(context, ref, model),
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Temp\u00e9rature'),
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
          _Section(title: 'S\u00e9curit\u00e9 & Cl\u00e9 API', children: [
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: const Text('Cl\u00e9 API (BYOK)'),
              subtitle: const Text('Consulter le statut ou modifier la cl\u00e9 enregistr\u00e9e'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/'),
            ),
          ]),
          _Section(title: '\u00c0 propos & Version', children: const [
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
        ThemeMode.system => 'Syst\u00e8me',
      };

  static Future<void> _editModel(BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current == 'Auto' ? _fallbackModel : current);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mod\u00e8le par d\u00e9faut'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Identifiant du mod\u00e8le',
            hintText: _fallbackModel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) {
      ref.read(defaultModelProvider.notifier).state =
          value.isEmpty || value == 'Auto' ? _fallbackModel : value;
    }
  }
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
