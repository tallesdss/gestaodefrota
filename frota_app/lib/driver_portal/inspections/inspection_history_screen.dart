import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frota_app/core/theme/app_colors.dart';
import 'package:frota_app/core/theme/app_text_styles.dart';
import 'package:frota_app/core/theme/app_spacing.dart';
import 'package:frota_app/core/widgets/app_icon.dart';

class InspectionHistoryScreen extends StatelessWidget {
  const InspectionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('HISTÓRICO DE VISTORIAS', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 2)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const AppIcon(icon: Icons.arrow_back),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final isCheckIn = index % 2 == 0;
          return _buildHistoryCard(
            type: isCheckIn ? 'CHECK-IN' : 'CHECK-OUT',
            date: '2${index + 1}/03/2026',
            time: '0${8 + index}:30',
            vehicle: 'VW VIRTUS - BRA2E24',
            status: index == 0 ? 'Recente' : 'Arquivado',
            isCheckIn: isCheckIn,
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard({
    required String type,
    required String date,
    required String time,
    required String vehicle,
    required String status,
    required bool isCheckIn,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isCheckIn ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isCheckIn ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                status,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const AppIcon(icon: Icons.directions_car_outlined, size: 20, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Text(vehicle, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const AppIcon(icon: Icons.calendar_today_outlined, size: 20, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Text('$date às $time', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('VER DETALHES', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}
