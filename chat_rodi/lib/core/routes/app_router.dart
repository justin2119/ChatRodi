import 'package:go_router/go_router.dart';

import 'package:chat_rodi/features/auth_byok/presentation/screens/byok_screen.dart';
import 'package:chat_rodi/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_rodi/features/model_selection/presentation/screens/model_selection_screen.dart';

abstract final class AppRoutes {
  static const byok = '/';
  static const chat = '/chat';
  static const modelSelection = '/models';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.byok,
  routes: [
    GoRoute(
      path: AppRoutes.byok,
      name: 'byok',
      builder: (context, state) => const ByokScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      name: 'chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: AppRoutes.modelSelection,
      name: 'modelSelection',
      builder: (context, state) => const ModelSelectionScreen(),
    ),
  ],
);
