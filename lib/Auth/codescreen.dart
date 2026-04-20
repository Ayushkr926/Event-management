import 'package:event_management/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/color.dart';

class Codescreen extends StatefulWidget {
  final String email;
  const Codescreen({super.key, required this.email});

  @override
  State<Codescreen> createState() => _CodescreenState();
}

class _CodescreenState extends State<Codescreen> {
  bool _linkSent = true; // The link was already sent from the onboarding screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Back
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              // 🔥 Title
              const Text(
                "Check your email",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              // ✉️ Subtitle
              Text(
                "We sent a sign-in link to\n${widget.email}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              // 📧 Email Link Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Open the link in your email to sign in",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "The link will automatically sign you into the app when opened on this device.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🔄 Resend Button
              TextButton(
                onPressed: _resendLink,
                child: const Text(
                  "Didn't receive the email? Resend",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),

              const Spacer(),

              // 📭 Open email app hint
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
                  onPressed: () {
                    // Just go back — the AuthGate will auto-navigate
                    // once the user clicks the email link
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Open the sign-in link from your email to continue',
                        ),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  },
                  child: const Text(
                    "I've opened the link",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resendLink() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.sendSignInLinkToEmail(widget.email).then((_) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in link resent! Check your email.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
