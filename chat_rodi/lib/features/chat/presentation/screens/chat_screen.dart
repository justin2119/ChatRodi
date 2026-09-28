import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/models/message_model.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/attachment_menu_bottom_sheet.dart';
import '../widgets/chat_drawer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty && ref.read(chatViewModelProvider).selectedAttachmentPath == null) return;
    _controller.clear();
    ref.read(chatViewModelProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.deepSlate,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlate,
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(context).openDrawer())),
        title: InkWell(onTap: () => context.go('/models'), child: Text(state.selectedModel, style: const TextStyle(color: AppColors.textPrimary))),
        centerTitle: true,
      ),
      drawer: const ChatDrawer(),
      body: Column(children: [
        Expanded(child: state.messages.isEmpty
            ? const Center(child: Text('Bonjour. Comment puis-je vous aider aujourd’hui ?', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 18)))
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: state.messages.length, itemBuilder: (context, index) => _MessageBubble(message: state.messages[index]))),
        if (state.errorMessage != null) Padding(padding: const EdgeInsets.all(8), child: Text(state.errorMessage!, style: const TextStyle(color: Colors.redAccent))),
        SafeArea(top: false, child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.subtleBorder))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (state.selectedAttachmentPath != null)
              _AttachmentPreview(path: state.selectedAttachmentPath!, type: state.selectedAttachmentType ?? 'file', onRemove: () => ref.read(chatViewModelProvider.notifier).clearAttachment()),
            Row(children: [
              IconButton(tooltip: 'Joindre un fichier', onPressed: () => showAttachmentMenu(context), icon: const Icon(Icons.attach_file_rounded, color: AppColors.textPrimary)),
              Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 5, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), style: const TextStyle(color: AppColors.textPrimary), decoration: InputDecoration(hintText: 'Posez votre question...', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.subtleBorder))))),
              IconButton.filled(onPressed: state.isLoading ? null : _send, style: IconButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: AppColors.deepSlate), icon: const Icon(Icons.arrow_upward_rounded)),
            ]),
          ]),
        )),
      ]),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.path, required this.type, required this.onRemove});
  final String path;
  final String type;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Container(height: 82, width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.subtleBorder), borderRadius: BorderRadius.circular(14)), child: Row(children: [
    ClipRRect(borderRadius: BorderRadius.circular(9), child: type == 'image' ? Image.file(File(path), width: 64, height: 64, fit: BoxFit.cover) : Container(width: 64, height: 64, color: const Color(0xFF0F172A), child: const Icon(Icons.description_outlined, color: AppColors.emerald))),
    const SizedBox(width: 12), Expanded(child: Text(path.split(Platform.pathSeparator).last, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary))),
    IconButton(onPressed: onRemove, tooltip: 'Supprimer la pi\\u00e8ce jointe', icon: const Icon(Icons.close_rounded, color: Colors.white70)),
  ]));
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final MessageModel message;

  void _showImage(BuildContext context, ImageProvider imageProvider) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(dialogContext).pop(),
          child: InteractiveViewer(child: Image(image: imageProvider, fit: BoxFit.contain)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attachmentPath = message.attachmentPath;
    final networkUrl = message.mediaUrls?.isNotEmpty == true ? message.mediaUrls!.first : null;
    final isLocalImage = message.attachmentType == 'image' && attachmentPath != null;
    final ImageProvider? imageProvider = isLocalImage
        ? FileImage(File(attachmentPath))
        : (networkUrl != null ? NetworkImage(networkUrl) : null);
    final maxWidth = MediaQuery.sizeOf(context).width * .82;
    return Align(
      alignment: message.role == MessageRole.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.subtleBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (imageProvider != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onTap: () => _showImage(context, imageProvider),
                  child: Image(image: imageProvider, width: maxWidth - 24, height: 190, fit: BoxFit.cover),
                ),
              ),
            ),
          if (attachmentPath != null && !isLocalImage)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.insert_drive_file_outlined, color: AppColors.emerald), const SizedBox(width: 8), Flexible(child: Text(attachmentPath.split(Platform.pathSeparator).last, style: const TextStyle(color: AppColors.textPrimary)))])),
          if (message.content.isNotEmpty) Text(message.content, style: const TextStyle(color: Color(0xFFF8FAFC), height: 1.45)),
        ]),
      ),
    );
  }
}
