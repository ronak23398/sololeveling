import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

import '../exceptions/app_exceptions.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user ID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  // Get current user email
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Register with email and password
  Future<User> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException(
              'Email is already in use. Please try another email or sign in.');
        case 'weak-password':
          throw AuthException(
              'Password is too weak. Please use a stronger password.');
        case 'invalid-email':
          throw AuthException(
              'Invalid email format. Please provide a valid email.');
        default:
          throw AuthException('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  // Login with email and password
  Future<User> loginWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthException(
              'No user found with this email. Please register first.');
        case 'wrong-password':
          throw AuthException('Incorrect password. Please try again.');
        case 'user-disabled':
          throw AuthException(
              'This account has been disabled. Please contact support.');
        case 'invalid-email':
          throw AuthException(
              'Invalid email format. Please provide a valid email.');
        default:
          throw AuthException('Login failed: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user!;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No user found with this email.');
        case 'invalid-email':
          throw AuthException(
              'Invalid email format. Please provide a valid email.');
        default:
          throw AuthException('Password reset failed: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw AuthException('Failed to send verification email: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
    } catch (e) {
      throw AuthException('Failed to update display name: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      // Re-authenticate user before changing password
      final user = _firebaseAuth.currentUser;
      final email = user?.email;

      if (user == null || email == null) {
        throw AuthException('No user is currently logged in');
      }

      // Create credential for re-authentication
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      // Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw AuthException(
              'New password is too weak. Please use a stronger password.');
        case 'requires-recent-login':
          throw AuthException(
              'This operation requires recent authentication. Please log in again before retrying.');
        default:
          throw AuthException('Failed to change password: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Failed to change password: ${e.toString()}');
    }
  }

  // Delete user account
  Future<void> deleteAccount(String password) async {
    try {
      // Re-authenticate user before deleting account
      final user = _firebaseAuth.currentUser;
      final email = user?.email;

      if (user == null || email == null) {
        throw AuthException('No user is currently logged in');
      }

      // Create credential for re-authentication
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // Delete account
      await user.delete();
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
