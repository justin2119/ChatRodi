import 'package:flutter/material.dart';

void main() {
  runApp(const ChatRodiApp());
}

class ChatRodiApp extends StatelessWidget {
  const ChatRodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ChatRodi',
      home: Scaffold(
        body: Center(
          child: Text('ChatRodi'),
        ),
      ),
    );
  }
}
