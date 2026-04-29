import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'auth_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<String> uploadStudyResource({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final safeName = fileName.replaceAll(' ', '_');
    final path =
        'study_resources/$userId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    final ref = _storage.ref(path);

    await ref.putData(bytes);

    final downloadUrl = await ref.getDownloadURL();

    await _db.collection('users').doc(userId).collection('resources').add({
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'storagePath': path,
      'uploadedAt': DateTime.now().toIso8601String(),
    });

    return downloadUrl;
  }
}
