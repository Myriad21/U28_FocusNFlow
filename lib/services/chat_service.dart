// Trajuan Smith

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';
import 'auth_service.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Sends a chat message inside a specific study group subcollection
  Future<void> sendMessage({
    required String groupId,
    required String text,
  }) async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    final message = ChatMessage(
      id: '',
      senderId: userId,
      text: text,
      timestamp: DateTime.now(),
    );

    await _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(message.toMap());
  }

  // Streams messages for a group ordered by newest timestamp last
  Stream<List<ChatMessage>> streamMessages(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}