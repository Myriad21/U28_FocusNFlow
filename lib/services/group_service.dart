import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/group_model.dart';
import 'auth_service.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> createGroup(String groupName) async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final group = StudyGroup(
      id: '',
      name: groupName,
      members: [userId],
      activeSessionId: null,
    );

    await _db.collection('groups').add(group.toMap());
  }

  Future<void> joinGroup(String groupId) async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  Stream<List<StudyGroup>> streamUserGroups() {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
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

  Stream<List<StudyGroup>> streamAllGroups() {
    return _db.collection('groups').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyGroup.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
