import 'package:flutter/material.dart';

const _orange = Color(0xFFFF6600);
const _background = Color(0xFF0D0D0D);
const _surface = Color(0xFF1A1A1A);

/// Presents the RodiumAi attachment actions.
Future<void> showAttachmentMenu(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: _surface,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  builder: (context) => SafeArea(child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8))),
      const SizedBox(height: 20),
      const Align(alignment: Alignment.centerLeft, child: Text('Joindre un contenu', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
      const SizedBox(height: 14),
      _Action(icon: Icons.photo_library_outlined, title: 'Image / Photo', subtitle: 'Choisir dans la galerie', onTap: () => Navigator.pop(context, 'gallery')),
      _Action(icon: Icons.description_outlined, title: 'Document / Fichier', subtitle: 'Parcourir les fichiers', onTap: () => Navigator.pop(context, 'file')),
      _Action(icon: Icons.camera_alt_outlined, title: 'Caméra', subtitle: 'Prendre une photo', onTap: () => Navigator.pop(context, 'camera')),
      _Action(icon: Icons.code_rounded, title: 'Code / Snippet', subtitle: 'Ajouter un extrait de code', onTap: () => Navigator.pop(context, 'code')),
    ]),
  )),
);

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  @override Widget build(BuildContext context) => ListTile(
    onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: _orange)),
    title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)), trailing: const Icon(Icons.chevron_right, color: Colors.white38),
  );
}
