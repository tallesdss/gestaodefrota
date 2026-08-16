import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
  });

  String _getInitials(String? text) {
    if (text == null || text.trim().isEmpty) return '?';
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(1, 2)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.secondaryContainer;
    final effectiveText = textColor ?? AppColors.onSecondaryContainer;
    final size = radius * 2;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(effectiveBg, effectiveText),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              color: effectiveBg,
              child: Center(
                child: SizedBox(
                  width: radius * 0.8,
                  height: radius * 0.8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveText),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return _buildFallback(effectiveBg, effectiveText);
  }

  Widget _buildFallback(Color bg, Color text) {
    final initials = _getInitials(name);
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: initials == '?'
          ? Icon(
              Icons.person,
              size: radius * 1.1,
              color: text,
            )
          : Text(
              initials,
              style: AppTextStyles.labelMedium.copyWith(
                color: text,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.75,
              ),
            ),
    );
  }
}
