import 'package:flutter/material.dart';

/// Informations de présentation et capacités d'un modèle proposé par RodiumAi.
class AiModel {
  const AiModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
    required this.contextWindow,
    required this.speed,
    required this.pricingEstimated,
    required this.capabilities,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String provider;
  final String description;
  final String contextWindow;
  final String speed;
  final String pricingEstimated;
  final List<String> capabilities;
  final IconData icon;
  final Color color;
}
