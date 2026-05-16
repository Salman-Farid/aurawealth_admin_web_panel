import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../transaction_constants.dart';

class TypeIcon extends StatelessWidget {
  final String type;
  final double size;
  const TypeIcon({super.key, required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final clr = typeColor(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: clr.withOpacity(0.08),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: clr.withOpacity(0.22), width: 1),
      ),
      padding: EdgeInsets.all(size * 0.18),
      child: CachedNetworkImage(
        imageUrl: pngForType(type),
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) =>
            Icon(iconForType(type), color: clr, size: size * 0.52),
      ),
    );
  }
}
