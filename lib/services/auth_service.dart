// lib/services/auth_service.dart

import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService;

  AuthService({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirestoreService firestoreService,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _firestoreService = firestoreService;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUpWithEmail(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await _firestoreService.setUser(user, name: name);
      }
      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        await _firestoreService.setUser(result.user!);
      }
      return result.user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        await _firestoreService.setUser(result.user!);
      }
      return result.user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> updateUserDisplayName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
      } else {
        throw Exception('No user is currently signed in.');
      }
    } catch (e) {
      throw Exception('Error updating display name in Auth: $e');
    }
  }

  Future<void> updateUserPhotoUrl(String newPhotoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(newPhotoUrl);
      } else {
        throw Exception('No user is currently signed in.');
      }
    } catch (e) {
      throw Exception('Error updating photo URL in Auth: $e');
    }
  }

  // NEW: Forgot Password Method
  Future<String> handlePasswordReset(String email) async {
    try {
      final List<String> signInMethods =
      await _auth.fetchSignInMethodsForEmail(email);

      // Case 1: User signed up with Google
      if (signInMethods.contains('google.com') &&
          !signInMethods.contains('password')) {
        return 'google-sign-in';
      }

      // Case 2: User signed up with email/password
      if (signInMethods.contains('password')) {
        await _auth.sendPasswordResetEmail(email: email);
        return 'success';
      }

      // Case 3: Email does not exist
      return 'not-found';
    } on FirebaseAuthException catch (e) {
      // Handle potential Firebase errors
      return e.code;
    } catch (e) {
      return 'unknown-error';
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});