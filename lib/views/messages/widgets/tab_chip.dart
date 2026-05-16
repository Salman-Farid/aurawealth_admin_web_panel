import 'package:flutter/material.dart';

class TabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const TabChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
