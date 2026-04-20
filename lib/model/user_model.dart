import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phoneNumber;
  final String provider;           // 'google', 'email', 'phone'
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isEmailVerified;
  final bool isActive;
  final String bio;
  final String location;
  final int loginCount;
  final List<String> fcmTokens;    // for push notifications
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> metadata;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
    this.phoneNumber = '',
    required this.provider,
    required this.createdAt,
    required this.lastLoginAt,
    this.isEmailVerified = false,
    this.isActive = true,
    this.bio = '',
    this.location = '',
    this.loginCount = 1,
    this.fcmTokens = const [],
    this.preferences = const {},
    this.metadata = const {},
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'provider': provider,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'bio': bio,
      'location': location,
      'loginCount': loginCount,
      'fcmTokens': fcmTokens,
      'preferences': preferences,
      'metadata': metadata,
    };
  }

  /// Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      provider: map['provider'] ?? 'unknown',
      createdAt: _parseTimestamp(map['createdAt']),
      lastLoginAt: _parseTimestamp(map['lastLoginAt']),
      isEmailVerified: map['isEmailVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      bio: map['bio'] ?? '',
      location: map['location'] ?? '',
      loginCount: map['loginCount'] ?? 1,
      fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Create from Firestore DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  /// Copy with updated fields
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    String? location,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? lastLoginAt,
    int? loginCount,
    List<String>? fcmTokens,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      provider: provider,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      loginCount: loginCount ?? this.loginCount,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
