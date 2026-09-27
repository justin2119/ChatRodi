import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../chat/presentation/viewmodels/chat_viewmodel.dart';
import '../../data/datasources/model_local_data.dart';
import '../../domain/models/ai_model.dart';
import '../viewmodels/model_selection_viewmodel.dart';

/// Écran de catalogue (écran 5) et détails de modèle (écran 6).
class ModelSelectionScreen extends ConsumerWidget {
  const ModelSelectionScreen({super.key});

  static const List<String> _filters = <String>['Tous', 'Texte', 'Image', 'Vidéo', 'Audio'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modelSelectionViewModelProvider);
    final viewModel = ref.read(modelSelectionViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.deepSlate,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlate,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Sélectionner un modèle', style: TextStyle(fontWeight: FontWeight.w700)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      body: SafeArea(
        top: false,
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: viewModel.setSearchQuery,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Rechercher un modèle...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true, fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.subtleBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.subtleBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.emerald)),
              ),
            ),
          ),
          SizedBox(
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final active = state.selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter), selected: active,
                  onSelected: (_) => viewModel.setFilter(filter),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.emerald,
                  labelStyle: TextStyle(color: active ? AppColors.deepSlate : AppColors.textPrimary, fontWeight: FontWeight.w600),
                  side: BorderSide(color: active ? AppColors.emerald : AppColors.subtleBorder),
                  shape: const StadiumBorder(),
                );
              },
            ),
          ),
          Expanded(
            child: state.filteredModels.isEmpty
                ? const Center(child: Text('Aucun modèle trouvé', style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: state.filteredModels.length,
                    itemBuilder: (context, index) {
                      final model = state.filteredModels[index];
                      final selected = model.id == state.selectedModelId;
                      return _ModelCard(
                        model: model, selected: selected,
                        onTap: () => _showDetails(context, ref, model),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }

  void _showDetails(BuildContext context, WidgetRef ref, AiModel model) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => _ModelDetailsSheet(
        model: model,
        onSelect: () {
          ref.read(modelSelectionViewModelProvider.notifier).selectModel(model.id);
          ref.read(chatViewModelProvider.notifier).selectModel(model.id);
          Navigator.of(sheetContext).pop();
          context.go('/chat');
        },
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.model, required this.selected, required this.onTap});
  final AiModel model;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.surface, elevation: selected ? 4 : 0,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: selected ? AppColors.emerald : AppColors.subtleBorder, width: selected ? 1.5 : 1)),
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[
            Container(width: 42, height: 42, decoration: BoxDecoration(color: model.color.withValues(alpha: .15), borderRadius: BorderRadius.circular(12)), child: Icon(model.icon, color: model.color)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(model.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3), Text(model.provider, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ])),
            if (selected) const Icon(Icons.check_circle, color: AppColors.emerald),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: model.capabilities.where((tag) => tag != 'Texte').take(4).map((tag) => _CapabilityTag(label: tag)).toList()),
          const SizedBox(height: 12),
          Row(children: <Widget>[
            const Icon(Icons.forum_outlined, size: 15, color: Colors.white54), const SizedBox(width: 5),
            Text(model.contextWindow, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 14), const Icon(Icons.bolt, size: 15, color: AppColors.emerald), const SizedBox(width: 3),
            Text(model.speed, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ]),
      ),
    ),
  );
}

class _ModelDetailsSheet extends StatelessWidget {
  const _ModelDetailsSheet({required this.model, required this.onSelect});
  final AiModel model;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(4)))),
        const SizedBox(height: 22),
        Row(children: <Widget>[
          Container(width: 52, height: 52, decoration: BoxDecoration(color: model.color.withValues(alpha: .15), borderRadius: BorderRadius.circular(15)), child: Icon(model.icon, color: model.color, size: 28)),
          const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(model.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(model.provider, style: const TextStyle(color: Colors.white60)),
          ])),
        ]),
        const SizedBox(height: 18),
        Text(model.description, style: const TextStyle(color: Colors.white70, height: 1.5)),
        const SizedBox(height: 22),
        Row(children: <Widget>[
          Expanded(child: _ModelStat(label: 'Contexte', value: model.contextWindow, icon: Icons.forum_outlined)),
          const SizedBox(width: 10), Expanded(child: _ModelStat(label: 'Vitesse', value: model.speed, icon: Icons.bolt_outlined)),
        ]),
        const SizedBox(height: 10),
        _ModelStat(label: 'Prix estimé', value: model.pricingEstimated, icon: Icons.payments_outlined),
        const SizedBox(height: 20),
        const Text('Capacités', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: model.capabilities.map((tag) => _CapabilityTag(label: tag)).toList()),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52, child: DecoratedBox(
          decoration: BoxDecoration(gradient: const LinearGradient(colors: <Color>[Color(0xFF00C9A7), Color(0xFF00A88D)]), borderRadius: BorderRadius.circular(14)),
          child: ElevatedButton(onPressed: onSelect, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Sélectionner', style: TextStyle(color: AppColors.deepSlate, fontSize: 16, fontWeight: FontWeight.bold))),
        )),
      ])),
    ),
  );
}

class _ModelStat extends StatelessWidget {
  const _ModelStat({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: AppColors.deepSlate, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.subtleBorder)),
    child: Row(children: <Widget>[Icon(icon, color: AppColors.emerald, size: 19), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 3), Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600))]))]),
  );
}

class _CapabilityTag extends StatelessWidget {
  const _CapabilityTag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: .1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.emerald.withValues(alpha: .25))),
    child: Text(label, style: const TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
