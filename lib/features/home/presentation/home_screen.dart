import 'package:flutter/material.dart';

/// S02 – Home: the "What should I do now?" recommendation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('What should I do now?')),
    );
  }
}
