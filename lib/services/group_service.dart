// Trajuan SMith

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import 'auth_service.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Creates a new study group and adds the current user as the first member
  Future<void> createGroup(String groupName) async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    final group = StudyGroup(
      id: '',
      name: groupName,
      members: [userId],
      activeSessionId: null,
    );

    await _db.collection('groups').add(group.toMap());
  }

  // Adds the current user to an existing group without overwriting other members
  Future<void> joinGroup(String groupId) async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  // Streams groups that include the current user
  Stream<List<StudyGroup>> streamUserGroups() {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    return _db
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyGroup.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}