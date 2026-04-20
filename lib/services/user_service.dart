import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management/model/user_model.dart';
import 'package:flutter/foundation.dart';

/// Dedicated service for all Firestore user CRUD operations.
class UserService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'users';

  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;

  /// Reference to the users collection
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(_collection);

  // ─────────────────────────────────────────────────
  //  CREATE / UPDATE USER
  // ─────────────────────────────────────────────────

  /// Create or update user document after sign-in.
  /// For new users: creates full document with createdAt.
  /// For returning users: merges updated fields (lastLoginAt, loginCount, etc.)
  Future<UserModel> createOrUpdateUser({
    required String uid,
    required String email,
    required String provider,
    String displayName = '',
    String photoUrl = '',
    String phoneNumber = '',
    bool isEmailVerified = false,
    Map<String, dynamic>? authMetadata,
  }) async {
    debugPrint('[UserService] createOrUpdateUser called for uid=$uid, email=$email');

    final docRef = _usersRef.doc(uid);
    final docSnapshot = await docRef.get();
    final now = DateTime.now();

    if (docSnapshot.exists) {
      // ── Returning user: update login info ──
      debugPrint('[UserService] Returning user — updating login data...');
      final existingData = docSnapshot.data()!;
      final currentLoginCount = existingData['loginCount'] ?? 0;

      final updateData = <String, dynamic>{
        'lastLoginAt': Timestamp.fromDate(now),
        'loginCount': currentLoginCount + 1,
        'isEmailVerified': isEmailVerified,
        'displayName': displayName.isNotEmpty
            ? displayName
            : existingData['displayName'] ?? '',
        'photoUrl':
            photoUrl.isNotEmpty ? photoUrl : existingData['photoUrl'] ?? '',
        'phoneNumber': phoneNumber.isNotEmpty
            ? phoneNumber
            : existingData['phoneNumber'] ?? '',
      };

      if (authMetadata != null) {
        updateData['metadata'] = {
          ...Map<String, dynamic>.from(existingData['metadata'] ?? {}),
          ...authMetadata,
        };
      }

      await docRef.update(updateData);
      debugPrint('[UserService] Returning user updated successfully!');

      // Fetch latest and cache
      final updated = await docRef.get();
      _currentUserModel = UserModel.fromDocument(updated);
    } else {
      // ── New user: create full document ──
      debugPrint('[UserService] New user — creating Firestore document...');
      final userModel = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
        provider: provider,
        createdAt: now,
        lastLoginAt: now,
        isEmailVerified: isEmailVerified,
        isActive: true,
        loginCount: 1,
        preferences: {
          'notifications': true,
          'darkMode': true,
          'language': 'en',
        },
        metadata: authMetadata ?? {},
      );

      await docRef.set(userModel.toMap());
      debugPrint('[UserService] New user document created successfully!');
      _currentUserModel = userModel;
    }

    notifyListeners();
    return _currentUserModel!;
  }

  // ─────────────────────────────────────────────────
  //  READ
  // ─────────────────────────────────────────────────

  /// Fetch user by UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (doc.exists) {
        _currentUserModel = UserModel.fromDocument(doc);
        notifyListeners();
        return _currentUserModel;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  /// Stream of user document changes (real-time updates)
  Stream<UserModel?> userStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    });
  }

  // ─────────────────────────────────────────────────
  //  UPDATE FIELDS
  // ─────────────────────────────────────────────────

  /// Update specific user profile fields
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? location,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (location != null) updates['location'] = location;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isNotEmpty) {
      await _usersRef.doc(uid).update(updates);

      // Refresh cached model
      if (_currentUserModel?.uid == uid) {
        _currentUserModel = _currentUserModel!.copyWith(
          displayName: displayName,
          bio: bio,
          location: location,
          phoneNumber: phoneNumber,
          photoUrl: photoUrl,
        );
        notifyListeners();
      }
    }
  }

  /// Update user preferences
  Future<void> updatePreferences(
      String uid, Map<String, dynamic> preferences) async {
    await _usersRef.doc(uid).update({'preferences': preferences});
    if (_currentUserModel?.uid == uid) {
      _currentUserModel = _currentUserModel!.copyWith(preferences: preferences);
      notifyListeners();
    }
  }

  /// Add an FCM token for push notifications
  Future<void> addFcmToken(String uid, String token) async {
    await _usersRef.doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  /// Remove an FCM token
  Future<void> removeFcmToken(String uid, String token) async {
    await _usersRef.doc(uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }

  // ─────────────────────────────────────────────────
  //  DEACTIVATE / DELETE
  // ─────────────────────────────────────────────────

  /// Soft-delete: deactivate account
  Future<void> deactivateAccount(String uid) async {
    await _usersRef.doc(uid).update({'isActive': false});
  }

  /// Hard delete user document
  Future<void> deleteUser(String uid) async {
    await _usersRef.doc(uid).delete();
    if (_currentUserModel?.uid == uid) {
      _currentUserModel = null;
      notifyListeners();
    }
  }

  /// Clear cached user on sign-out
  void clearCurrentUser() {
    _currentUserModel = null;
    notifyListeners();
  }
}
