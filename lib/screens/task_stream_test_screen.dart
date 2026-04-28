import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';

class TaskStreamTestScreen extends StatelessWidget {
  final TaskService _taskService = TaskService();

  TaskStreamTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Real-Time Tasks")),
      body: StreamBuilder<List<Task>>(
        stream: _taskService.streamUserTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text("No tasks found"));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.course),
              );
            },
          );
        },
      ),
    );
  }
}