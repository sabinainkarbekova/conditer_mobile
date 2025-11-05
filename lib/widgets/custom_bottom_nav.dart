import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.pink[200]!,
            hoverColor: Colors.pink[100]!,
            haptic: true,
            tabBorderRadius: 15,
            tabActiveBorder: Border.all(color: Colors.pinkAccent, width: 1),
            tabBorder: Border.all(color: Colors.grey.shade300, width: 1),
            tabShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8)],
            curve: Curves.easeOutExpo,
            duration: const Duration(milliseconds: 700),
            gap: 8,
            color: Colors.grey[600],
            activeColor: Colors.white,
            iconSize: 26,
            tabBackgroundColor: const Color(0xFFF967A0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            tabs: const [
              GButton(icon: LineIcons.home, text: 'Home'),
              GButton(icon: LineIcons.heart, text: 'Likes'),
              GButton(icon: LineIcons.shoppingCart, text: 'Cart'),
              GButton(icon: LineIcons.user, text: 'Profile'),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}
