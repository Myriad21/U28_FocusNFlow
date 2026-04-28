import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Streams all study rooms so availability updates in real time
  Stream<List<StudyRoom>> streamRooms() {
    return _db.collection('rooms').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyRoom.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Adds a test room
  Future<void> addTestRoom() async {
    await _db.collection('rooms').add({
      'name': 'Library Room ${DateTime.now().millisecondsSinceEpoch}',
      'capacity': 4,
      'currentOccupancy': 0,
    });
  }

  // Uses a Firestore transaction so multiple users cannot overfill a room
  Future<void> joinRoom(String roomId) async {
    final roomRef = _db.collection('rooms').doc(roomId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        throw Exception('Room does not exist');
      }

      final data = snapshot.data()!;
      final capacity = data['capacity'] ?? 0;
      final currentOccupancy = data['currentOccupancy'] ?? 0;

      if (currentOccupancy >= capacity) {
        throw Exception('Room is already full');
      }

      transaction.update(roomRef, {
        'currentOccupancy': currentOccupancy + 1,
      });
    });
  }

  // Decreases occupancy safely without going below zero
  Future<void> leaveRoom(String roomId) async {
    final roomRef = _db.collection('rooms').doc(roomId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        throw Exception('Room does not exist');
      }

      final data = snapshot.data()!;
      final currentOccupancy = data['currentOccupancy'] ?? 0;

      if (currentOccupancy <= 0) {
        return;
      }

      transaction.update(roomRef, {
        'currentOccupancy': currentOccupancy - 1,
      });
    });
  }
}