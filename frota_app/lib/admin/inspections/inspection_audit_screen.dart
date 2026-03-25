import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInspections();
  }

  Future<void> _fetchInspections() async {
    final list = await _repository.getInspections();
    setState(() {
      _inspections = list;
      _isLoading = false;
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
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: ListView.builder(
                itemCount: _inspections.length,
                itemBuilder: (context, index) {
                  final inspection = _inspections[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: inspection.type == InspectionType.checkin ? Colors.green.withAlpha(30) : Colors.orange.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                inspection.type == InspectionType.checkin ? Icons.login_outlined : Icons.logout_outlined,
                                color: inspection.type == InspectionType.checkin ? Colors.green : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inspection.type == InspectionType.checkin ? 'CHECK-IN (ENTRADA)' : 'CHECK-OUT (SAÍDA)',
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Veículo: ${inspection.vehicleId} • Motorista: ${inspection.driverId}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (inspection.hasNewDamage)
                              const StatusBadge(label: 'AVARIA', type: BadgeType.error)
                            else
                              const StatusBadge(label: 'OK', type: BadgeType.active),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
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
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Data: ${_formatDate(inspection.dateTime)}',
                              style: AppTextStyles.bodySmall,
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('VER DETALHES'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
