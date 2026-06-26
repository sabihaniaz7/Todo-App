import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service class handling Firebase Authentication operations
/// including email/password sign up, email/password login, and Google sign-in.
class AuthService {
  static const String _serverClientId =
      '642654545106-6n9nvecvrpce830u8p3217hbjqj2m18g.apps.googleusercontent.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final Future<void> _googleSignInInitialized = GoogleSignIn.instance
      .initialize(serverClientId: _serverClientId);

  /// Signs up a new user using their [name], [email] and [password].
  ///
  /// Returns a [UserCredential] upon successful registration.
  Future<UserCredential> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Update the user's display name after account creation
    await userCredential.user?.updateDisplayName(name);
    return userCredential;
  }

  /// Logs in an existing user using their [email] and [password].
  ///
  /// Returns a [UserCredential] upon successful authentication.
  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Authenticates the user using Google Sign-In and registers the credentials with Firebase.
  ///
  /// Returns a [UserCredential] if the sign-in is successful, or `null` if the user cancelled.
  /// Throws an exception for any other failure so the caller can display the real error.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignInInitialized;

      // Trigger the interactive Google sign-in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();
      // IF the user physically closes the dialog box, googleUser returns null
      if (googleUser == null) return null;
      // Obtain the authentication details containing the idToken
      final googleAuth = googleUser.authentication;

      // Generate a credential package for Firebase to digest natively
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign into Firebase utilizing the verified token passport
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      // Rethrow so the UI layer can display the actual error message
      rethrow;
    }
  }

  /// Terminates active sessions for both Google Sign-In and Firebase.
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
