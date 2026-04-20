import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../eventdetail/model/user_model.dart';


// Mock data – in real app load from auth / firestore / hive
final userProfileProvider = StateProvider<UserProfile>((ref) {
  return UserProfile(
    displayName: "Ayush Kumar",
    username: "@ayushk_07",
    email: "ayushkumar@example.com",
    joinDate: DateTime(2024, 3, 15),
    profileImageUrl: "assets/images/profile_placeholder.jpg", // or network
    badges: ["Early Bird", "VIP"],
  );
});