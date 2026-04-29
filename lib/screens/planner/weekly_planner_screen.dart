import 'package:flutter/material.dart';

import '../../logic/planner_engine.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/schedule_service.dart';
import '../../services/task_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_card.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  final PlannerEngine _plannerEngine = PlannerEngine();
  final TaskService _taskService = TaskService();
  final ScheduleService _scheduleService = ScheduleService();

  Map<String, List<Task>> _plan = {};
  List<String> _suggestions = [];
  bool _loading = false;

  Future<void> _generatePlan() async {
    setState(() => _loading = true);

    try {
      final tasks = await _taskService.getUserTasks();
      final userId = AuthService().currentUserId;

      final plan = _plannerEngine.generateWeeklyPlan(tasks);
      final suggestions = _buildSuggestions(plan);

      if (userId != null) {
        final schedule = _plannerEngine.createScheduleFromTasks(
          userId: userId,
          tasks: tasks,
        );

        await _scheduleService.saveSchedule(schedule);
      }

      if (!mounted) return;

      setState(() {
        _plan = plan;
        _suggestions = suggestions;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weekly plan generated and saved.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Planner failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<String> _buildSuggestions(Map<String, List<Task>> plan) {
    final suggestions = <String>[];

    for (final entry in plan.entries) {
      final totalHours = entry.value.fold<int>(
        0,
        (sum, task) => sum + task.estimatedEffort,
      );

      if (totalHours > 6) {
        suggestions.add(
          '${entry.key} has $totalHours planned hours. Move lower-priority tasks to a lighter day.',
        );
      }
    }

    final emptyDays = plan.entries.where((entry) => entry.value.isEmpty).length;

    if (emptyDays > 0) {
      suggestions.add(
        'There are $emptyDays open day(s). Use them as buffer time for harder assignments.',
      );
    }

    if (suggestions.isEmpty) {
      suggestions.add(
        'Your workload looks balanced. Keep the highest-priority tasks early in the week.',
      );
    }

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    final hasPlan = _plan.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Planner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rule-Based Study Plan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tasks are prioritized using deadline urgency, estimated effort, and course weight.',
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _loading ? null : _generatePlan,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    _loading ? 'Generating...' : 'Generate Weekly Plan',
                  ),
                ),
              ],
            ),
          ),
          if (!hasPlan)
            const EmptyState(
              icon: Icons.calendar_month_outlined,
              title: 'No plan generated yet',
              subtitle: 'Add tasks, then generate your weekly study schedule.',
            )
          else ...[
            ..._plan.entries.map(
              (entry) => SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (entry.value.isEmpty)
                      const Text('Buffer / open study time')
                    else
                      ...entry.value.map(
                        (task) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(task.title),
                          subtitle: Text(
                            '${task.course} • ${task.estimatedEffort} hr • Weight ${task.courseWeight}/10',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adjustment Suggestions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ..._suggestions.map(
                    (suggestion) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.tips_and_updates_outlined),
                      title: Text(suggestion),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
