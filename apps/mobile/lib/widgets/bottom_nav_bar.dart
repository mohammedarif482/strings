import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/aivo_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onOpenCheckIn;

  const BottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
    required this.onOpenCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF16141B).withOpacity(0.85),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tab 0: Home
                    _NavItem(
                      icon: Icons.home_rounded,
                      isSelected: activeIndex == 0,
                      onTap: () => onTabSelected(0),
                    ),

                    // Tab 1: Guided Player
                    _NavItem(
                      icon: Icons.star_rounded,
                      isSelected: activeIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),

                    // Center Glowing FAB
                    GestureDetector(
                      onTap: onOpenCheckIn,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AivoColors.orangeLight,
                              Color(0xFFFF5E1E),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFFFA566).withOpacity(0.6),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AivoColors.orange.withOpacity(0.6),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wb_sunny_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Tab 2: AI Insights
                    _NavItem(
                      icon: Icons.insights_rounded,
                      isSelected: activeIndex == 2,
                      onTap: () => onTabSelected(2),
                    ),

                    // Tab 3: Profile
                    _NavItem(
                      icon: Icons.person_rounded,
                      isSelected: activeIndex == 3,
                      onTap: () => onTabSelected(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : AivoColors.textMuted,
        size: 24,
      ),
      onPressed: onTap,
    );
  }
}
