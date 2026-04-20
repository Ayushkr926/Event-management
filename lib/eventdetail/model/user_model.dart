class UserProfile {
  final String displayName;
  final String username;
  final String email;
  final DateTime joinDate;
  final String? profileImageUrl; // local path or network URL
  final List<String> badges; // e.g. ["Verified", "VIP", "Organizer"]

  UserProfile({
    required this.displayName,
    required this.username,
    required this.email,
    required this.joinDate,
    this.profileImageUrl,
    this.badges = const [],
  });
}