import '../models/task_model.dart';

class PlannerEngine {
  double calculatePriorityScore(Task task) {
    final now = DateTime.now();
    final daysUntilDeadline = task.deadline.difference(now).inDays;

    final deadlineFactor = daysUntilDeadline <= 0
        ? 10
        : (10 - daysUntilDeadline).clamp(1, 10);

    final courseWeightFactor = task.courseWeight.clamp(1, 10);
    final effortFactor = task.estimatedEffort.clamp(1, 10);

    return (deadlineFactor * 0.5) +
        (courseWeightFactor * 0.3) +
        (effortFactor * 0.2);
  }

  List<Task> prioritizeTasks(List<Task> tasks) {
    final sortedTasks = [...tasks];

    sortedTasks.sort((a, b) {
      final scoreA = calculatePriorityScore(a);
      final scoreB = calculatePriorityScore(b);

      return scoreB.compareTo(scoreA);
    });

    return sortedTasks;
  }

  Map<String, List<Task>> generateWeeklyPlan(List<Task> tasks) {
    final prioritizedTasks = prioritizeTasks(tasks);

    final Map<String, List<Task>> weeklyPlan = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };

    final days = weeklyPlan.keys.toList();
    int dayIndex = 0;

    for (final task in prioritizedTasks) {
      weeklyPlan[days[dayIndex]]!.add(task);
      dayIndex = (dayIndex + 1) % days.length;
    }

    return weeklyPlan;
  }
}