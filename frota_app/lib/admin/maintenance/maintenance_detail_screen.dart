import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/maintenance_entry.dart';
import '../../core/widgets/status_badge.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final String maintenanceId;
  const MaintenanceDetailScreen({super.key, required this.maintenanceId});

  @override
  State<MaintenanceDetailScreen> createState() =>
      _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  final MockRepository _repository = MockRepository();
  MaintenanceEntry? _entry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final entry = await _repository.getMaintenanceById(widget.maintenanceId);
    setState(() {
      _entry = entry;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_entry == null) {
      return const Scaffold(
        body: Center(child: Text('Manutenção não encontrada')),
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
        title: Text(
          'Detalhes da Manutenção',
          style: AppTextStyles.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        actions: [
          IconButton(
            onPressed: () {}, // Edit logic
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () {}, // Delete logic
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(currencyFormat, dateFormat),
            const SizedBox(height: AppSpacing.xxl),

            _buildInfoGrid(dateFormat),
            const SizedBox(height: AppSpacing.xxl),

            _buildPartsList(currencyFormat),
            const SizedBox(height: AppSpacing.xxl),

            if (_entry!.invoiceNumber != null) ...[
              _buildInvoiceSection(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NumberFormat currencyFormat, DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _entry!.description,
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Realizada em ${dateFormat.format(_entry!.date)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: _entry!.status == MaintenanceStatus.paid
                    ? 'PAGO'
                    : 'PENDENTE',
                type: _entry!.status == MaintenanceStatus.paid
                    ? BadgeType.active
                    : BadgeType.error,
              ),
            ],
          ),
          const Divider(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderStat(
                'Valor Total',
                currencyFormat.format(_entry!.cost),
              ),
              _buildHeaderStat(
                'KM do Veículo',
                '${_entry!.kmAtMaintenance} KM',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informações Gerais', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.md),
        _buildInfoCard([
          _buildInfoRow(
            Icons.person_outline,
            'Motorista',
            _entry!.driverName ?? 'Não informado',
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Oficina',
            _entry!.workshop,
          ),
          _buildInfoRow(
            Icons.category_outlined,
            'Tipo',
            _getTypeLabel(_entry!.type),
          ),
        ]),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPartsList(NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Peças e Serviços', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.md),
        if (_entry!.parts.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('Nenhuma peça ou serviço listado')),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _entry!.parts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = _entry!.parts[index];
                return ListTile(
                  title: Text(p.name, style: AppTextStyles.labelLarge),
                  subtitle: Text(
                    '${p.quantity}x ${currencyFormat.format(p.unitPrice)}',
                  ),
                  trailing: Text(
                    currencyFormat.format(p.total),
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInvoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Documentação', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nota Fiscal / Recibo',
                      style: AppTextStyles.labelLarge,
                    ),
                    Text(
                      'Nº ${_entry!.invoiceNumber}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('VER ANEXO')),
            ],
          ),
        ),
      ],
    );
  }

  String _getTypeLabel(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange:
        return 'Troca de Óleo';
      case MaintenanceType.tires:
        return 'Pneus';
      case MaintenanceType.brakes:
        return 'Freios';
      case MaintenanceType.suspension:
        return 'Suspensão';
      case MaintenanceType.generalRevision:
        return 'Revisão Geral';
      case MaintenanceType.motor:
        return 'Motor';
      case MaintenanceType.transmission:
        return 'Câmbio/Transmissão';
      case MaintenanceType.electrical:
        return 'Elétrica';
      case MaintenanceType.bodywork:
        return 'Funilaria';
      default:
        return 'Outros';
    }
  }
}
