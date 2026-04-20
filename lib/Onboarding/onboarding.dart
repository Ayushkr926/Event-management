import 'package:event_management/utils/color.dart';
import 'package:event_management/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Auth/codescreen.dart';
import '../Home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;

  TextEditingController _emailctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1100), // 🔥 slower
        switchInCurve: Curves.easeOutQuart,
        switchOutCurve: Curves.easeInQuart,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.15), // 🔥 subtle movement
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: currentStep == 3
            ? emailcontainer(size)
            : onboardingFlow(size),
      ),



    );
  }


  Widget onboardingFlow(Size size) {
    return Column(
      key: const ValueKey("onboarding"),
      children: [
        SizedBox(
          height: size.height * 0.5,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "assets/images/onboarding1.jpg",
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            return SlideTransition(position: slide, child: child);
          },
          child: buildStep(size),
        ),
      ],
    );
  }


  // ================= STEP HANDLER =================

  Widget buildStep(Size size) {
    switch (currentStep) {
      case 0:
        return onboardingContainer(
          key: const ValueKey(0),
          size: size,
          title: "Event exploration\nmade simple",
          subtitle:
          "Discover, book, and track events seamlessly with calendar integration.",
        );
      case 1:
        return onboardingContainer(
          key: const ValueKey(1),
          size: size,
          title: "Never miss\na moment",
          subtitle:
          "Get reminders, personalized suggestions, and real-time updates.",
        );
      case 2:
        return authContainer(size);

      default:
        return const SizedBox();
    }
  }

  // ================= ONBOARDING CONTAINER =================

  Widget onboardingContainer({
    required Key key,
    required Size size,
    required String title,
    required String subtitle,
  }) {
    return Material(
      elevation: 7,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(48),
        topRight: Radius.circular(48),
      ),
      child: Container(
        key: key,
        height: size.height * 0.5,
        width: size.width,
        decoration: containerDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 17,
                height: 1.5,
              ),
            ),
            const Spacer(),
            navigationRow(),
          ],
        ),
      ),
    );
  }

  // ================= AUTH CONTAINER =================

  Widget authContainer(Size size) {
    return Container(
      key: const ValueKey(2),
      height: size.height * 0.5,
      width: size.width,
      decoration: containerDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Title
          const Text(
            "Get started",
            style: TextStyle(
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          // 🧠 Description
          const Text(
            "Register for events and create memories of the activities you plan to attend.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const Spacer(), // 🔥 Push buttons to bottom

          // 🔐 Auth Buttons
          authButton(
            icon: Image.asset(
              "assets/images/google.png",
              height: 22,
              width: 22,
            ),
            text: "Sign in with Google",
            onTap: () => _handleGoogleSignIn(context),
            bgcolor: Colors.white,
            fgcolor: Colors.black,
          ),
          const SizedBox(height: 14),
          authButton(
            icon: const Icon(
              Icons.email_outlined,
              color: Colors.white,
              size: 22,
            ),
            text: "Continue with Email",
            onTap: () {
              setState(() {
                currentStep++;
              });
            },
            bgcolor: const Color(0xff1E1E2A),
            fgcolor: Colors.white,
          ),

          const SizedBox(height: 14),

          authButton(
            icon: const Icon(
              Icons.phone_android,
              color: Colors.white,
              size: 22,
            ),
            text: "Continue with Phone",
            onTap: () {},
            bgcolor: const Color(0xff1E1E2A),
            fgcolor: Colors.white,
          ),

          const SizedBox(height: 18),

          // 🔁 Login Text
          Center(
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to login
              },
              child: const Text(
                "Already have an account? Log in",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  //continue with email==========================

  Widget emailcontainer(Size size) {
    return SafeArea(
      child: Container(
        key: const ValueKey("email"),
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          color: Colors.black,
          // borderRadius: const BorderRadius.only(
          //   topLeft: Radius.circular(48),
          //   topRight: Radius.circular(48),
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 180,
              spreadRadius: 2,
              offset: const Offset(0, -16),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔙 Back button
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                setState(() {
                  currentStep--;
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 Title
            const Text(
              "Continue with email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            // 🧠 Subtitle
            const Text(
              "Sign in or create a new account using your email address.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // 📧 Label
            const Text(
              "Email address",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // 📩 Email Input
            TextField(
              controller: _emailctrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xffF2F862),
              decoration: InputDecoration(
                hintText: "you@example.com",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xff181A25),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xffF2F862),
                    width: 1.2,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // 👉 Continue Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _handleEmailContinue(context),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 🔐 Footer text
            Center(
              child: Text(
                "We’ll never share your email with anyone.",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ================= NAVIGATION =================

  Widget navigationRow() {
    return Row(
      children: [
        // ⬅️ PREV (only show if not first step)
        if (currentStep > 0)
          GestureDetector(
            onTap: () {
              setState(() {
                currentStep--;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xffF2F862),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Prev",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        const SizedBox(width: 16),

        // ●●● INDICATORS (CENTERED)
        indicator(0),
        const SizedBox(width: 8),
        indicator(1),
        const SizedBox(width: 8),
        indicator(2),

        const Spacer(),

        // ➡️ NEXT (only till step 1)
        if (currentStep < 2)
          GestureDetector(
            onTap: () {
              setState(() {
                currentStep++;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xffF2F862),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Next",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }


  Widget navigationRowback() {
    return Row(
      children: [
        indicator(0),
        const SizedBox(width: 8),
        indicator(1),
        const SizedBox(width: 8),
        indicator(2),
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              if (currentStep >0) currentStep--;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xffF2F862),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Prev",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }



  // ================= UI HELPERS =================

  BoxDecoration containerDecoration() {
    return BoxDecoration(
      color: Colors.black,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(48),
        topRight: Radius.circular(48),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.2),
          blurRadius: 180,
          spreadRadius: 2,
          offset: const Offset(0, -16),
        ),
      ],
    );
  }

  Widget indicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: currentStep == index ? 32 : 14,
      height: 8,
      decoration: BoxDecoration(
        color:
        currentStep == index ? const Color(0xffF2F862) : Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget authButton({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
    required Color bgcolor,
    required Color fgcolor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: bgcolor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3)
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: fgcolor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= AUTH HANDLERS =================

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.signInWithGoogle();

    if (!mounted) return;

    if (result != null) {
      // Auth state change will trigger AuthGate to navigate
      // No manual navigation needed
    } else if (authService.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.error!),
          backgroundColor: Colors.red.shade700,
        ),
      );
      authService.clearError();
    }
  }

  void _handleEmailContinue(BuildContext context) {
    final email = _emailctrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    // Send email link for passwordless sign-in
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.sendSignInLinkToEmail(email).then((_) {
      if (!mounted) return;
      if (authService.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.error!),
            backgroundColor: Colors.red.shade700,
          ),
        );
        authService.clearError();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Codescreen(email: email),
          ),
        );
      }
    });
  }
}
