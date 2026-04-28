class StudyRoom {
  final String id;
  final String name;
  final int capacity;
  final int currentOccupancy;
  final List<String> members;

  StudyRoom({
    required this.id,
    required this.name,
    required this.capacity,
    required this.members,
    required this.currentOccupancy,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
    };
  }

  factory StudyRoom.fromMap(Map<String, dynamic> map, String documentId) {
    return StudyRoom(
      id: documentId,
      name: map['name'] ?? '',
      capacity: map['capacity'] ?? 0,
      members: List<String>.from(map['members'] ?? []),
      currentOccupancy: map['currentOccupancy'] ?? 0,
    );
  }

  bool get isAvailable => currentOccupancy < capacity;
}