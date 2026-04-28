import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//import 'screens/task_stream_test_screen.dart';
import 'services/auth_service.dart';
//import 'screens/group_test_screen.dart';
import 'screens/room_test_screen.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AuthService().signInAnonymously();
  await FcmService().initializeFcm();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusNFlow',
      debugShowCheckedModeBanner: false,
      home: RoomTestScreen(),
    );
  }
}