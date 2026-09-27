import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/models/message_model.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  static const _suggestions = <String>[
    'Analyser un probl\u00e8me de physique-chimie',
    'G\u00e9n\u00e9rer ou d\u00e9boguer du code',
    'R\u00e9sumer un long texte ou document',
    'Brainstormer des id\u00e9es cr\u00e9atives',
  ];
  @override
  void dispose() { _controller.dispose(); _scroll.dispose(); super.dispose(); }
  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(chatViewModelProvider.notifier).sendMessage(text);
  }
  void _newChat() {
    ref.read(chatViewModelProvider.notifier).newConversation();
    _controller.clear();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.deepSlate,
      drawer: Drawer(
        backgroundColor: AppColors.deepSlate,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(padding: const EdgeInsets.all(20), child: Row(children: [
            const CircleAvatar(backgroundColor: AppColors.emerald, child: Icon(Icons.auto_awesome, color: AppColors.deepSlate)),
            const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('RodiumAi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('user@example.com', style: TextStyle(color: Colors.white60, fontSize: 12))]),
          ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: AppColors.deepSlate, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            onPressed: _newChat, icon: const Icon(Icons.add_comment_outlined), label: const Text('Nouveau chat'),
          )),
          const Divider(color: AppColors.subtleBorder),
          _nav(context, Icons.chat_bubble_outline_rounded, 'Conversations', null),
          _nav(context, Icons.tune_rounded, 'Mod\u00e8les', '/models'),
          _nav(context, Icons.bar_chart_rounded, 'Utilisation', '/usage'),
          _nav(context, Icons.vpn_key_outlined, 'Cl\u00e9 API (BYOK)', '/byok'),
          _nav(context, Icons.settings_outlined, 'Param\u00e8tres', '/settings'),
          const Spacer(),
          const Padding(padding: EdgeInsets.all(20), child: Text('RodiumAi  •  v1.0.0', style: TextStyle(color: Colors.white54, fontSize: 12))),
        ])),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.deepSlate,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        leading: Builder(builder: (context) => IconButton(tooltip: 'Menu', icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(context).openDrawer())),
        title: InkWell(onTap: () => context.go('/models'), borderRadius: BorderRadius.circular(24), child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.subtleBorder), borderRadius: BorderRadius.circular(24)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Text(state.selectedModel, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)), const SizedBox(width: 4), const Icon(Icons.keyboard_arrow_down_rounded, size: 20)],),
        )),
        centerTitle: true,
        actions: [IconButton(tooltip: 'Nouveau chat', onPressed: _newChat, icon: const Icon(Icons.add_comment_outlined))],
      ),
      body: Column(children: [
        Expanded(child: state.messages.isEmpty ? _welcome() : ListView.builder(
          controller: _scroll, padding: const EdgeInsets.all(16),
          itemCount: state.messages.length + (state.isLoading ? 1 : 0),
          itemBuilder: (context, index) => index == state.messages.length
              ? const _Thinking() : _MessageBubble(message: state.messages[index]),
        )),
        if (state.errorMessage != null) Padding(padding: const EdgeInsets.all(8), child: Text(state.errorMessage!, style: const TextStyle(color: Colors.redAccent))),
        SafeArea(top: false, child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: const BoxDecoration(color: AppColors.deepSlate, border: Border(top: BorderSide(color: AppColors.subtleBorder))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            IconButton(tooltip: 'Joindre un fichier', onPressed: () {}, icon: const Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 28)),
            Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 5, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), style: const TextStyle(color: AppColors.textPrimary), decoration: InputDecoration(hintText: 'Posez votre question...', hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: AppColors.surface, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.subtleBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.emerald))))),
            const SizedBox(width: 8), ValueListenableBuilder<TextEditingValue>(valueListenable: _controller, builder: (context, value, _) => IconButton.filled(tooltip: value.text.trim().isEmpty ? 'Audio' : 'Envoyer', onPressed: state.isLoading ? null : (value.text.trim().isEmpty ? () {} : _send), style: IconButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: AppColors.deepSlate), icon: Icon(value.text.trim().isEmpty ? Icons.mic_none_rounded : Icons.arrow_upward_rounded))),
          ]),
        )),
      ]),
    );
  }
  Widget _welcome() => Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('Bonjour \u2728', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 30, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8), const Text('Comment puis-je vous aider aujourd\u2019hui ?', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
    const SizedBox(height: 28), ..._suggestions.map((text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: () => setState(() => _controller.text = text), borderRadius: BorderRadius.circular(14), child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.subtleBorder), borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.auto_awesome_outlined, color: AppColors.emerald, size: 20), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary))), const Icon(Icons.arrow_forward_rounded, color: Colors.white54, size: 18)]))))),
  ])));
  Widget _nav(BuildContext context, IconData icon, String label, String? route) => ListTile(leading: Icon(icon, color: AppColors.textPrimary), title: Text(label, style: const TextStyle(color: AppColors.textPrimary)), onTap: () { Navigator.pop(context); if (route != null) context.go(route); });
}

class _Thinking extends StatelessWidget {
  const _Thinking();
  @override
  Widget build(BuildContext context) => const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(12), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_awesome, color: AppColors.emerald, size: 18), SizedBox(width: 10), Text('RodiumAi r\u00e9fl\u00e9chit...', style: TextStyle(color: Colors.white70))])));
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final MessageModel message;
  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final bubble = Container(constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .82), margin: const EdgeInsets.symmetric(vertical: 5), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.subtleBorder)), child: Text(message.content, style: const TextStyle(color: Color(0xFFF8FAFC), height: 1.45)));
    if (isUser) return Align(alignment: Alignment.centerRight, child: Container(margin: const EdgeInsets.symmetric(vertical: 5), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .82), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.subtleBorder)), child: Text(message.content, style: const TextStyle(color: Color(0xFFF8FAFC), height: 1.45))));
    return Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Padding(padding: EdgeInsets.only(top: 10, right: 8), child: CircleAvatar(radius: 14, backgroundColor: AppColors.emerald, child: Icon(Icons.auto_awesome, size: 15, color: AppColors.deepSlate))), Flexible(child: bubble)]), Padding(padding: const EdgeInsets.only(left: 38), child: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: 'Copier', visualDensity: VisualDensity.compact, onPressed: () => Clipboard.setData(ClipboardData(text: message.content)), icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white54)), IconButton(tooltip: 'J’aime', visualDensity: VisualDensity.compact, onPressed: () {}, icon: const Icon(Icons.thumb_up_outlined, size: 18, color: Colors.white54)), IconButton(tooltip: 'Je n’aime pas', visualDensity: VisualDensity.compact, onPressed: () {}, icon: const Icon(Icons.thumb_down_outlined, size: 18, color: Colors.white54))]))]));
  }
}
