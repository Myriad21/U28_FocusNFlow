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
      body: SafeArea(
        child: StreamBuilder<List<Task>>(
          stream: taskService.streamUserTasks(),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];
            final prioritized = plannerEngine.prioritizeTasks(tasks);
            final topTasks = prioritized.take(3).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                    child: _HeroHeader(
                      taskCount: tasks.length,
                      onSignOut: () => AuthService().signOut(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Total Tasks',
                            value: '${tasks.length}',
                            icon: Icons.task_alt,
                            gradient: const [
                              Color(0xFF4F46E5),
                              Color(0xFF7C3AED),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _MetricCard(
                            title: 'Priority',
                            value: '${topTasks.length}',
                            icon: Icons.bolt,
                            gradient: const [
                              Color(0xFF06B6D4),
                              Color(0xFF0891B2),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(
                            title: 'High Priority',
                            subtitle:
                                'Based on deadline, effort, and course weight',
                          ),
                          const SizedBox(height: 12),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Center(child: CircularProgressIndicator())
                          else if (topTasks.isEmpty)
                            const EmptyState(
                              icon: Icons.assignment_outlined,
                              title: 'No tasks yet',
                              subtitle:
                                  'Add coursework to generate your study plan.',
                            )
                          else
                            ...topTasks.map((task) {
                              final score = plannerEngine
                                  .calculatePriorityScore(task);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFE0E7FF),
                                    child: Text(
                                      score.toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF4F46E5),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${task.course} • Due ${_formatDate(task.deadline)} • ${task.estimatedEffort} hr',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      taskService.deleteTask(task.id);
                                    },
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(
                            title: 'Quick Actions',
                            subtitle: 'Jump into your main study workflow',
                          ),
                          const SizedBox(height: 14),
                          _ActionTile(
                            icon: Icons.add_task,
                            title: 'Add coursework',
                            subtitle: 'Create a deadline-based academic task',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddTaskScreen(),
                                ),
                              );
                            },
                          ),
                          _ActionTile(
                            icon: Icons.calendar_month,
                            title: 'Generate weekly plan',
                            subtitle: 'Use the planner tab to build a schedule',
                            onTap: () {},
                          ),
                          _ActionTile(
                            icon: Icons.groups,
                            title: 'Coordinate with groups',
                            subtitle: 'Create chats and shared sessions',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final int taskCount;
  final VoidCallback onSignOut;

  const _HeroHeader({required this.taskCount, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.school, color: Color(0xFF4F46E5)),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'FocusNFlow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            taskCount == 0
                ? 'Build your academic workflow today.'
                : 'You have $taskCount task(s) in your study queue.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0F2FE),
          child: Icon(icon, color: const Color(0xFF0284C7)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
