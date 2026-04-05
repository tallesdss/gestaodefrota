import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class FleetStatusChart extends StatelessWidget {
  const FleetStatusChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status da Frota',
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 60,
                    sections: _getSections(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '89%',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'ATIVOS',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _LegendItem(color: AppColors.primary, label: 'Alugado', count: 58),
          const SizedBox(height: AppSpacing.sm),
          _LegendItem(
            color: AppColors.surfaceContainerLow,
            label: 'Disponível',
            count: 5,
          ),
          const SizedBox(height: AppSpacing.sm),
          _LegendItem(color: AppColors.tertiary, label: 'Oficina', count: 2),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    return [
      PieChartSectionData(
        color: AppColors.primary,
        value: 58,
        title: '',
        radius: 20,
      ),
      PieChartSectionData(
        color: AppColors.surfaceContainerLow,
        value: 5,
        title: '',
        radius: 20,
      ),
      PieChartSectionData(
        color: AppColors.tertiary,
        value: 2,
        title: '',
        radius: 20,
      ),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
