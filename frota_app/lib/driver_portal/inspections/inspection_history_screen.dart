import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frota_app/core/theme/app_colors.dart';
import 'package:frota_app/core/theme/app_text_styles.dart';
import 'package:frota_app/core/theme/app_spacing.dart';
import 'package:frota_app/core/widgets/app_icon.dart';
import 'package:frota_app/core/routes/app_routes.dart';

class InspectionHistoryScreen extends StatefulWidget {
  const InspectionHistoryScreen({super.key});

  @override
  State<InspectionHistoryScreen> createState() => _InspectionHistoryScreenState();
}

class _InspectionHistoryScreenState extends State<InspectionHistoryScreen> {
  String _selectedFilter = 'Tudo';
  final List<String> _filters = ['Tudo', 'Check-in', 'Check-out', 'Ocorrência'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'HISTÓRICO DE VISTORIAS',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const AppIcon(icon: Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: 10,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) {
                return _buildHistoryCard(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
      color: AppColors.surface,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por placa ou veículo...',
              prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (v) => setState(() => _selectedFilter = filter),
                    backgroundColor: AppColors.surfaceContainerLow,
                    selectedColor: AppColors.primary,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, int index) {
    // Mock data logic
    final isOccurrence = index == 2 || index == 5;
    final isCheckIn = !isOccurrence && index % 2 == 0;
    
    final type = isOccurrence ? 'OCORRÊNCIA' : (isCheckIn ? 'CHECK-IN' : 'CHECK-OUT');
    final typeColor = isOccurrence ? AppColors.error : (isCheckIn ? AppColors.success : AppColors.primary);
    final vehicle = index % 3 == 0 ? 'VW VIRTUS' : (index % 3 == 1 ? 'HYUNDAI HB20' : 'TOYOTA COROLLA');
    final plate = index % 3 == 0 ? 'BRA2E24' : (index % 3 == 1 ? 'QWE9J12' : 'PLM4K88');
    final date = '2${9 - index}/03/2026';
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOccurrence ? AppColors.error.withValues(alpha: 0.2) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOccurrence ? Icons.report_problem_outlined : (isCheckIn ? Icons.login : Icons.logout),
                      size: 14,
                      color: typeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'ID: #${1000 + index}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      plate,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    date,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${08 + index}:20',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _buildInfoChip(Icons.speed, '${12450 + (index * 100)} km'),
              const SizedBox(width: AppSpacing.sm),
              if (!isOccurrence) _buildInfoChip(Icons.photo_library_outlined, '${index + 4} fotos'),
              const Spacer(),
              _buildViewDetailsButton(context, index),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton(BuildContext context, int index) {
    return InkWell(
      onTap: () => context.push(AppRoutes.driverInspectionDetail.replaceFirst(':id', 'insp_00${index + 1}')),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DETALHES',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
