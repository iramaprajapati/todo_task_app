import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthService() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
    }
  }

  // Future<void> signUpWithEmail(String email, String password) async {
  //   try {
  //     await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  Future<void> signUpWithEmail(String email, String password,
      {required String fullName, required String mobile}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Update user profile with additional information
      //await _firebaseAuth.currentUser!.updateProfile(displayName: fullName);
      await _firebaseAuth.currentUser!.updateDisplayName(fullName);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseAuth.currentUser!.uid)
          .set({
        'fullName': fullName,
        'email': email,
        'mobile': mobile,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
