import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
  final _imagePicker = ImagePicker();
  static const _suggestions = <String>[
    'Analyser un probl\\u00e8me de physique-chimie',
    'G\\u00e9n\\u00e9rer ou d\\u00e9boguer du code',
    'R\\u00e9sumer un long texte ou document',
    'Brainstormer des id\\u00e9es cr\\u00e9atives',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty && ref.read(chatViewModelProvider).selectedAttachmentPath == null) return;
    _controller.clear();
    ref.read(chatViewModelProvider.notifier).sendMessage(text);
  }

  void _newChat() {
    ref.read(chatViewModelProvider.notifier).newConversation();
    _controller.clear();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _showAttachmentSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF334155)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 38, height: 4, decoration: BoxDecoration(color: const Color(0xFF64748B), borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 18),
            const Align(alignment: Alignment.centerLeft, child: Text('Joindre un fichier', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 16, fontWeight: FontWeight.w600))),
            const SizedBox(height: 18),
            Row(children: [
              _AttachmentAction(icon: Icons.camera_alt_outlined, label: 'Appareil photo', onTap: () { Navigator.pop(sheetContext); _pickImage(ImageSource.camera); }),
              _AttachmentAction(icon: Icons.photo_library_outlined, label: 'Galerie', onTap: () { Navigator.pop(sheetContext); _pickImage(ImageSource.gallery); }),
              _AttachmentAction(icon: Icons.description_outlined, label: 'Documents', onTap: () { Navigator.pop(sheetContext); _pickFile(); }),
              _AttachmentAction(icon: Icons.folder_open_rounded, label: 'Fichiers', onTap: () { Navigator.pop(sheetContext); _pickFile(); }),
            ]),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(sheetContext), style: TextButton.styleFrom(backgroundColor: const Color(0xFF334155), foregroundColor: const Color(0xFFF8FAFC), padding: const EdgeInsets.symmetric(vertical: 13)), child: const Text('Annuler'))),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source, imageQuality: 88);
      if (image != null && mounted) ref.read(chatViewModelProvider.notifier).setAttachment(image.path, type: 'image');
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de sélectionner l’image : $error')));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path != null && mounted) ref.read(chatViewModelProvider.notifier).setAttachment(path, type: 'file');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.deepSlate,
      drawer: Drawer(backgroundColor: AppColors.deepSlate, child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Padding(padding: EdgeInsets.all(20), child: Row(children: [CircleAvatar(backgroundColor: AppColors.emerald, child: Icon(Icons.auto_awesome, color: AppColors.deepSlate)), SizedBox(width: 12), Text('RodiumAi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: FilledButton.icon(onPressed: _newChat, icon: const Icon(Icons.add_comment_outlined), label: const Text('Nouveau chat'), style: FilledButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: AppColors.deepSlate))),
        const Divider(color: AppColors.subtleBorder),
        _nav(context, Icons.chat_bubble_outline_rounded, 'Conversations', null),
        _nav(context, Icons.tune_rounded, 'Mod\\u00e8les', '/models'),
        _nav(context, Icons.bar_chart_rounded, 'Utilisation', '/usage'),
        _nav(context, Icons.vpn_key_outlined, 'Cl\\u00e9 API (BYOK)', '/byok'),
        _nav(context, Icons.settings_outlined, 'Param\\u00e8tres', '/settings'),
      ]))),
      appBar: AppBar(
        backgroundColor: AppColors.deepSlate,
        leading: Builder(builder: (context) => IconButton(tooltip: 'Menu', icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(context).openDrawer())),
        title: InkWell(onTap: () => context.go('/models'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.subtleBorder), borderRadius: BorderRadius.circular(24)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(state.selectedModel, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)), const Icon(Icons.keyboard_arrow_down_rounded, size: 20)]))),
        centerTitle: true,
        actions: [IconButton(tooltip: 'Nouveau chat', onPressed: _newChat, icon: const Icon(Icons.add_comment_outlined))],
      ),
      body: Column(children: [
        Expanded(child: state.messages.isEmpty ? _welcome() : ListView.builder(controller: _scroll, padding: const EdgeInsets.all(16), itemCount: state.messages.length + (state.isLoading ? 1 : 0), itemBuilder: (context, index) => index == state.messages.length ? const _Thinking() : _MessageBubble(message: state.messages[index]))),
        if (state.errorMessage != null) Padding(padding: const EdgeInsets.all(8), child: Text(state.errorMessage!, style: const TextStyle(color: Colors.redAccent))),
        SafeArea(top: false, child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: const BoxDecoration(color: AppColors.deepSlate, border: Border(top: BorderSide(color: AppColors.subtleBorder))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (state.selectedAttachmentPath != null) _AttachmentPreview(path: state.selectedAttachmentPath!, type: state.selectedAttachmentType ?? 'file', onRemove: () => ref.read(chatViewModelProvider.notifier).clearAttachment()),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              IconButton(tooltip: 'Joindre un fichier', onPressed: _showAttachmentSheet, icon: const Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 28)),
              Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 5, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), style: const TextStyle(color: AppColors.textPrimary), decoration: InputDecoration(hintText: 'Posez votre question...', hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: AppColors.surface, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.subtleBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.emerald))))),
              const SizedBox(width: 8), ValueListenableBuilder<TextEditingValue>(valueListenable: _controller, builder: (context, value, _) => IconButton.filled(tooltip: 'Envoyer', onPressed: state.isLoading ? null : _send, style: IconButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: AppColors.deepSlate), icon: const Icon(Icons.arrow_upward_rounded))),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _welcome() => Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('Bonjour \\u2728', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 30, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8), const Text('Comment puis-je vous aider aujourd\\u2019hui ?', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
    const SizedBox(height: 28), ..._suggestions.map((text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: () => setState(() => _controller.text = text), borderRadius: BorderRadius.circular(14), child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.subtleBorder), borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.auto_awesome_outlined, color: AppColors.emerald, size: 20), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary))), const Icon(Icons.arrow_forward_rounded, color: Colors.white54, size: 18)]))))),
  ])));

  Widget _nav(BuildContext context, IconData icon, String label, String? route) => ListTile(leading: Icon(icon, color: AppColors.textPrimary), title: Text(label, style: const TextStyle(color: AppColors.textPrimary)), onTap: () { Navigator.pop(context); if (route != null) context.go(route); });
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2), child: Column(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF334155))), child: Icon(icon, color: AppColors.emerald)), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 11))]))));
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.path, required this.type, required this.onRemove});
  final String path;
  final String type;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Container(height: 82, width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.subtleBorder), borderRadius: BorderRadius.circular(14)), child: Row(children: [
    ClipRRect(borderRadius: BorderRadius.circular(9), child: type == 'image' ? Image.file(File(path), width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 64, height: 64, child: Icon(Icons.broken_image_outlined, color: Colors.white54))) : Container(width: 64, height: 64, color: const Color(0xFF0F172A), child: const Icon(Icons.description_outlined, color: AppColors.emerald))),
    const SizedBox(width: 12), Expanded(child: Text(path.split(Platform.pathSeparator).last, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary))),
    IconButton(onPressed: onRemove, tooltip: 'Supprimer la pièce jointe', icon: const Icon(Icons.close_rounded, color: Colors.white70)),
  ]));
}

class _Thinking extends StatelessWidget {
  const _Thinking();
  @override
  Widget build(BuildContext context) => const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(12), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_awesome, color: AppColors.emerald, size: 18), SizedBox(width: 10), Text('RodiumAi r\\u00e9fl\\u00e9chit...', style: TextStyle(color: Colors.white70))])));
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final MessageModel message;

  void _showImage(BuildContext context, ImageProvider image) => showDialog<void>(context: context, builder: (_) => Dialog(backgroundColor: Colors.transparent, child: GestureDetector(onTap: () => Navigator.pop(context), child: InteractiveViewer(child: Image(image: image, fit: BoxFit.contain)))));

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final maxWidth = MediaQuery.sizeOf(context).width * .82;
    final attachmentPath = message.attachmentPath;
    final networkUrl = message.mediaUrls?.isNotEmpty == true ? message.mediaUrls!.first : null;
    final imageAttachment = message.attachmentType == 'image' && attachmentPath != null;
    final image = imageAttachment ? Image.file(File(attachmentPath), width: maxWidth - 30, height: 190, fit: BoxFit.cover) : (networkUrl != null ? Image.network(networkUrl, width: maxWidth - 30, height: 190, fit: BoxFit.cover) : null);
    final bubble = Container(constraints: BoxConstraints(maxWidth: maxWidth), margin: const EdgeInsets.symmetric(vertical: 5), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.subtleBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (image != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: GestureDetector(onTap: () => _showImage(context, imageAttachment ? FileImage(File(attachmentPath!)) : NetworkImage(networkUrl!) as ImageProvider, child: image))),
      if (attachmentPath != null && !imageAttachment) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.insert_drive_file_outlined, color: AppColors.emerald), const SizedBox(width: 8), Flexible(child: Text(attachmentPath.split(Platform.pathSeparator).last, style: const TextStyle(color: AppColors.textPrimary)))])),
      if (message.content.isNotEmpty) Text(message.content, style: const TextStyle(color: Color(0xFFF8FAFC), height: 1.45)),
    ]));
    if (isUser) return Align(alignment: Alignment.centerRight, child: bubble);
    return Align(alignment: Alignment.centerLeft, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Padding(padding: EdgeInsets.only(top: 10, right: 8), child: CircleAvatar(radius: 14, backgroundColor: AppColors.emerald, child: Icon(Icons.auto_awesome, size: 15, color: AppColors.deepSlate))), Flexible(child: bubble)]));
  }
}
