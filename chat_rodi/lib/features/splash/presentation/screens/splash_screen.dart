import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900), lowerBound: .72, upperBound: 1)..repeat(reverse: true);
  @override void initState() { super.initState(); Future<void>.delayed(const Duration(milliseconds: 900), () { if (mounted) context.go('/'); }); }
  @override void dispose() { _pulse.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFF0D0D0D), body: _SplashBody());
}
class _SplashBody extends StatelessWidget { const _SplashBody(); @override Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 96, height: 96, decoration: BoxDecoration(color: Color(0xFF1A1A1A), borderRadius: BorderRadius.all(Radius.circular(28))), child: Icon(Icons.auto_awesome, color: Color(0xFFFF6600), size: 54)), SizedBox(height: 20), Text('RodiumAi', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)), SizedBox(height: 28), SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF6600)))])); }
