import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/maintenance_entry.dart';
import '../../models/vehicle.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  final String vehicleId;
  const MaintenanceHistoryScreen({super.key, required this.vehicleId});

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  final MockRepository _repository = MockRepository();
  Vehicle? _vehicle;
  List<MaintenanceEntry> _maintenances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final v = await _repository.getVehicleById(widget.vehicleId);
    final m = await _repository.getMaintenancesByVehicle(widget.vehicleId);
    setState(() {
      _vehicle = v;
      _maintenances = m.reversed.toList();
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
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: r'R$',
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico de Manutenções',
              style: AppTextStyles.headlineSmall,
            ),
            Text(
              '${_vehicle!.plate} - ${_vehicle!.brand} ${_vehicle!.model}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
      ),
      body: _maintenances.isEmpty
          ? Center(
              child: Text(
                'Nenhuma manutenção registrada para este veículo',
                style: AppTextStyles.bodyMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: _maintenances.length,
              itemBuilder: (context, index) {
                final m = _maintenances[index];
                final isPaid = m.status == MaintenanceStatus.paid;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () =>
                        context.push('/admin/maintenance/detail/${m.id}'),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryContainer.withValues(
                        alpha: 0.2,
                      ),
                      child: Icon(
                        _getMaintenanceIcon(m.type),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(m.description, style: AppTextStyles.labelLarge),
                    subtitle: Text(
                      '${dateFormat.format(m.date)} • ${m.workshop}',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(m.cost),
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isPaid ? 'PAGO' : 'PENDENTE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isPaid ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/admin/maintenance/form?vehicleId=${widget.vehicleId}',
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getMaintenanceIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange:
        return Icons.oil_barrel_outlined;
      case MaintenanceType.tires:
        return Icons.tire_repair_outlined;
      case MaintenanceType.brakes:
        return Icons.e_mobiledata_outlined;
      case MaintenanceType.suspension:
        return Icons.agriculture_outlined;
      case MaintenanceType.generalRevision:
        return Icons.build_circle_outlined;
      case MaintenanceType.motor:
        return Icons.engineering_outlined;
      case MaintenanceType.transmission:
        return Icons.settings_input_component_outlined;
      case MaintenanceType.electrical:
        return Icons.electrical_services_outlined;
      case MaintenanceType.bodywork:
        return Icons.format_paint_outlined;
      default:
        return Icons.build_outlined;
    }
  }
}
