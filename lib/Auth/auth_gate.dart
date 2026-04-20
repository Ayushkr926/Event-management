import 'package:event_management/Home/home_screen.dart';
import 'package:event_management/Onboarding/onboarding.dart';
import 'package:event_management/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Listens to Firebase auth state and routes accordingly.
/// Also loads user data from Firestore into UserService when authenticated.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xffF2F862),
              ),
            ),
          );
        }

        // Authenticated
        if (snapshot.hasData) {
          // Load user data from Firestore
          final userService = Provider.of<UserService>(context, listen: false);
          if (userService.currentUserModel == null ||
              userService.currentUserModel!.uid != snapshot.data!.uid) {
            userService.getUserById(snapshot.data!.uid);
          }
          return HomeScreen();
        }

        // Not authenticated
        return const OnboardingScreen();
      },
    );
  }
}
