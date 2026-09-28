import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/byok_storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: .72,
    upperBound: 1,
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    var hasApiKey = false;
    try {
      hasApiKey = await ref.read(byokStorageServiceProvider).hasApiKey();
    } catch (_) {
      // If secure storage cannot be read, let the user enter or restore a key.
    }
    if (!mounted) return;
    context.go(hasApiKey ? '/chat' : '/');
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: _SplashBody(),
      );
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Color(0xFFFF6600), size: 54),
            ),
            const SizedBox(height: 20),
            const Text('RodiumAi',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 28),
            const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Color(0xFFFF6600))),
          ],
        ),
      );
}
