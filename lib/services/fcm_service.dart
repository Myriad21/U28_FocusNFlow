import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> initializeFcm() async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      return;
    }

    await _messaging.requestPermission();

    final token = await _messaging.getToken();

    if (token != null) {
      await _db.collection('users').doc(userId).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Foreground notification title: ${message.notification?.title}',
      );
      debugPrint('Foreground notification body: ${message.notification?.body}');
      debugPrint('Foreground notification data: ${message.data}');
    });
  }
}
