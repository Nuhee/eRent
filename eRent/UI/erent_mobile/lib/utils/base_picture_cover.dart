import 'dart:convert';
import 'package:flutter/material.dart';

class BasePictureCover extends StatelessWidget {
  final String? base64;
  final double size;
  final IconData fallbackIcon;
  final Color borderColor;
  final Color iconColor;
  final Color backgroundColor;
  final double borderWidth;
  final bool showShadow;
  final BoxShape shape;
  final EdgeInsetsGeometry? padding;
  final Widget? overlay;

  const BasePictureCover({
    super.key,
    required this.base64,
    this.size = 140,
    this.fallbackIcon = Icons.account_circle,
    this.borderColor = const Color(0xFF6A1B9A),
    this.iconColor = const Color(0xFF6A1B9A),
    this.backgroundColor = const Color(0xFFFFF3E0),
    this.borderWidth = 2.0,
    this.showShadow = true,
    this.shape = BoxShape.circle,
    this.padding,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: shape == BoxShape.circle
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [_buildBackground(), if (overlay != null) overlay!],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (base64 == null || base64!.isEmpty) {
      return _buildFallback();
    }

    try {
      final bytes = base64Decode(base64!);
      return Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } catch (e) {
      return _buildFallback();
    }
  }

  Widget _buildFallback() {
    return Container(
      alignment: Alignment.center, // ✅ centers the icon
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
        ),
      ),
      child: Icon(fallbackIcon, size: size * 0.5, color: iconColor),
    );
  }
}
