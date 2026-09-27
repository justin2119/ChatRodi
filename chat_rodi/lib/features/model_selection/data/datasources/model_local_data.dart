import 'package:flutter/material.dart';

import '../../domain/models/ai_model.dart';

/// Catalogue local des modèles disponibles dans l'interface RodiumAi.
abstract final class ModelLocalData {
  static const List<AiModel> models = <AiModel>[
    AiModel(
      id: 'gemini-3.7-flash', name: 'Gemini 3.7 Flash', provider: 'Google',
      description: 'Un modèle multimodal rapide pour analyser, rédiger et coder. Adapté aux demandes quotidiennes comme aux longs documents.',
      contextWindow: '1M tokens', speed: 'Ultra rapide', pricingEstimated: '~2,5 RODI / 1K tokens',
      capabilities: <String>['Texte', 'Image', 'Vision', 'Vidéo', 'Audio', 'Code', 'Raisonnement'],
      icon: Icons.auto_awesome, color: Color(0xFF4285F4),
    ),
    AiModel(
      id: 'claude-3-5-sonnet', name: 'Claude 3.5 Sonnet', provider: 'Anthropic',
      description: 'Un assistant équilibré, particulièrement à l’aise pour l’écriture, l’analyse de documents et le développement logiciel.',
      contextWindow: '200K tokens', speed: 'Rapide', pricingEstimated: '~3 RODI / 1K tokens',
      capabilities: <String>['Texte', 'Image', 'Vision', 'Code', 'Raisonnement'],
      icon: Icons.auto_awesome, color: Color(0xFFD97757),
    ),
    AiModel(
      id: 'gpt-4o', name: 'GPT-4o', provider: 'OpenAI',
      description: 'Un modèle généraliste multimodal, efficace pour les conversations, l’analyse visuelle et la génération de code.',
      contextWindow: '128K tokens', speed: 'Rapide', pricingEstimated: '~3 RODI / 1K tokens',
      capabilities: <String>['Texte', 'Image', 'Vision', 'Audio', 'Code'],
      icon: Icons.blur_on, color: Color(0xFF10A37F),
    ),
    AiModel(
      id: 'deepseek-r1', name: 'DeepSeek R1', provider: 'DeepSeek',
      description: 'Un modèle orienté raisonnement, conçu pour décomposer les problèmes complexes et aider à la programmation.',
      contextWindow: '64K tokens', speed: 'Moyen', pricingEstimated: '~1,5 RODI / 1K tokens',
      capabilities: <String>['Texte', 'Code', 'Raisonnement'],
      icon: Icons.psychology_outlined, color: Color(0xFF536DFE),
    ),
    AiModel(
      id: 'llama-3.3-70b', name: 'Llama 3.3 70B', provider: 'Meta',
      description: 'Un modèle ouvert polyvalent pour les échanges, la synthèse et les tâches de code courantes.',
      contextWindow: '128K tokens', speed: 'Rapide', pricingEstimated: '~1 RODI / 1K tokens',
      capabilities: <String>['Texte', 'Code', 'Raisonnement'],
      icon: Icons.all_inclusive, color: Color(0xFF0866FF),
    ),
    AiModel(
      id: 'rodium-smart', name: 'Rodium Smart', provider: 'RodiumAi',
      description: 'Laissez RodiumAi choisir automatiquement un modèle adapté à votre demande et à ses besoins.',
      contextWindow: 'Variable', speed: 'Adaptatif', pricingEstimated: 'Selon le modèle utilisé',
      capabilities: <String>['Texte', 'Image', 'Code', 'Raisonnement'],
      icon: Icons.bolt, color: Color(0xFF00C9A7),
    ),
  ];
}
