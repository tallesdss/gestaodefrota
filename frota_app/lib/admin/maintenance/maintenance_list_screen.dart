import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/maintenance_entry.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  final MockRepository _repository = MockRepository();
  List<MaintenanceEntry> _maintenances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMaintenances();
  }

  Future<void> _fetchMaintenances() async {
    final list = await _repository.getMaintenances();
    setState(() {
      _maintenances = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'MANUTENÇÕES',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: ListView.builder(
                itemCount: _maintenances.length,
                itemBuilder: (context, index) {
                  final entry = _maintenances[index];
                  return InkWell(
                    onTap: () => context.push(AppRoutes.adminMaintenanceDetail.replaceFirst(':id', entry.id)),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(entry.type).withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getCategoryIcon(entry.type),
                                  color: _getCategoryColor(entry.type),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.type.label,
                                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Veículo ID: ${entry.vehicleId}',
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'R\$ ${entry.cost.toStringAsFixed(2)}',
                                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    entry.status.label.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: entry.status == MaintenanceStatus.paid ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(entry.description, style: AppTextStyles.bodyMedium),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(_formatDate(entry.date), style: AppTextStyles.bodySmall),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.speed_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text('${entry.kmAtMaintenance} KM', style: AppTextStyles.bodySmall),
                                ],
                              ),
                              Text(entry.workshop, style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.adminMaintenanceForm);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  IconData _getCategoryIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange: return Icons.oil_barrel_outlined;
      case MaintenanceType.tires: return Icons.tire_repair_outlined;
      case MaintenanceType.brakes: return Icons.disc_full_outlined;
      case MaintenanceType.suspension: return Icons.settings_input_component_outlined;
      case MaintenanceType.generalRevision: return Icons.build_circle_outlined;
      case MaintenanceType.motor: return Icons.electrical_services_outlined;
      case MaintenanceType.transmission: return Icons.settings_suggest_outlined;
      case MaintenanceType.electrical: return Icons.electric_bolt_outlined;
      case MaintenanceType.bodywork: return Icons.car_repair_outlined;
      case MaintenanceType.other: return Icons.miscellaneous_services_outlined;
    }
  }

  Color _getCategoryColor(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange: return Colors.orange;
      case MaintenanceType.tires: return Colors.blue;
      case MaintenanceType.brakes: return Colors.red;
      case MaintenanceType.suspension: return Colors.purple;
      case MaintenanceType.motor: return Colors.indigo;
      case MaintenanceType.generalRevision: return AppColors.primary;
      case MaintenanceType.transmission: return Colors.teal;
      case MaintenanceType.electrical: return Colors.amber;
      case MaintenanceType.bodywork: return Colors.brown;
      case MaintenanceType.other: return Colors.grey;
    }
  }
}
