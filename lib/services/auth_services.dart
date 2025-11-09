import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AuthException implements Exception {
  final String message;
  final String? code;
  AuthException(this.message, [this.code]);
}

class AuthServices extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<UserCredential?> _handleWebSignIn() async {
    try {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({
        'prompt': 'select_account',
        'login_hint': '', 
      });

      UserCredential? credential;
      try {
        credential = await _auth.signInWithPopup(provider);
      } catch (e) {
        if (e is FirebaseAuthException && 
            (e.code == 'popup-blocked' || e.code == 'popup-closed-by-user')) {
          await _auth.signInWithRedirect(provider);
          credential = await _auth.getRedirectResult();
        } else {
          rethrow;
        }
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getReadableErrorMessage(e.code), e.code);
    }
  }

  Future<UserCredential?> _handleMobileSignIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Sign in was cancelled by user');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getReadableErrorMessage(e.code), e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  Future<User?> signInWithGoogle() async {
    if (_isLoading) return null;
    _setLoading(true);

    try {
      final credential = await (kIsWeb ? _handleWebSignIn() : _handleMobileSignIn());
      return credential?.user;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut().catchError((_) => null);
      }
      await _auth.signOut();
    } finally {
      _setLoading(false);
    }
  }

  String _getReadableErrorMessage(String code) {
    switch (code) {
      case 'popup-blocked':
        return 'Sign in popup was blocked. Please allow popups for this site.';
      case 'popup-closed-by-user':
        return 'Sign in was cancelled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      case 'network-request-failed':
        return 'Network error occurred. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled for this project.';
      case 'invalid-credential':
        return 'The sign-in credential is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'An error occurred during sign in. Please try again.';
    }
  }
}

