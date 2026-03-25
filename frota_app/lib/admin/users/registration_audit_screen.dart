import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/driver.dart';
import '../../core/widgets/status_badge.dart';

class RegistrationAuditScreen extends StatefulWidget {
  const RegistrationAuditScreen({super.key});

  @override
  State<RegistrationAuditScreen> createState() => _RegistrationAuditScreenState();
}

class _RegistrationAuditScreenState extends State<RegistrationAuditScreen> {
  final MockRepository _repository = MockRepository();
  List<dynamic> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    final drivers = await _repository.getDrivers();
    final managers = await _repository.getManagers();
    
    final pendingDrivers = drivers.where((d) => !d.isApproved).toList();
    final pendingManagers = managers.where((m) => !m.isApproved).toList();
    
    setState(() {
      _pendingUsers = [...pendingDrivers, ...pendingManagers];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            children: [
              Text(
                'Auditoria de Cadastro',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Analise e aprove novos usuários e motoristas',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_pendingUsers.isEmpty)
                _buildEmptyState()
              else
                ..._pendingUsers.map((user) => _buildAuditItem(user, user is Driver)),
            ],
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary.withAlpha(100)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nenhum cadastro pendente',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditItem(dynamic user, bool isDriver) {
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
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.surfaceContainerLow,
                backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                child: user.avatarUrl.isEmpty ? Text(user.name[0], style: AppTextStyles.headlineSmall.copyWith(fontSize: 18)) : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(isDriver ? 'MOTORISTA' : 'GESTOR', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    Text(user.email, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              StatusBadge(label: 'AGUARDANDO', type: BadgeType.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // TODO: Reject user
                },
                child: Text('REJEITAR', style: AppTextStyles.labelSmall.copyWith(color: AppColors.error)),
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  // TODO: Approve user
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('APROVAR', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onPrimary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
