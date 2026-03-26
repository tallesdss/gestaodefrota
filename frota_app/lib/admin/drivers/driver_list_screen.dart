import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/driver.dart';
import '../../core/widgets/status_badge.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  final MockRepository _repository = MockRepository();
  List<Driver> _drivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    final list = await _repository.getDrivers();
    setState(() {
      _drivers = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'MOTORISTAS',
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
                itemCount: _drivers.length,
                itemBuilder: (context, index) {
                  final driver = _drivers[index];
                  return GestureDetector(
                    onTap: () {
                      if (driver.isApproved) {
                        context.push(AppRoutes.adminDriverForm, extra: driver);
                      } else {
                        context.push('${AppRoutes.adminRegistrationAudit}?id=${driver.id}');
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.surfaceContainerLow,
                            child: Text(driver.name[0], style: AppTextStyles.headlineSmall.copyWith(fontSize: 18)),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(driver.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                                Text(driver.email, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                StatusBadge(label: driver.isApproved ? 'APROVADO' : 'PENDENTE', type: driver.isApproved ? BadgeType.active : BadgeType.warning),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.adminDriverForm),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }
}
