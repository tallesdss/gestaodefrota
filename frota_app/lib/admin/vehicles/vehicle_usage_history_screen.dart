import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/vehicle_repository.dart';
import '../../core/repositories/contract_repository.dart';
import '../../models/vehicle.dart';

class VehicleUsageHistoryScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleUsageHistoryScreen({super.key, required this.vehicleId});

  @override
  State<VehicleUsageHistoryScreen> createState() =>
      _VehicleUsageHistoryScreenState();
}

class _VehicleUsageHistoryScreenState extends State<VehicleUsageHistoryScreen> {
  final VehicleRepository _vehicleRepository = VehicleRepository();
  final ContractRepository _contractRepository = ContractRepository();
  Vehicle? _vehicle;
  List<VehicleUsage> _usageHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final v = await _vehicleRepository.getVehicleById(widget.vehicleId);
      final contracts = await _contractRepository.getContracts(
        vehicleId: widget.vehicleId,
      );

      List<VehicleUsage> usages = v?.usageHistory ?? [];
      if (usages.isEmpty && contracts.isNotEmpty) {
        final currentKm = v?.currentKm ?? 0;
        usages = contracts
            .map(
              (c) => VehicleUsage(
                driverId: c.driverId,
                driverName: c.driverName ?? 'Motorista',
                startDate: c.startDate,
                endDate: c.endDate,
                startKm: currentKm,
                endKm: null,
                purpose: 'Contrato ${c.contractNumber ?? ""}',
              ),
            )
            .toList();
      }

      if (mounted) {
        setState(() {
          _vehicle = v;
          _usageHistory = usages;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _vehicle = null;
          _isLoading = false;
        });
      }
    }
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

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        title: Text(
          'HISTÓRICO DE USO: ${_vehicle!.plate}',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _usageHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum histórico de uso registrado para este veículo',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: _usageHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final h = _usageHistory[index];
                final isActive = h.endDate == null;

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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isActive
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceContainerLow,
                        child: Icon(
                          isActive ? Icons.directions_car : Icons.history,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.driverName,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${dateFormat.format(h.startDate)} - ${h.endDate != null ? dateFormat.format(h.endDate!) : "Em andamento"}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'KM INICIAL',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${h.startKm}',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (h.endKm != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'KM FINAL',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '${h.endKm}',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
