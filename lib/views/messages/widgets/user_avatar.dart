import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;

  const UserAvatar({
    super.key,
    required this.name,
    required this.size,
    this.imageUrl,
  });

  static const _palette = [
    Color(0xFF4F8EF7),
    Color(0xFF7C5CBF),
    Color(0xFF43C6AC),
    Color(0xFFFF6B6B),
    Color(0xFFFFB347),
  ];

  @override
  Widget build(BuildContext context) {
    final safeName = name.trim().isNotEmpty ? name.trim() : 'User';
    final initial = safeName[0].toUpperCase();
    final color = _palette[safeName.codeUnitAt(0) % _palette.length];
    final validImageUrl = _validImageUrl(imageUrl);

    final hasImage = validImageUrl != null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasImage ? Colors.white : color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: hasImage
              ? const Color(0xFFE5E7EB)
              : color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              validImageUrl,
              fit: BoxFit.cover,
              // Use the browser's <img> element on Flutter Web so Firebase
              // Storage URLs that work in the browser are not rejected by the
              // canvas image fetch/decode path with statusCode 0.
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: size * 0.35,
                    height: size * 0.35,
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
                  '⚠️ Message avatar image failed: $validImageUrl error=$error',
                );
                return _InitialAvatar(
                  initial: initial,
                  color: color,
                  size: size,
                );
              },
            )
          : _InitialAvatar(initial: initial, color: color, size: size),
    );
  }

  String? _validImageUrl(String? url) {
    if (url == null) return null;
    final cleaned = url.trim();
    if (cleaned.isEmpty || cleaned.toLowerCase() == 'null') return null;
    return cleaned;
  }
}

class _InitialAvatar extends StatelessWidget {
  final String initial;
  final Color color;
  final double size;

  const _InitialAvatar({
    required this.initial,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
