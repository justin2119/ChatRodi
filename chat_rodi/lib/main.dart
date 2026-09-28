import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

const _supabaseUrl = 'https://tgxpyykmwsaeijlgtuex.supabase.co';
// Supabase publishable/anon keys are public client identifiers, not secrets.
// Never put a service_role key in a mobile app.
const _supabasePublishableKey =
    'sb_publishable_xnKTy_6KOgayjDCbQRZSiA_8H6dW474';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Environment file is optional; API configuration has safe defaults.
  }
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabasePublishableKey,
  );
  runApp(const ProviderScope(child: ChatRodiApp()));
}

class ChatRodiApp extends StatelessWidget {
  const ChatRodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChatRodi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
