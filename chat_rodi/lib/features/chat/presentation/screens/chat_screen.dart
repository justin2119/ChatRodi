import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../../domain/models/message_model.dart';

/// Écran principal de conversation RodiumAi.
///
/// Il observe le ViewModel Riverpod, présente les messages et transmet les
/// saisies utilisateur sans mélanger l'affichage à la logique réseau.
class ChatScreen extends ConsumerStatefulWidget {
  /// Crée l'écran de chat.
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Vide le champ puis délègue l'envoi au ViewModel.
  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
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
        title: const Text('RodiumAi'),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length + (state.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(color: AppColors.emerald),
                    ),
                  );
                }
                return _MessageBubble(message: state.messages[index]);
              },
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(state.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent)),
            ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.subtleBorder)),
              ),
              child: Row(
                children: <Widget>[
                  // Le bouton d'attachement est présent en préparation de
                  // l'ajout du téléversement des médias.
                  IconButton(
                    tooltip: 'Joindre un fichier',
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file, color: AppColors.emerald),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message…',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Envoyer',
                    onPressed: state.isLoading ? null : _send,
                    icon: const Icon(Icons.send, color: AppColors.emerald),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bulle de message alignée selon son rôle et habillée aux couleurs de la marque.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isUser ? AppColors.emerald.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser ? AppColors.emerald : AppColors.subtleBorder,
          ),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
        ),
      ),
    );
  }
}
