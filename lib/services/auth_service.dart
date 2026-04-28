// Trajuan Smith
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Returns the currently signed-in Firebase user, or null if no user is logged in
  User? get currentUser => _auth.currentUser;

  // Returns the current user's UID for Firestore ownership checks
  String? get currentUserId => _auth.currentUser?.uid;

  // Creates a new account using email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}