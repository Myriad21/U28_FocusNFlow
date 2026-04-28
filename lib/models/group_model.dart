// Trajuan Smith

class StudyGroup {
  final String id;
  final String name;
  final List<String> members;
  final String? activeSessionId;

  StudyGroup({
    required this.id,
    required this.name,
    required this.members,
    this.activeSessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members,
      'activeSessionId': activeSessionId,
    };
  }

  factory StudyGroup.fromMap(Map<String, dynamic> map, String documentId) {
    return StudyGroup(
      id: documentId,
      name: map['name'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      activeSessionId: map['activeSessionId'],
    );
  }
}