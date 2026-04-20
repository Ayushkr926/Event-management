import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management/services/auth_service.dart';
import 'package:event_management/services/user_service.dart';
import 'package:event_management/utils/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Not logged in', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No profile data found',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final user = UserModel.fromDocument(snapshot.data!);

          return CustomScrollView(
            slivers: [
              // ─── PROFILE HEADER ───
              SliverToBoxAdapter(child: _buildProfileHeader(context, user)),

              // ─── STATS ROW ───
              SliverToBoxAdapter(child: _buildStatsRow(user)),

              // ─── PROFILE INFO SECTION ───
              SliverToBoxAdapter(child: _buildInfoSection(user)),

              // ─── SETTINGS SECTION ───
              SliverToBoxAdapter(child: _buildSettingsSection(context, user)),

              // ─── SIGN OUT ───
              SliverToBoxAdapter(child: _buildSignOutButton(context)),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  PROFILE HEADER
  // ─────────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        children: [
          // App bar row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              const Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                onPressed: () => _showEditProfileSheet(context, user),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.primary.withOpacity(0.3),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.seccard,
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 54, color: Colors.white54)
                      : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            user.displayName.isNotEmpty ? user.displayName : 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          // Provider badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.seccard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.provider == 'google'
                      ? Icons.g_mobiledata
                      : Icons.email_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Signed in via ${user.provider[0].toUpperCase()}${user.provider.substring(1)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Member since
          Text(
            'Member since ${DateFormat('MMMM yyyy').format(user.createdAt)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  STATS ROW
  // ─────────────────────────────────────────────────

  Widget _buildStatsRow(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('Logins', user.loginCount.toString(), Icons.login_rounded),
            _divider(),
            _statItem(
              'Verified',
              user.isEmailVerified ? 'Yes' : 'No',
              user.isEmailVerified
                  ? Icons.verified_rounded
                  : Icons.cancel_outlined,
            ),
            _divider(),
            _statItem(
              'Status',
              user.isActive ? 'Active' : 'Inactive',
              Icons.circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }

  // ─────────────────────────────────────────────────
  //  INFO SECTION
  // ─────────────────────────────────────────────────

  Widget _buildInfoSection(UserModel user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('PERSONAL INFO'),
          const SizedBox(height: 12),
          _infoTile(Icons.person_outline, 'Name', user.displayName.isNotEmpty ? user.displayName : '—'),
          _infoTile(Icons.email_outlined, 'Email', user.email),
          _infoTile(Icons.phone_outlined, 'Phone', user.phoneNumber.isNotEmpty ? user.phoneNumber : '—'),
          _infoTile(Icons.location_on_outlined, 'Location', user.location.isNotEmpty ? user.location : '—'),
          _infoTile(Icons.info_outline, 'Bio', user.bio.isNotEmpty ? user.bio : '—'),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  SETTINGS SECTION
  // ─────────────────────────────────────────────────

  Widget _buildSettingsSection(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('PREFERENCES'),
          const SizedBox(height: 12),
          _settingsTile(
            Icons.notifications_outlined,
            'Notifications',
            trailing: Switch.adaptive(
              value: user.preferences['notifications'] ?? true,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.4),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[800],
              onChanged: (val) {
                final userService = Provider.of<UserService>(context, listen: false);
                final updatedPrefs = Map<String, dynamic>.from(user.preferences);
                updatedPrefs['notifications'] = val;
                userService.updatePreferences(user.uid, updatedPrefs);
              },
            ),
          ),
          _settingsTile(
            Icons.dark_mode_outlined,
            'Dark Mode',
            trailing: Switch.adaptive(
              value: user.preferences['darkMode'] ?? true,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.4),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[800],
              onChanged: (val) {
                final userService = Provider.of<UserService>(context, listen: false);
                final updatedPrefs = Map<String, dynamic>.from(user.preferences);
                updatedPrefs['darkMode'] = val;
                userService.updatePreferences(user.uid, updatedPrefs);
              },
            ),
          ),
          _settingsTile(Icons.description_outlined, 'Terms & Conditions'),
          _settingsTile(Icons.lock_outline_rounded, 'Privacy Policy'),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.white70, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  SIGN OUT
  // ─────────────────────────────────────────────────

  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade900.withOpacity(0.4),
            foregroundColor: Colors.redAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.shade800.withOpacity(0.5)),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text(
            'Sign Out',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text('Sign Out',
                    style: TextStyle(color: Colors.white)),
                content: const Text('Are you sure you want to sign out?',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white54)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sign Out',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );

            if (confirmed == true && context.mounted) {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              // AuthGate will auto-redirect to onboarding
            }
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  EDIT PROFILE BOTTOM SHEET
  // ─────────────────────────────────────────────────

  void _showEditProfileSheet(BuildContext context, UserModel user) {
    final nameCtrl = TextEditingController(text: user.displayName);
    final bioCtrl = TextEditingController(text: user.bio);
    final locationCtrl = TextEditingController(text: user.location);
    final phoneCtrl = TextEditingController(text: user.phoneNumber);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _editField('Display Name', nameCtrl, Icons.person_outline),
                _editField('Bio', bioCtrl, Icons.info_outline, maxLines: 3),
                _editField('Location', locationCtrl, Icons.location_on_outlined),
                _editField('Phone', phoneCtrl, Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      final userService =
                          Provider.of<UserService>(context, listen: false);
                      userService.updateProfile(
                        uid: user.uid,
                        displayName: nameCtrl.text.trim(),
                        bio: bioCtrl.text.trim(),
                        location: locationCtrl.text.trim(),
                        phoneNumber: phoneCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: AppColors.cardcolor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}
