

import 'dart:ui';

import 'package:event_management/utils/color.dart';
import 'package:flutter/material.dart';

import 'Create_event/screen/create_event_screen.dart';
import 'Home/home_screen.dart';
import 'Screen/create_event_screen.dart';
import 'Screen/explore_screen.dart';
import 'Screen/profile_screen.dart';

enum NavItem { home, explore, ticket, profile }


class FloatingBottomNav extends StatefulWidget {
  const FloatingBottomNav({super.key});

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav> {
  NavItem selected = NavItem.home;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child:ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 74, // 🔥 Bottom Nav Height (perfect)
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.55),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              // border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(NavItem.home, Icons.home_rounded, "Home"),
                _navItem(NavItem.explore, Icons.search_rounded, "Explore"),
                _navItem(
                    NavItem.ticket,
                    Icons.add_circle_outline,
                    "Create"),
                _navItem(
                    NavItem.profile,
                    Icons.person_outline_rounded,
                    "Profile"),
              ],
            ),
          ),
        ),
      )


    );
  }
  Widget _navItem(NavItem item, IconData icon, String label) {
    final bool isActive = selected == item;

    return GestureDetector(
      onTap: () {
        if (selected == item) return;

        setState(() => selected = item);

        _navigateTo(item);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
        ),
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.seccard,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? AppColors.primaryDark
                  : AppColors.textSecondary,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  void _navigateTo(NavItem item) {
    Widget page;

    switch (item) {
      case NavItem.home:
        page =  HomeScreen();
        break;
      case NavItem.explore:
        page = const ExploreScreen();
        break;
      case NavItem.ticket:
        page = const CreateEventScreen();
        break;
      case NavItem.profile:
        page = const ProfileScreen();
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

}
