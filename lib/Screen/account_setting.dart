import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../provider/account_setting_provider.dart';
import '../provider/profile_provider.dart';
import '../utils/color.dart'; // ← your AppColors

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsEnabledProvider);
    final email = ref.watch(emailEnabledProvider);
    final location = ref.watch(locationEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Account Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Profile Section
          _buildSectionHeader("Profile"),
          const SizedBox(height: 8),
          ProfileHeader(),

          const SizedBox(height: 24),

          // Communication Preferences
          _buildSectionHeader("Communication Preferences"),
          const SizedBox(height: 8),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            subtitle:
            "Receive personalized notifications about top events i...",
            value: notifications,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              ref.read(notificationsEnabledProvider.notifier).state = val;
            },
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle:
            "Receive discount vouchers, exclusive offers and the latest...",
            value: email,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              ref.read(emailEnabledProvider.notifier).state = val;
            },
          ),

          const SizedBox(height: 24),

          // Location Permission
          _buildSectionHeader("Location permission"),
          const SizedBox(height: 8),
          _buildSwitchTile(
            icon: Icons.location_on_outlined,
            title: "Enable My Location",
            subtitle:
            "Your location is used to improve your experience",
            value: location,
            onChanged: (val) async {
              HapticFeedback.lightImpact();
              // In real app → request permission here
              // e.g. using permission_handler package
              ref.read(locationEnabledProvider.notifier).state = val;
              if (val) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Location permission requested")),
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Legal
          _buildSectionHeader("Legal"),
          const SizedBox(height: 8),
          _buildListTile(
            icon: Icons.description_outlined,
            title: "Terms & Conditions",
            subtitle: null,
            trailing: null,
            onTap: () {
              // TODO: Open terms page / webview
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Terms & Conditions tapped")),
              );
            },
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildListTile(
            icon: Icons.lock_outline_rounded,
            title: "Privacy Policy",
            subtitle: null,
            trailing: null,
            onTap: () {
              // TODO: Open privacy page / webview
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Privacy Policy tapped")),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: Icon(icon, color: Colors.white70, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13,
          ),
        ),
      )
          : null,
      trailing: trailing ?? const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white54,
        size: 26,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: Icon(icon, color: Colors.white70, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13,
          ),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xffF3FF5A),
        activeTrackColor: const Color(0xffF3FF5A).withOpacity(0.4),
        inactiveThumbColor: Colors.grey[400],
        inactiveTrackColor: Colors.grey[800],
        onChanged: onChanged,
        thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
              (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? const Icon(Icons.check_rounded, color: Colors.black)
              : null,
        ),
      ),
    );
  }
}





class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile picture
          GestureDetector(
            onTap: () {
              // TODO: open image picker / camera / gallery
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Change profile picture tapped")),
              );
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 62,
                  backgroundColor: AppColors.primary.withOpacity(0.3),
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: AppColors.seccard,
                    backgroundImage: profile.profileImageUrl != null
                        ? AssetImage(profile.profileImageUrl!) as ImageProvider
                        : const NetworkImage("https://via.placeholder.com/150") as ImageProvider,
                    child: profile.profileImageUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white54)
                        : null,
                  ),
                ),
                // Edit icon overlay
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Name & username
          Text(
            profile.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.username,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Email (partially hidden)
          Text(
            _obscureEmail(profile.email),
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),

          // Join date
          Text(
            "Member since ${DateFormat('MMMM yyyy').format(profile.joinDate)}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // Badges
          if (profile.badges.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: profile.badges.map((badge) {
                final isVIP = badge.toLowerCase().contains("vip");
                final isOrganizer = badge.toLowerCase().contains("organizer");

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isVIP || isOrganizer
                        ? LinearGradient(
                      colors: [const Color(0xffF3FF5A), const Color(0xffFFD700)],
                    )
                        : null,
                    color: isVIP || isOrganizer ? null : AppColors.seccard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isVIP || isOrganizer
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.2),
                    ),
                    boxShadow: isVIP || isOrganizer
                        ? [
                      BoxShadow(
                        color: const Color(0xffF3FF5A).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                        : null,
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: isVIP || isOrganizer ? Colors.black : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _obscureEmail(String email) {
    if (email.isEmpty) return "";
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    if (local.length <= 3) return email;
    final obscured = '${local.substring(0, 3)}${'*' * (local.length - 5)}${local.substring(local.length - 2)}@${parts[1]}';
    return obscured;
  }
}