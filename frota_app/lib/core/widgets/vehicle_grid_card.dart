import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'status_badge.dart';

class VehicleGridCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleGridCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    vehicle.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceContainerLow,
                      child: const Icon(Icons.directions_car, color: AppColors.primary, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StatusBadge(
                      label: vehicle.status == VehicleStatus.rented 
                          ? 'ALUGADO' 
                          : (vehicle.status == VehicleStatus.available 
                              ? 'LIVRE' 
                              : (vehicle.status == VehicleStatus.sold ? 'VENDIDO' : 'MANUTENÇÃO')),
                      type: _getTypeByStatus(vehicle.status),
                    ),
                  ),
                ],
              ),
            ),
            // Vehicle Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.brand} ${vehicle.model}',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Placa: ${vehicle.plate}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ALUGUEL',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 8,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'R\$ ${vehicle.rentalValue?.toStringAsFixed(0) ?? '0'}',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.outlineVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BadgeType _getTypeByStatus(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return BadgeType.active;
      case VehicleStatus.rented:
        return BadgeType.neutral;
      case VehicleStatus.maintenance:
        return BadgeType.error;
      case VehicleStatus.sold:
        return BadgeType.neutral;
    }
  }
}
