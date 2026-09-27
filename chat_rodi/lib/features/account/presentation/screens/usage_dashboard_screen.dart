import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/usage_viewmodel.dart';

class UsageDashboardScreen extends ConsumerWidget {
  const UsageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(usageViewModelProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consommation de tokens'),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      body: usage.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(usageViewModelProvider.notifier).fetchUsage(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _quotaCard(context, usage),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _periodCard(context, 'Aujourd’hui', usage.dailyTokens, usage.quota ~/ 30, Icons.today)),
                    const SizedBox(width: 12),
                    Expanded(child: _periodCard(context, 'Cette semaine', usage.weeklyTokens, usage.quota ~/ 4, Icons.date_range)),
                  ]),
                  const SizedBox(height: 20),
                  Text('Répartition des tokens', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  _breakdownCard(context, 'Prompt', usage.promptTokens, 'Completion', usage.completionTokens),
                  const SizedBox(height: 10),
                  _breakdownCard(context, 'Texte', usage.textTokens, 'Image', usage.imageTokens),
                  const SizedBox(height: 20),
                  Text('Utilisation par modèle', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Card(child: Column(children: usage.models.map((model) => ListTile(
                    leading: CircleAvatar(backgroundColor: Color(model.color), radius: 7),
                    title: Text(model.name),
                    trailing: Text(_format(model.tokens)),
                    subtitle: LinearProgressIndicator(
                      value: usage.tokensUsed == 0 ? 0 : model.tokens / usage.tokensUsed,
                      color: Color(model.color),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  )).toList())),
                ],
              ),
            ),
    );
  }

  Widget _quotaCard(BuildContext context, UsageState usage) {
    final theme = Theme.of(context);
    return Card(child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Quota total', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(children: [
          SizedBox(width: 82, height: 82, child: Stack(fit: StackFit.expand, children: [
            CircularProgressIndicator(value: usage.quotaProgress, strokeWidth: 9),
            Center(child: Text('${(usage.quotaProgress * 100).round()}%', style: theme.textTheme.titleMedium)),
          ])),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_format(usage.tokensUsed), style: theme.textTheme.headlineSmall),
            const Text('tokens utilisés'),
            const SizedBox(height: 4),
            Text('sur ${_format(usage.quota)} tokens', style: theme.textTheme.bodySmall),
          ])),
        ]),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: usage.quotaProgress, minHeight: 8),
      ]),
    ));
  }

  Widget _periodCard(BuildContext context, String title, int used, int quota, IconData icon) {
    final value = quota == 0 ? 0.0 : (used / quota).clamp(0.0, 1.0);
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 10),
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(_format(used), style: Theme.of(context).textTheme.titleLarge),
        Text('sur ${_format(quota)} tokens', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: value),
      ]),
    ));
  }

  Widget _breakdownCard(BuildContext context, String firstLabel, int first, String secondLabel, int second) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Expanded(child: _metric(context, firstLabel, first)),
        const SizedBox(width: 12),
        Expanded(child: _metric(context, secondLabel, second)),
      ]),
    ));
  }

  Widget _metric(BuildContext context, String label, int count) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Text(label, style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 4), Text(_format(count), style: Theme.of(context).textTheme.titleMedium)],
  );

  String _format(int count) => count.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ',
  );
}
