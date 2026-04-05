import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppIconLayer { onSurface, onPrimary, onSecondary, error, success }

class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final AppIconLayer layer;
  final VoidCallback? onTap;

  const AppIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
    this.layer = AppIconLayer.onSurface,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Icon iconWidget = Icon(
      icon,
      size: size,
      color: color ?? _getLayerColor(),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: Padding(padding: const EdgeInsets.all(4.0), child: iconWidget),
      );
    }

    return iconWidget;
  }

  Color _getLayerColor() {
    switch (layer) {
      case AppIconLayer.onSurface:
        return AppColors.onSurface;
      case AppIconLayer.onPrimary:
        return AppColors.onPrimary;
      case AppIconLayer.onSecondary:
        return AppColors.onSecondaryContainer;
      case AppIconLayer.error:
        return AppColors.error;
      case AppIconLayer.success:
        return AppColors.success;
    }
  }
}
