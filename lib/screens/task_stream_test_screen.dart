// Trajuan Smith
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final task = Task(
              id: '',
              userId: '',
              title: 'Test Task',
              course: 'MAD',
              deadline: DateTime.now().add(const Duration(days: 2)),
              estimatedEffort: 3,
              courseWeight: 5,
            );

            await _taskService.addTask(task);
          },
        child: const Icon(Icons.add),
      ),
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