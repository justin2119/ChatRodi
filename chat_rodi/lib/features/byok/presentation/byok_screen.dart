import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';

class ByokScreen extends StatelessWidget {
  const ByokScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect your API key')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bring your own key to get started.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.chat),
              child: const Text('Continue to chat'),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.modelSelection),
              child: const Text('Choose a model'),
            ),
          ],
        ),
      ),
    );
  }
}
