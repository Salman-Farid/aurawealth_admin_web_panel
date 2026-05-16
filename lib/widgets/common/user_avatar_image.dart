import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user.dart';

class UserAvatarImage extends StatelessWidget {
  final User user;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const UserAvatarImage({
    super.key,
    required this.user,
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _validImageUrl(user.photoUrl);
    final bgColor = backgroundColor ?? AppColors.primary.withValues(alpha: 0.1);
    final fgColor = foregroundColor ?? AppColors.primary;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? _Initials(user: user, radius: radius, color: fgColor)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              // Flutter Web can fail Firebase Storage images with
              // `statusCode: 0` when the renderer tries to fetch/decode the
              // image through the canvas pipeline. Let the browser render the
              // image as an HTML element instead; the same URL already works
              // directly in the browser.
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: radius * 0.7,
                    height: radius * 0.7,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes == null
                          ? null
                          : loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!,
                    ),
                  ),
                );
              },
              errorBuilder: (_, error, _) {
                debugPrint(
                  '⚠️ User avatar image failed: user=${user.displayName} url=$imageUrl error=$error',
                );
                return _Initials(user: user, radius: radius, color: fgColor);
              },
            ),
    );
  }

  String? _validImageUrl(String? url) {
    if (url == null) return null;
    final cleaned = url.trim();
    if (cleaned.isEmpty || cleaned.toLowerCase() == 'null') return null;
    if (cleaned.toLowerCase().contains('/null')) return null;
    return cleaned;
  }
}

class _Initials extends StatelessWidget {
  final User user;
  final double radius;
  final Color color;

  const _Initials({
    required this.user,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        user.initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
