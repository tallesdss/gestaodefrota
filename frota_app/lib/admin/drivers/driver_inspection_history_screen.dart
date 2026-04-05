import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/inspection.dart';
import '../../core/widgets/status_badge.dart';

class DriverInspectionHistoryScreen extends StatefulWidget {
  final String driverId;

  const DriverInspectionHistoryScreen({super.key, required this.driverId});

  @override
  State<DriverInspectionHistoryScreen> createState() =>
      _DriverInspectionHistoryScreenState();
}

class _DriverInspectionHistoryScreenState
    extends State<DriverInspectionHistoryScreen> {
  final MockRepository _repository = MockRepository();
  List<Inspection> _inspections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _repository.getInspectionsByDriver(widget.driverId);
    setState(() {
      _inspections = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        title: Text(
          'HISTÓRICO DE VISTORIAS',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _inspections.isEmpty
          ? Center(
              child: Text(
                'Nenhuma vistoria registrada',
                style: AppTextStyles.bodyMedium,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: _inspections.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final i = _inspections[index];
                final isCheckin = i.type == InspectionType.checkin;

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ambientShadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isCheckin
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.secondary.withValues(alpha: 0.1),
                            child: Icon(
                              isCheckin
                                  ? Icons.login_rounded
                                  : Icons.logout_rounded,
                              color: isCheckin
                                  ? AppColors.success
                                  : AppColors.secondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCheckin ? 'CHECK-IN' : 'CHECK-OUT',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${dateFormat.format(i.dateTime)} às ${timeFormat.format(i.dateTime)}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            label: i.hasNewDamage ? 'COM AVARIA' : 'SEM AVARIA',
                            type: i.hasNewDamage
                                ? BadgeType.error
                                : BadgeType.active,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn('KM', '${i.kmAtInspection} km'),
                          _buildInfoColumn(
                            'COMBUSTÍVEL',
                            '${(i.fuelLevel * 100).toInt()}%',
                          ),
                          _buildInfoColumn('VEÍCULO ID', i.vehicleId),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
