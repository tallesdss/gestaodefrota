import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../core/repositories/contract_repository.dart';
import '../../models/driver.dart';
import '../../models/contract.dart';

class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final DriverRepository _driverRepo = DriverRepository();
  final ContractRepository _contractRepo = ContractRepository();

  Driver? _driver;
  Contract? _activeContract;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final uid = _authRepo.currentUserId;
    if (uid != null) {
      try {
        final driver = await _driverRepo.getDriverById(uid);
        final contract = await _contractRepo.getActiveContractByDriver(uid);
        if (mounted) {
          setState(() {
            _driver = driver;
            _activeContract = contract;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCnh = _driver?.cnhFrontUrl != null && _driver!.cnhFrontUrl!.isNotEmpty;
    final hasResidence = _driver?.residenceProofUrl != null && _driver!.residenceProofUrl!.isNotEmpty;
    final hasContract = _activeContract != null;

    final cnhStatus = hasCnh ? (_driver?.isApproved == true ? 'VALIDADO' : 'EM ANÁLISE') : 'NÃO ENVIADO';
    final cnhColor = hasCnh ? (_driver?.isApproved == true ? const Color(0xFF4CAF50) : AppColors.warning) : AppColors.error;
    final cnhExpiryStr = _driver?.cnhExpiry != null
        ? 'Validade: ${_driver!.cnhExpiry.day.toString().padLeft(2, '0')}/${_driver!.cnhExpiry.month.toString().padLeft(2, '0')}/${_driver!.cnhExpiry.year}'
        : 'Pendente de envio';

    final residenceStatus = hasResidence ? 'ENVIADO' : 'NÃO ENVIADO';
    final residenceColor = hasResidence ? const Color(0xFF4CAF50) : AppColors.error;

    final contractStatus = hasContract ? 'ATIVO' : 'NENHUM CONTRATO';
    final contractColor = hasContract ? AppColors.primary : AppColors.onSurfaceVariant;
    final contractDateStr = hasContract
        ? 'Contrato ${_activeContract!.contractNumber} - Início ${_activeContract!.startDate.day.toString().padLeft(2, '0')}/${_activeContract!.startDate.month.toString().padLeft(2, '0')}/${_activeContract!.startDate.year}'
        : 'Aguardando alocação pela gestão';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDocuments,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildDocumentItem(
                        title: 'CNH Digital / Física',
                        subtitle: cnhExpiryStr,
                        status: cnhStatus,
                        statusColor: cnhColor,
                        onTap: () => context.push(AppRoutes.driverOnboardingDocs),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildDocumentItem(
                        title: 'Comprovante de Residência',
                        subtitle: hasResidence ? 'Documento anexado' : 'Pendente de envio',
                        status: residenceStatus,
                        statusColor: residenceColor,
                        onTap: () => context.push(AppRoutes.driverOnboardingDocs),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildDocumentItem(
                        title: 'Contrato de Locação',
                        subtitle: contractDateStr,
                        status: contractStatus,
                        statusColor: contractColor,
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildInfoFooter(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.onSurface,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'DOCUMENTAÇÃO',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        Text('Central de Arquivos', style: AppTextStyles.headlineMedium),
      ],
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AppIcon(
                icon: Icons.file_present_outlined,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Mantenha seus documentos atualizados para evitar bloqueios automáticos no sistema.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
