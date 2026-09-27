import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/generation_viewmodel.dart';

class VideoGenerationScreen extends ConsumerStatefulWidget {
  const VideoGenerationScreen({super.key});
  @override
  ConsumerState<VideoGenerationScreen> createState() => _VideoGenerationScreenState();
}
class _VideoGenerationScreenState extends ConsumerState<VideoGenerationScreen> {
  final _prompt = TextEditingController();
  @override
  void dispose() { _prompt.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generationViewModelProvider);
    final vm = ref.read(generationViewModelProvider.notifier);
    return Scaffold(backgroundColor: AppColors.deepSlate,
      appBar: AppBar(backgroundColor: AppColors.deepSlate, foregroundColor: AppColors.textPrimary, title: const Text('Générer une vidéo'), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
      body: SafeArea(child: Column(children: [Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Décrivez votre vidéo', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
        TextField(controller: _prompt, minLines: 5, maxLines: 8, style: const TextStyle(color: AppColors.textPrimary), decoration: _decoration('Décrivez la scène, le mouvement et l’ambiance...')),
        const SizedBox(height: 22), _label('Modèle'), const SizedBox(height: 8), _dropdown(state.videoModel, const ['Runway Gen-3'], vm.selectVideoModel),
        const SizedBox(height: 20), _label('Durée'), const SizedBox(height: 8), _chips(['5s', '10s', '20s'], state.videoDuration, vm.selectVideoDuration),
        const SizedBox(height: 20), _label('Format'), const SizedBox(height: 8), _chips(['1:1', '16:9', '9:16'], state.videoRatio, vm.selectVideoRatio),
        const SizedBox(height: 20), _label('Style'), const SizedBox(height: 8), _chips(['Réaliste', 'Cinématique', 'Anime'], state.videoStyle, vm.selectVideoStyle),
      ])), Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), child: _generateButton())]),));
  }
}
Widget _label(String text) => Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700));
InputDecoration _decoration(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: AppColors.surface, alignLabelWithHint: true, contentPadding: const EdgeInsets.all(16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.subtleBorder)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.subtleBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.emerald)));
Widget _dropdown(String selected, List<String> options, ValueChanged<String> onChanged) => Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.subtleBorder)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: selected, isExpanded: true, dropdownColor: AppColors.surface, style: const TextStyle(color: AppColors.textPrimary), items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { if (v != null) onChanged(v); })));
Widget _chips(List<String> items, String selected, ValueChanged<String> onSelected) => Wrap(spacing: 8, runSpacing: 6, children: items.map((e) => ChoiceChip(label: Text(e), selected: e == selected, onSelected: (_) => onSelected(e), selectedColor: AppColors.emerald, backgroundColor: AppColors.surface, labelStyle: TextStyle(color: e == selected ? AppColors.deepSlate : AppColors.textPrimary, fontWeight: FontWeight.w600), side: BorderSide(color: e == selected ? AppColors.emerald : AppColors.subtleBorder))).toList());
Widget _generateButton() => SizedBox(width: double.infinity, height: 54, child: DecoratedBox(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00C9A7), Color(0xFF00A88D)]), borderRadius: BorderRadius.circular(14)), child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Générer', style: TextStyle(color: AppColors.deepSlate, fontSize: 16, fontWeight: FontWeight.bold)))));
