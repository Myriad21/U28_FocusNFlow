import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';
import 'auth_service.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

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
      'members': [],
    });
  }

  // Uses a Firestore transaction so multiple users cannot overfill a room
  Future<void> joinRoom(String roomId) async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final roomRef = _db.collection('rooms').doc(roomId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        throw Exception('Room does not exist');
      }

      final data = snapshot.data()!;
      final capacity = data['capacity'] ?? 0;
      final currentOccupancy = data['currentOccupancy'] ?? 0;
      final members = List<String>.from(data['members'] ?? []);

      if (members.contains(userId)) {
        throw Exception('You already joined this room');
      }

      if (currentOccupancy >= capacity) {
        throw Exception('Room is already full');
      }

      transaction.update(roomRef, {
        'currentOccupancy': currentOccupancy + 1,
        'members': FieldValue.arrayUnion([userId]),
      });
    });
  }

  // Decreases occupancy safely without going below zero
  Future<void> leaveRoom(String roomId) async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final roomRef = _db.collection('rooms').doc(roomId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        throw Exception('Room does not exist');
      }

      final data = snapshot.data()!;
      final currentOccupancy = data['currentOccupancy'] ?? 0;
      final members = List<String>.from(data['members'] ?? []);

      if (!members.contains(userId)) {
        throw Exception('You are not in this room');
      }

      transaction.update(roomRef, {
        'currentOccupancy': currentOccupancy > 0 ? currentOccupancy - 1 : 0,
        'members': FieldValue.arrayRemove([userId]),
      });
    });
  }
}