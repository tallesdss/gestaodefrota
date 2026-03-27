import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/vehicle.dart';
import '../../models/driver.dart';
import '../../models/inspection.dart';
import '../../core/widgets/status_badge.dart';

class InspectionAuditScreen extends StatefulWidget {
  const InspectionAuditScreen({super.key});

  @override
  State<InspectionAuditScreen> createState() => _InspectionAuditScreenState();
}

class _InspectionAuditScreenState extends State<InspectionAuditScreen> {
  final MockRepository _repository = MockRepository();
  List<Inspection> _inspections = [];
  List<Inspection> _filteredInspections = [];
  Map<String, Driver> _driverMap = {};
  Map<String, Vehicle> _vehicleMap = {};
  List<String> _cities = ['Todas'];
  String _selectedCity = 'Todas';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInspections();
  }

  Future<void> _fetchInspections() async {
    final inspections = await _repository.getInspections();
    final drivers = await _repository.getDrivers();
    final vehicles = await _repository.getVehicles();
    
    setState(() {
      _inspections = inspections;
      _filteredInspections = inspections;
      _driverMap = {for (var d in drivers) d.id: d};
      _vehicleMap = {for (var v in vehicles) v.id: v};
      
      _cities = ['Todas', ...drivers.map((d) => d.city).whereType<String>().toSet()];
      _isLoading = false;
    });
  }

  void _applyFilter(String city) {
    setState(() {
      _selectedCity = city;
      if (city == 'Todas') {
        _filteredInspections = _inspections;
      } else {
        _filteredInspections = _inspections.where((ins) {
          final driver = _driverMap[ins.driverId];
          return driver?.city == city;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'AUDITORIA DE VISTORIAS',
          style: AppTextStyles.labelLarge.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'FILTRAR POR CIDADE:',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCity,
                            items: _cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city, style: AppTextStyles.bodySmall),
                              );
                            }).toList(),
                            onChanged: (val) => _applyFilter(val!),
                            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: ListView.builder(
                      itemCount: _filteredInspections.length,
                      itemBuilder: (context, index) {
                        final inspection = _filteredInspections[index];
                        final driver = _driverMap[inspection.driverId];
                        final vehicle = _vehicleMap[inspection.vehicleId];

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: driver != null ? NetworkImage(driver.avatarUrl) : null,
                              backgroundColor: AppColors.surfaceContainerLow,
                              child: driver == null ? const Icon(Icons.person) : null,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver?.name ?? 'Motorista não identificado',
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    vehicle != null 
                                      ? '${vehicle.model} (${vehicle.year})' 
                                      : 'Veículo não identificado',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: inspection.type == InspectionType.checkin ? AppColors.successContainer : AppColors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                inspection.type == InspectionType.checkin ? 'CHECK-IN' : 'CHECK-OUT',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: inspection.type == InspectionType.checkin ? AppColors.success : AppColors.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'REGISTRO FOTOGRÁFICO',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: inspection.photos.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                inspection.photos[i],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  color: AppColors.surfaceContainerLow,
                                  child: const Icon(Icons.image_not_supported_outlined),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(inspection.dateTime),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            if (inspection.hasNewDamage)
                              const StatusBadge(label: 'REGISTRO DE AVARIA', type: BadgeType.error)
                            else
                              const StatusBadge(label: 'VISTORIA OK', type: BadgeType.active),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
