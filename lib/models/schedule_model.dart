// Trajuan Smith
// This is a generated weekly study schedule stored in Firestore
// Stores task IDs grouped by day instead of full task objects

class StudySchedule {
  final String id;
  final String userId;
  final Map<String, List<String>> generatedPlan;
  final DateTime lastUpdated;

  StudySchedule({
    required this.id,
    required this.userId,
    required this.generatedPlan,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'generatedPlan': generatedPlan,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory StudySchedule.fromMap(Map<String, dynamic> map, String documentId) {
    return StudySchedule(
      id: documentId,
      userId: map['userId'] ?? '',
      generatedPlan: Map<String, List<String>>.from(
        (map['generatedPlan'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}