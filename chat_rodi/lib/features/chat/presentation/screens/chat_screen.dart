import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  void dispose() { _controller.dispose(); super.dispose(); }
  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty && ref.read(chatViewModelProvider).selectedAttachmentPath == null) return;
    _controller.clear();
    ref.read(chatViewModelProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(chatViewModelProvider);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(context).openDrawer())),
        title: InkWell(onTap: () => context.go('/models'), child: Text(state.selectedModel, style: TextStyle(color: colors.onSurface))),
        centerTitle: true,
      ),
      drawer: const ChatDrawer(),
      body: Column(children: [
        Expanded(child: state.messages.isEmpty
            ? Center(child: Text('Bonjour. Comment puis-je vous aider aujourd’hui ?', textAlign: TextAlign.center, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 18)))
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: state.messages.length, itemBuilder: (context, index) => _MessageBubble(message: state.messages[index]))),
        if (state.errorMessage != null) Padding(padding: const EdgeInsets.all(8), child: Text(state.errorMessage!, style: TextStyle(color: colors.error))),
        SafeArea(top: false, child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.outline))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (state.selectedAttachmentPath != null) _AttachmentPreview(path: state.selectedAttachmentPath!, type: state.selectedAttachmentType ?? 'file', onRemove: () => ref.read(chatViewModelProvider.notifier).clearAttachment()),
            Row(children: [
              IconButton(tooltip: 'Joindre un fichier', onPressed: () => showAttachmentMenu(context), icon: Icon(Icons.attach_file_rounded, color: colors.onSurface)),
              Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 5, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), style: TextStyle(color: colors.onSurface), decoration: InputDecoration(hintText: 'Posez votre question...', filled: true, fillColor: colors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: colors.outline))))),
              IconButton.filled(onPressed: state.isLoading ? null : _send, style: IconButton.styleFrom(backgroundColor: const Color(0xFFFF6600), foregroundColor: colors.onPrimary), icon: const Icon(Icons.arrow_upward_rounded)),
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(height: 82, width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: colors.surface, border: Border.all(color: colors.outline), borderRadius: BorderRadius.circular(14)), child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(9), child: type == 'image' ? Image.file(File(path), width: 64, height: 64, fit: BoxFit.cover) : Container(width: 64, height: 64, color: colors.surfaceContainerHighest, child: Icon(Icons.description_outlined, color: const Color(0xFFFF6600)))),
      const SizedBox(width: 12), Expanded(child: Text(path.split(Platform.pathSeparator).last, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.onSurface))),
      IconButton(onPressed: onRemove, tooltip: 'Supprimer la pièce jointe', icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant)),
    ]));
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final MessageModel message;
  void _showImage(BuildContext context, ImageProvider imageProvider) {
    showDialog<void>(context: context, builder: (dialogContext) => Dialog(backgroundColor: Colors.transparent, child: GestureDetector(onTap: () => Navigator.of(dialogContext).pop(), child: InteractiveViewer(child: Image(image: imageProvider, fit: BoxFit.contain)))));
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final attachmentPath = message.attachmentPath;
    final networkUrl = message.mediaUrl ?? (message.mediaUrls?.isNotEmpty == true ? message.mediaUrls!.first : null);
    final isLocalImage = message.attachmentType == 'image' && attachmentPath != null;
    final ImageProvider? imageProvider = isLocalImage ? FileImage(File(attachmentPath)) : (networkUrl != null && message.type != MessageType.video ? NetworkImage(networkUrl) : null);
    final maxWidth = MediaQuery.sizeOf(context).width * .82;
    return Align(alignment: message.role == MessageRole.user ? Alignment.centerRight : Alignment.centerLeft, child: Container(
      constraints: BoxConstraints(maxWidth: maxWidth), margin: const EdgeInsets.symmetric(vertical: 5), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: colors.outline)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (imageProvider != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: GestureDetector(onTap: () => _showImage(context, imageProvider), child: Image(image: imageProvider, width: maxWidth - 24, height: 190, fit: BoxFit.cover)))),
        if (message.type == MessageType.video && message.mediaUrl != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.movie_outlined, color: colors.primary), const SizedBox(width: 8), Flexible(child: Text('Video generation: ${message.mediaUrl}', style: TextStyle(color: colors.onSurface)))])),
        if (attachmentPath != null && !isLocalImage) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.insert_drive_file_outlined, color: colors.primary), const SizedBox(width: 8), Flexible(child: Text(attachmentPath.split(Platform.pathSeparator).last, style: TextStyle(color: colors.onSurface)))])),
        if (message.content.isNotEmpty && message.type != MessageType.video) Text(message.content, style: TextStyle(color: colors.onSurface, height: 1.45)),
      ]),
    ));
  }
}
