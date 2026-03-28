import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileHeader extends StatelessWidget {
  final String selectedAvatar;
  final String displayName;
  final String email;
  final VoidCallback onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.selectedAvatar,
    required this.displayName,
    required this.email,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      selectedAvatar,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0A0E27),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
    );
  }
}
