import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/manager.dart';
import '../../core/widgets/status_badge.dart';

class ManagerListScreen extends StatefulWidget {
  const ManagerListScreen({super.key});

  @override
  State<ManagerListScreen> createState() => _ManagerListScreenState();
}

class _ManagerListScreenState extends State<ManagerListScreen> {
  final MockRepository _repository = MockRepository();
  List<Manager> _managers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchManagers();
  }

  Future<void> _fetchManagers() async {
    final list = await _repository.getManagers();
    setState(() {
      _managers = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'GESTORES',
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
                itemCount: _managers.length,
                itemBuilder: (context, index) {
                  final manager = _managers[index];
                  return GestureDetector(
                    onTap: () => context.push(AppRoutes.adminManagerForm, extra: manager),
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
                            backgroundImage: NetworkImage(manager.avatarUrl),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(manager.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                                Text(manager.email, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                StatusBadge(
                                  label: manager.isApproved ? 'APROVADO' : 'PENDENTE',
                                  type: manager.isApproved ? BadgeType.active : BadgeType.warning,
                                ),
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
        onPressed: () => context.push(AppRoutes.adminManagerSearch),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_circle_outline, color: AppColors.onPrimary),
      ),
    );
  }
}
