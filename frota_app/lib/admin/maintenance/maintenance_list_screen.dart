import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/maintenance_entry.dart';
import 'maintenance_form_screen.dart';

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
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
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
                                    _formatType(entry.type),
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Veículo: ${entry.vehicleId}',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'R\$ ${entry.cost.toStringAsFixed(2)}',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
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
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceFormScreen()));
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatType(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange: return 'Troca de Óleo';
      case MaintenanceType.tires: return 'Pneus';
      case MaintenanceType.brakes: return 'Freios';
      case MaintenanceType.suspension: return 'Suspensão';
      case MaintenanceType.generalRevision: return 'Revisão Geral';
      case MaintenanceType.other: return 'Outros';
    }
  }

  IconData _getCategoryIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange: return Icons.oil_barrel_outlined;
      case MaintenanceType.tires: return Icons.tire_repair_outlined;
      case MaintenanceType.brakes: return Icons.disc_full_outlined;
      case MaintenanceType.suspension: return Icons.settings_input_component_outlined;
      case MaintenanceType.generalRevision: return Icons.build_circle_outlined;
      case MaintenanceType.other: return Icons.miscellaneous_services_outlined;
    }
  }

  Color _getCategoryColor(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange: return Colors.orange;
      case MaintenanceType.tires: return Colors.blue;
      case MaintenanceType.brakes: return Colors.red;
      case MaintenanceType.suspension: return Colors.purple;
      case MaintenanceType.generalRevision: return AppColors.primary;
      case MaintenanceType.other: return Colors.grey;
    }
  }
}
