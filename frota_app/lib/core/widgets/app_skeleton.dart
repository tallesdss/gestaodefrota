import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  /// Skeleton para um Card
  factory AppSkeleton.card({double? height}) => AppSkeleton(
    height: height ?? 160,
    width: double.infinity,
    borderRadius: 16,
  );

  /// Skeleton para uma Linha de Texto
  factory AppSkeleton.text({double? width}) =>
      AppSkeleton(height: 16, width: width ?? 200, borderRadius: 4);

  /// Skeleton para um Avatar
  factory AppSkeleton.avatar({double size = 48}) =>
      AppSkeleton(width: size, height: size, shape: BoxShape.circle);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerLow,
      highlightColor: AppColors.surfaceContainerLowest,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(borderRadius),
          shape: shape,
        ),
      ),
    );
  }
}
