import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/Admin Panel.json',
              width: 250,
              height: 250,
              repeat: false,
            ),
            const SizedBox(height: 16),
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      )
          .animate()
          .scale(begin: const Offset(0.8, 0.8), duration: 300.ms)
          .fadeIn(duration: 300.ms),
    );
  }
}
