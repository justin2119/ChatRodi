import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';

/// Drawer correspondant a l'ecran 12 du mockup RodiumAi.
class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  static const _background = Color(0xFF0D0D0D);
  static const _surface = Color(0xFF1A1A1A);
  static const _orange = Color(0xFFFF6600);
  static const _muted = Color(0xFFB3B3B3);

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    return Drawer(
      backgroundColor: _background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
              child: Row(
                children: [
                  CircleAvatar(radius: 25, backgroundColor: _surface, child: const Icon(Icons.person_outline, color: Colors.white, size: 27)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Utilisateur', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)), SizedBox(height: 3), Text('user@example.com', style: TextStyle(color: _muted, fontSize: 12))])),
                  const Icon(Icons.more_horiz, color: _muted),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(height: 48, child: ElevatedButton.icon(
                onPressed: () { final router = GoRouter.of(context); Navigator.of(context).pop(); router.go(AppRoutes.chat); },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nouveau chat', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: _orange, foregroundColor: Colors.white, shape: const StadiumBorder(), elevation: 0),
              )),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(20, 25, 20, 10), child: Text('Conversations', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: .5))),
            Expanded(child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _conversation(context, 'Projet Flutter ChatRodi'),
                _conversation(context, 'Explication Physique Chimie'),
                _conversation(context, 'Architecture Supabase'),
                const Padding(padding: EdgeInsets.fromLTRB(10, 23, 10, 10), child: Text('NAVIGATION', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: .8))),
                _navItem(context, currentLocation, Icons.widgets_outlined, 'Modèles', AppRoutes.modelSelection),
                _navItem(context, currentLocation, Icons.bar_chart_rounded, 'Utilisation', AppRoutes.usage),
                _navItem(context, currentLocation, Icons.key_outlined, 'Clé API', AppRoutes.byok),
                _navItem(context, currentLocation, Icons.settings_outlined, 'Paramètres', AppRoutes.settings),
                ListTile(dense: true, leading: const Icon(Icons.help_outline, color: _muted, size: 20), title: const Text('Aide & support', style: TextStyle(color: Colors.white, fontSize: 14)), onTap: () {
                  showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(backgroundColor: _surface, title: const Text('Aide & support', style: TextStyle(color: Colors.white)), content: const Text('Besoin d’aide ? Contactez notre equipe de support.', style: TextStyle(color: _muted)), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Fermer', style: TextStyle(color: _orange)))]));
                }),
                _navItem(context, currentLocation, Icons.info_outline, 'À propos', AppRoutes.about),
              ],
            )),
            Container(margin: const EdgeInsets.fromLTRB(16, 8, 16, 14), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.auto_awesome, color: _orange, size: 23), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('RodiumAi', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), SizedBox(height: 3), Text('Plus de 100 modèles. Une seule API.', style: TextStyle(color: _muted, fontSize: 11))]))])),
          ],
        ),
      ),
    );
  }

  Widget _conversation(BuildContext context, String title) => ListTile(
    dense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    leading: const Icon(Icons.chat_bubble_outline, color: _muted, size: 18),
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13)),
    trailing: PopupMenuButton<String>(padding: EdgeInsets.zero, icon: const Icon(Icons.more_horiz, color: _muted, size: 18), color: _surface, onSelected: (_) {}, itemBuilder: (context) => const [PopupMenuItem(value: 'options', child: Text('Options', style: TextStyle(color: Colors.white)))]),
    onTap: () { final router = GoRouter.of(context); Navigator.of(context).pop(); router.go(AppRoutes.chat); },
  );

  Widget _navItem(BuildContext context, String current, IconData icon, String label, String route) {
    final selected = current == route;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: selected ? _orange : _muted, size: 20),
      title: Text(label, style: TextStyle(color: selected ? Colors.white : _muted, fontSize: 14)),
      selected: selected,
      selectedTileColor: const Color(0x26FF6600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.push(route);
      },
    );
  }
}
