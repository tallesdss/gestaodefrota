import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'status_badge.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                vehicle.imageUrl,
                width: 80,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 60,
                  color: AppColors.surfaceContainerLow,
                  child: const Icon(Icons.directions_car, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vehicle.plate,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      StatusBadge(
                        label: vehicle.status == VehicleStatus.available 
                            ? 'LIVRE' 
                            : (vehicle.status == VehicleStatus.rented 
                                ? 'ALUGADO' 
                                : (vehicle.status == VehicleStatus.sold ? 'VENDIDO' : 'MANUTENÇÃO')),
                        type: _getTypeByStatus(vehicle.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.brand} ${vehicle.model} • ${vehicle.year}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${vehicle.currentKm} km',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BadgeType _getTypeByStatus(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available: return BadgeType.active;
      case VehicleStatus.rented: return BadgeType.neutral;
      case VehicleStatus.maintenance: return BadgeType.error;
      case VehicleStatus.sold: return BadgeType.neutral;
    }
  }
}
