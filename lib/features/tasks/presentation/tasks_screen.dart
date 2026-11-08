import 'package:flutter/material.dart';

/// S04 – Tasks list.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: const Center(child: Text('Tasks – coming soon')),
    );
  }
}
