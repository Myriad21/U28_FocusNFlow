// Trajuan Smith
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Saves a generated weekly schedule to Firestore
  Future<void> saveSchedule(StudySchedule schedule) async {
    await _db.collection('schedules').add(schedule.toMap());
  }

  // Retrieves the most recent schedule for a specific user
  Future<StudySchedule?> getLatestSchedule(String userId) async {
    final snapshot = await _db
        .collection('schedules')
        .where('userId', isEqualTo: userId)
        .orderBy('lastUpdated', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;
    return StudySchedule.fromMap(doc.data(), doc.id);
  }
}