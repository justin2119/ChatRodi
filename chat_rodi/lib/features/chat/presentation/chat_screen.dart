import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatRodi'),
        actions: [
          IconButton(
            tooltip: 'Select model',
            onPressed: () => context.go(AppRoutes.modelSelection),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: const Center(child: Text('Your conversations will appear here.')),
    );
  }
}
