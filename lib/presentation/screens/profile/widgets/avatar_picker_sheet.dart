import 'package:flutter/material.dart';

class AvatarPickerSheet extends StatelessWidget {
  final List<String> avatarEmojis;
  final String selectedAvatar;
  final ValueChanged<String> onSelect;

  const AvatarPickerSheet({
    super.key,
    required this.avatarEmojis,
    required this.selectedAvatar,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Avatar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 8,
            shrinkWrap: true,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: avatarEmojis.map((emoji) {
              final isSelected = emoji == selectedAvatar;
              return GestureDetector(
                onTap: () {
                  onSelect(emoji);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6C63FF).withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
