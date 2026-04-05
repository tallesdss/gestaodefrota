import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DashboardChart extends StatelessWidget {
  const DashboardChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Visão Financeira',
                style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
              ),
              const Row(
                children: [
                  _LegendItem(label: 'Receita', color: Color(0xFF00236F)),
                  SizedBox(width: 12),
                  _LegendItem(label: 'Despesa', color: Color(0xFFF5A623)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.outlineVariant.withAlpha(
                      (0.1 * 255).toInt(),
                    ),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['01', '05', '10', '15', '20', '25', '30'];
                        if (value >= 0 && value < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1500),
                      FlSpot(1, 1800),
                      FlSpot(2, 2200),
                      FlSpot(3, 2000),
                      FlSpot(4, 3000),
                      FlSpot(5, 3500),
                      FlSpot(6, 4000),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha((0.1 * 255).toInt()),
                          AppColors.primary.withAlpha(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 800),
                      FlSpot(1, 1200),
                      FlSpot(2, 900),
                      FlSpot(3, 1500),
                      FlSpot(4, 2000),
                      FlSpot(5, 1800),
                      FlSpot(6, 2500),
                    ],
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.labelMedium.copyWith(fontSize: 12)),
      ],
    );
  }
}
