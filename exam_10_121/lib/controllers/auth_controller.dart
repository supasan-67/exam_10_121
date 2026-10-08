import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthController {
  static const testPassword = '123456';
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  Stream<UserModel?> userStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? UserModel.fromMap(d.data()!) : null);

  /// สร้างบัญชีทดสอบ 2 บัญชี + เอกสารใน collection users
  Future<void> seedTestAccounts() async {
    final accounts = [
      {'name': 'Admin Tester', 'email': 'admin@test.com', 'role': 'Admin'},
      {'name': 'Operator Tester', 'email': 'operator@test.com', 'role': 'Operator'},
    ];
    for (final a in accounts) {
      UserCredential cred;
      try {
        cred = await _auth.createUserWithEmailAndPassword(
            email: a['email']!, password: testPassword);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;
        cred = await _auth.signInWithEmailAndPassword(
            email: a['email']!, password: testPassword);
      }
      final user = UserModel(
        uid: cred.user!.uid,
        name: a['name']!,
        email: a['email']!,
        role: a['role']!,
      );
      await _db.collection('users').doc(user.uid).set(user.toMap());
      await _auth.signOut();
    }
  }
}
