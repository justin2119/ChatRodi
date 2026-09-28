import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _orange = Color(0xFFFF6600), _bg = Color(0xFF0D0D0D), _surface = Color(0xFF1A1A1A);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: _bg, appBar: AppBar(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), backgroundColor: _bg, foregroundColor: Colors.white, title: const Text('Param\u00e8tres')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      _Section(title: 'G\u00e9n\u00e9ral', children: [const _Item(icon: Icons.dark_mode_outlined, title: 'Th\u00e8me sombre', trailing: Icon(Icons.check, color: _orange)), const _Item(icon: Icons.language, title: 'Langue', subtitle: 'Fran\u00e7ais')]),
      _Section(title: 'Mod\u00e8le & IA', children: [const _Item(icon: Icons.smart_toy_outlined, title: 'Mod\u00e8le par d\u00e9faut', subtitle: 'Choisir un mod\u00e8le'), const _Item(icon: Icons.tune, title: 'Temp\u00e9rature', subtitle: 'Par d\u00e9faut'), SwitchListTile(activeColor: _orange, value: true, onChanged: (_) {}, title: const Text('Stream des r\u00e9ponses', style: TextStyle(color: Colors.white)), secondary: const Icon(Icons.bolt, color: _orange))]),
      _Section(title: 'S\u00e9curit\u00e9 & Cl\u00e9 API', children: [_Item(icon: Icons.key_outlined, title: 'Gestion de la cl\u00e9 API', subtitle: 'BYOK — votre cl\u00e9, votre contr\u00f4le', onTap: () => context.go('/'))]),
      _Section(title: 'Donn\u00e9es & Cache', children: [const _Item(icon: Icons.delete_outline, title: 'Vider l’historique'), const _Item(icon: Icons.cleaning_services_outlined, title: 'Vider le cache')]),
      _Section(title: '\u00c0 propos & Version', children: [_Item(icon: Icons.info_outline, title: 'RodiumAi', subtitle: 'Version 1.0.0', onTap: () => context.go('/about'))]),
    ]));
}
class _Section extends StatelessWidget { const _Section({required this.title, required this.children}); final String title; final List<Widget> children; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: const TextStyle(color: _orange, fontWeight: FontWeight.w700))), Container(decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16)), child: Column(children: children))])); }
class _Item extends StatelessWidget { const _Item({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap}); final IconData icon; final String title; final String? subtitle; final Widget? trailing; final VoidCallback? onTap; @override Widget build(BuildContext context) => ListTile(onTap: onTap, leading: Icon(icon, color: _orange), title: Text(title, style: const TextStyle(color: Colors.white)), subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(color: Colors.white60)), trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white38)); }
