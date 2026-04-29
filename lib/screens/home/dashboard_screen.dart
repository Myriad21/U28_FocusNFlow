import 'package:flutter/material.dart';

import '../../logic/planner_engine.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_card.dart';
import '../tasks/add_task_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();
    final plannerEngine = PlannerEngine();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusNFlow'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: StreamBuilder<List<Task>>(
        stream: taskService.streamUserTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];
          final prioritized = plannerEngine.prioritizeTasks(tasks);
          final topTasks = prioritized.take(3).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Your Study Dashboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Track deadlines, generate a weekly plan, and coordinate with study groups.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Tasks',
                      value: '${tasks.length}',
                      icon: Icons.task_alt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'Priority Items',
                      value: '${topTasks.length}',
                      icon: Icons.priority_high,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Priority Tasks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (topTasks.isEmpty)
                      const EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No tasks yet',
                        subtitle:
                            'Add your first coursework task to start planning.',
                      )
                    else
                      ...topTasks.map((task) {
                        final score = plannerEngine.calculatePriorityScore(
                          task,
                        );

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text(score.toStringAsFixed(1)),
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            '${task.course} • Due ${_formatDate(task.deadline)} • ${task.estimatedEffort} hr',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await taskService.deleteTask(task.id);
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _QuickChip(
                          icon: Icons.add_task,
                          label: 'Add coursework',
                        ),
                        _QuickChip(
                          icon: Icons.calendar_month,
                          label: 'Generate plan',
                        ),
                        _QuickChip(icon: Icons.groups, label: 'Study groups'),
                        _QuickChip(
                          icon: Icons.meeting_room,
                          label: 'Find rooms',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          CircleAvatar(child: Icon(icon)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(title),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
