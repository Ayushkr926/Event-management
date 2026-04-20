import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService;

  AuthService({required UserService userService})
      : _userService = userService;

  // Current Firebase user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;

  // Email link sent state
  bool _emailLinkSent = false;
  bool get emailLinkSent => _emailLinkSent;

  // ─────────────────────────────────────────────────
  //  GOOGLE SIGN-IN
  // ─────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Save full user data to Firestore
      await _saveUserData(userCredential, 'google');

      _isLoading = false;
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ─────────────────────────────────────────────────
  //  EMAIL LINK (PASSWORDLESS) SIGN-IN
  // ─────────────────────────────────────────────────

  /// Send a sign-in link to the user's email
  Future<void> sendSignInLinkToEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      _emailLinkSent = false;
      notifyListeners();

      final actionCodeSettings = ActionCodeSettings(
        url: 'https://eventmanagement.page.link/email-signin',
        handleCodeInApp: true,
        androidPackageName: 'com.example.event_management',
        androidInstallApp: true,
        androidMinimumVersion: '23',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      _emailLinkSent = true;
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify the email sign-in link
  Future<UserCredential?> signInWithEmailLink(
      String email, String emailLink) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      // Save user data to Firestore
      await _saveUserData(userCredential, 'email');

      _isLoading = false;
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Check if a link is a sign-in email link
  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  // ─────────────────────────────────────────────────
  //  EMAIL + PASSWORD SIGN-IN (FALLBACK)
  // ─────────────────────────────────────────────────

  /// Register a new user with email and password
  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Save user data to Firestore
      await _saveUserData(userCredential, 'email');

      _isLoading = false;
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Sign in an existing user with email and password
  Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update login data in Firestore
      await _saveUserData(userCredential, 'email');

      _isLoading = false;
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ─────────────────────────────────────────────────
  //  SIGN OUT
  // ─────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _userService.clearCurrentUser();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────
  //  SAVE USER DATA (PRIVATE)
  // ─────────────────────────────────────────────────

  /// Delegates to UserService to create/update the Firestore user document
  /// with all available metadata from the FirebaseAuth user.
  Future<void> _saveUserData(
      UserCredential userCredential, String provider) async {
    final user = userCredential.user;
    if (user == null) {
      debugPrint('[AuthService] _saveUserData: user is null, skipping.');
      return;
    }

    debugPrint('[AuthService] Saving user data to Firestore for uid=${user.uid}, email=${user.email}');

    try {
      await _userService.createOrUpdateUser(
        uid: user.uid,
        email: user.email ?? '',
        provider: provider,
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL ?? '',
        phoneNumber: user.phoneNumber ?? '',
        isEmailVerified: user.emailVerified,
        authMetadata: {
          'lastSignInTime':
              user.metadata.lastSignInTime?.toIso8601String() ?? '',
          'creationTime':
              user.metadata.creationTime?.toIso8601String() ?? '',
          'providerId': user.providerData.isNotEmpty
              ? user.providerData.first.providerId
              : provider,
          'tenantId': user.tenantId ?? '',
          'isAnonymous': user.isAnonymous,
        },
      );
      debugPrint('[AuthService] User data saved successfully!');
    } catch (e, stackTrace) {
      debugPrint('[AuthService] ERROR saving user to Firestore: $e');
      debugPrint('[AuthService] Stack trace: $stackTrace');
    }
  }
}
