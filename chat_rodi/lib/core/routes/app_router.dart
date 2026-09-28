import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chat_rodi/features/auth_byok/presentation/screens/byok_screen.dart';
import 'package:chat_rodi/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_rodi/features/model_selection/presentation/screens/model_selection_screen.dart';
import 'package:chat_rodi/features/generation/presentation/screens/image_generation_screen.dart';
import 'package:chat_rodi/features/generation/presentation/screens/video_generation_screen.dart';
import 'package:chat_rodi/features/account/presentation/screens/usage_dashboard_screen.dart';

abstract final class AppRoutes {
  static const byok = '/';
  static const chat = '/chat';
  static const modelSelection = '/models';
  static const generateImage = '/generate-image';
  static const generateVideo = '/generate-video';
  static const usage = '/usage';
  static const settings = '/settings';
  static const about = '/about';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.byok,
  routes: [
    GoRoute(path: AppRoutes.byok, name: 'byok', builder: (context, state) => const ByokScreen()),
    GoRoute(path: AppRoutes.chat, name: 'chat', builder: (context, state) => const ChatScreen()),
    GoRoute(path: AppRoutes.modelSelection, name: 'modelSelection', builder: (context, state) => const ModelSelectionScreen()),
    GoRoute(path: AppRoutes.generateImage, name: 'generateImage', builder: (context, state) => const ImageGenerationScreen()),
    GoRoute(path: AppRoutes.generateVideo, name: 'generateVideo', builder: (context, state) => const VideoGenerationScreen()),
    GoRoute(path: AppRoutes.usage, name: 'usage', builder: (context, state) => const UsageDashboardScreen()),
    GoRoute(path: AppRoutes.settings, name: 'settings', builder: (context, state) => const _InfoPage(title: 'Param\u00e8tres')),
    GoRoute(path: AppRoutes.about, name: 'about', builder: (context, state) => const _InfoPage(title: '\u00c0 propos de RodiumAi')),
  ],
);

class _InfoPage extends StatelessWidget {
  const _InfoPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
      );
}
