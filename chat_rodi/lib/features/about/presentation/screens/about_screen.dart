import 'package:flutter/material.dart';

const _orange = Color(0xFFFF6600),
    _bg = Color(0xFF0D0D0D),
    _surface = Color(0xFF1A1A1A);

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: _bg,
      foregroundColor: Colors.white,
      title: const Text('\u00c0 propos'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.home_repair_service, color: _orange, size: 52),
          ),
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'RodiumAi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text('v1.0.0', style: TextStyle(color: _orange)),
        ),
        const SizedBox(height: 28),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Une IA au service de l’apprentissage, de la curiosit\u00e9 et de la cr\u00e9ativit\u00e9.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
        const SizedBox(height: 28),
        const Center(
          child: Text(
            'RodiumAi',
            style: TextStyle(color: _orange, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Developpe par Justin Bina',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 26),
        const _LegalRow(
          icon: Icons.gavel_outlined,
          text: 'Mentions l\u00e9gales',
        ),
        const _LegalRow(
          icon: Icons.shield_outlined,
          text: 'Politiques de confidentialit\u00e9',
        ),
        const _LegalRow(
          icon: Icons.description_outlined,
          text: 'Conditions d’utilisation',
        ),
      ],
    ),
  );
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(14),
    ),
    child: ListTile(
      leading: Icon(icon, color: _orange),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.open_in_new, color: Colors.white38, size: 18),
    ),
  );
}
