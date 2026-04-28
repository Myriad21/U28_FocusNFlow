class Task {
  final String id;
  final String userId;
  final String title;
  final String course;
  final DateTime deadline;
  final int estimatedEffort;
  final int courseWeight;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.course,
    required this.deadline,
    required this.estimatedEffort,
    required this.courseWeight,
  });

  // Convert Task -> Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'course': course,
      'deadline': deadline.toIso8601String(),
      'estimatedEffort': estimatedEffort,
      'courseWeight': courseWeight,
    };
  }

  // Convert Firestore Map -> Task
  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      course: map['course'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      estimatedEffort: map['estimatedEffort'] ?? 0,
      courseWeight: map['courseWeight'] ?? 0,
    );
  }
}