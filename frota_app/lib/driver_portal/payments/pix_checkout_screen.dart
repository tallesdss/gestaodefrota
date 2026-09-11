import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../models/financial_entry.dart';
import '../../models/admin_pix_config.dart';
import '../../core/repositories/financial_repository.dart';
import '../../core/services/pix_service.dart';

class PixCheckoutScreen extends StatefulWidget {
  final List<FinancialEntry> entries;
  final FinancialEntry? entry;

  const PixCheckoutScreen({
    super.key,
    this.entries = const [],
    this.entry,
  });

  @override
  State<PixCheckoutScreen> createState() => _PixCheckoutScreenState();
}

class _PixCheckoutScreenState extends State<PixCheckoutScreen> {
  final FinancialRepository _financialRepo = FinancialRepository();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedReceipt;
  Uint8List? _receiptBytes;
  bool _isUploading = false;

  List<FinancialEntry> get _allEntries {
    if (widget.entries.isNotEmpty) return widget.entries;
    if (widget.entry != null) return [widget.entry!];
    return [];
  }

  double get _totalAmount => _allEntries.fold(0.0, (sum, e) => sum + e.amount);

  bool get _isBatch => _allEntries.length > 1;

  Future<void> _pickReceipt(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedReceipt = picked;
          _receiptBytes = bytes;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível selecionar o arquivo.')),
        );
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SELECIONAR COMPROVANTE', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Tirar Foto / Câmera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickReceipt(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Galeria / Arquivo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickReceipt(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildValueCard(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildQrCodeSection(context),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildInstructions(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildUploadSection(),
                    const SizedBox(height: AppSpacing.xxl),
                    _isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : AppButton(
                            label: _isBatch
                                ? 'CONFIRMAR QUITAÇÃO TOTAL (${_allEntries.length} PARCELAS)'
                                : 'CONFIRMAR PAGAMENTO',
                            onPressed: _showConfirmation,
                            isFullWidth: true,
                          ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            color: AppColors.onSurface,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _isBatch ? 'QUITAR TODAS AS PARCELAS' : 'PAGAMENTO PIX',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard() {
    final count = _allEntries.length;
    return Column(
      children: [
        Text(
          _isBatch ? 'VALOR TOTAL PARA QUITAÇÃO' : 'VALOR DO PAGAMENTO',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'R\$ ${_totalAmount.toStringAsFixed(2).replaceAll('.', ',')}',
          style: AppTextStyles.displayMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _isBatch
              ? 'Quitação acumulada de $count faturas/parcelas do contrato'
              : (_allEntries.isNotEmpty ? _allEntries.first.description : 'Aluguel do Veículo'),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQrCodeSection(BuildContext context) {
    final pixService = PixService();

    return ValueListenableBuilder<AdminPixConfig>(
      valueListenable: pixService.configNotifier,
      builder: (context, pixConfig, _) {
        final txId = _allEntries.isNotEmpty ? _allEntries.first.id : 'ALUGUEL';
        final payload = pixService.generatePixPayload(
          amount: _totalAmount,
          txId: txId,
          customDescription: _isBatch ? 'QUITACAO CONTRATO' : 'ALUGUEL VEICULO',
        );

        return Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.04),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              // Dynamic Real QR Code using QrImageView
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF00BDAE).withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: 190,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Beneficiary & Key Details Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Beneficiário:',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          pixConfig.merchantName,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chave PIX (${pixConfig.keyType.label}):',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          pixConfig.pixKey,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00BDAE),
                          ),
                        ),
                      ],
                    ),
                    if (pixConfig.bankName != null && pixConfig.bankName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Instituição / Cidade:',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${pixConfig.bankName} • ${pixConfig.merchantCity}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Action buttons: Copiar Código Pix e Copiar Chave
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: payload));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Código Pix Copia e Cola copiado com sucesso!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy, color: AppColors.primary, size: 18),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'COPIAR CÓDIGO PIX',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: pixConfig.pixKey));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Chave PIX (${pixConfig.keyType.label}) copiada!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.vpn_key_outlined, color: AppColors.onSurfaceVariant, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Copiar Chave',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INSTRUÇÕES DE PAGAMENTO',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInstructionRow('1', 'Abra o app do seu banco e selecione a opção PIX.'),
        const SizedBox(height: AppSpacing.sm),
        _buildInstructionRow('2', 'Escaneie o QR Code ou cole a chave "Pix Copia e Cola".'),
        const SizedBox(height: AppSpacing.sm),
        _buildInstructionRow('3', 'Anexe a foto do comprovante abaixo para validação imediata.'),
      ],
    );
  }

  Widget _buildInstructionRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    final hasFile = _selectedReceipt != null && _receiptBytes != null;

    return InkWell(
      onTap: _showImageSourceModal,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasFile ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (hasFile) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _receiptBytes!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _selectedReceipt!.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Clique para trocar o comprovante',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ] else ...[
              const AppIcon(
                icon: Icons.cloud_upload_outlined,
                color: AppColors.primary,
                size: 36,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'ANEXAR COMPROVANTE',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tire uma foto ou escolha da galeria',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('CONFIRMAR PAGAMENTO?', style: AppTextStyles.headlineSmall),
        content: Text(
          _isBatch
              ? 'Deseja confirmar a quitação de ${_allEntries.length} parcelas no valor total de R\$ ${_totalAmount.toStringAsFixed(2)}?'
              : 'Deseja confirmar o pagamento de R\$ ${_totalAmount.toStringAsFixed(2)}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCELAR',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx); // fecha modal
              setState(() => _isUploading = true);

              try {
                final entryIds = _allEntries.map((e) => e.id).toList();

                if (_receiptBytes != null && _selectedReceipt != null) {
                  if (_isBatch) {
                    await _financialRepo.uploadBatchPaymentReceipt(
                      entryIds: entryIds,
                      bytes: _receiptBytes!,
                      fileName: _selectedReceipt!.name,
                    );
                  } else if (entryIds.isNotEmpty) {
                    await _financialRepo.uploadPaymentReceipt(
                      entryId: entryIds.first,
                      bytes: _receiptBytes!,
                      fileName: _selectedReceipt!.name,
                    );
                  }
                } else {
                  if (_isBatch) {
                    await _financialRepo.markBatchAsPaid(entryIds, paymentMethod: 'pix');
                  } else if (entryIds.isNotEmpty) {
                    await _financialRepo.markAsPaid(entryIds.first, paymentMethod: 'pix');
                  }
                }

                if (!mounted) return;
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isBatch
                          ? 'Todas as ${_allEntries.length} parcelas foram quitadas com sucesso!'
                          : 'Pagamento confirmado e comprovante enviado!',
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                setState(() => _isUploading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao registrar pagamento: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }
}

