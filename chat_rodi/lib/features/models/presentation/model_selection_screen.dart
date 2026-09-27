import 'package:flutter/material.dart';

class ModelSelectionScreen extends StatelessWidget {
  const ModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model selection')),
      body: const Center(child: Text('Choose your preferred AI model.')),
    );
  }
}
