import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const FocusNFlowApp());
  } catch (error) {
    runApp(FirebaseErrorApp(error: error));
  }
}

class FocusNFlowApp extends StatelessWidget {
  const FocusNFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusNFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class FirebaseErrorApp extends StatelessWidget {
  final Object error;

  const FirebaseErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusNFlow Firebase Setup',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Setup Needed')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 54),
                      const SizedBox(height: 16),
                      Text(
                        'Firebase is not configured for this platform.',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This usually happens when running on Chrome/Web before FlutterFire has been configured for web.',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Quick fix:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const SelectableText(
                        'flutterfire configure\nflutter clean\nflutter pub get\nflutter run -d chrome',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Or run on Windows desktop instead:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const SelectableText('flutter run -d windows'),
                      const SizedBox(height: 16),
                      Text(
                        'Error details:\n$error',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
