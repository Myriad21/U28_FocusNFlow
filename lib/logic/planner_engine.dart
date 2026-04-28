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
}