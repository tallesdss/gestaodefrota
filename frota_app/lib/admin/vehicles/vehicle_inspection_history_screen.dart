import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/inspection.dart';
import '../../models/vehicle.dart';
import '../../core/widgets/status_badge.dart';

class VehicleInspectionHistoryScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleInspectionHistoryScreen({super.key, required this.vehicleId});

  @override
  State<VehicleInspectionHistoryScreen> createState() =>
      _VehicleInspectionHistoryScreenState();
}

class _VehicleInspectionHistoryScreenState
    extends State<VehicleInspectionHistoryScreen> {
  final MockRepository _repository = MockRepository();
  Vehicle? _vehicle;
  List<Inspection> _inspections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final v = await _repository.getVehicleById(widget.vehicleId);
    final list = await _repository.getInspectionsByVehicle(widget.vehicleId);
    setState(() {
      _vehicle = v;
      _inspections = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_vehicle == null) {
      return const Scaffold(
        body: Center(child: Text('Veículo não encontrado')),
      );
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
          'VISTORIAS: ${_vehicle!.plate}',
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

                return GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.adminInspectionDetail.replaceAll(':id', i.id),
                  ),
                  child: Container(
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
                                  Row(
                                    children: [
                                      Text(
                                        isCheckin ? 'CHECK-IN' : 'CHECK-OUT',
                                        style: AppTextStyles.labelLarge
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildSmallStatusBadge(i.status),
                                    ],
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
                              label: i.hasNewDamage
                                  ? 'COM AVARIA'
                                  : 'SEM AVARIA',
                              type: i.hasNewDamage
                                  ? BadgeType.error
                                  : BadgeType.active,
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
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
                            _buildInfoColumn(
                              'STATUS',
                              i.status.name.toUpperCase(),
                            ),
                          ],
                        ),
                        if (i.photos.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: i.photos.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, photoIndex) {
                                final photo = i.photos[photoIndex];
                                return Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        photo.url,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    SizedBox(
                                      width: 50,
                                      child: Text(
                                        photo.title,
                                        style: const TextStyle(
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSmallStatusBadge(InspectionStatus status) {
    Color color;
    switch (status) {
      case InspectionStatus.approved:
        color = AppColors.success;
        break;
      case InspectionStatus.rejected:
        color = AppColors.error;
        break;
      case InspectionStatus.pending:
        color = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
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
