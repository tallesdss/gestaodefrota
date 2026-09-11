import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/admin_pix_config.dart';
import '../../core/services/pix_service.dart';

class PixConfigDialog extends StatefulWidget {
  const PixConfigDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PixConfigDialog(),
    );
  }

  @override
  State<PixConfigDialog> createState() => _PixConfigDialogState();
}

class _PixConfigDialogState extends State<PixConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pixService = PixService();

  late PixKeyType _selectedType;
  late TextEditingController _keyController;
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _bankController;
  late TextEditingController _descController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final current = _pixService.currentConfig;
    _selectedType = current.keyType;
    _keyController = TextEditingController(text: current.pixKey);
    _nameController = TextEditingController(text: current.merchantName);
    _cityController = TextEditingController(text: current.merchantCity);
    _bankController = TextEditingController(text: current.bankName ?? '');
    _descController = TextEditingController(text: current.description ?? 'Aluguel de Veículo');
  }

  @override
  void dispose() {
    _keyController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _bankController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String get _currentPreviewPayload {
    final tempConfig = AdminPixConfig(
      keyType: _selectedType,
      pixKey: _keyController.text.trim().isEmpty ? '54123456000189' : _keyController.text.trim(),
      merchantName: _nameController.text.trim().isEmpty ? 'ARCHITECT FLEET' : _nameController.text.trim(),
      merchantCity: _cityController.text.trim().isEmpty ? 'SAO PAULO' : _cityController.text.trim(),
      bankName: _bankController.text.trim(),
      description: _descController.text.trim(),
      updatedAt: DateTime.now(),
    );

    return _pixService.generatePixPayload(
      amount: 750.0,
      customConfig: tempConfig,
      customDescription: 'TESTE PIX',
    );
  }

  String _getKeyHint() {
    switch (_selectedType) {
      case PixKeyType.cnpj:
        return 'Ex: 12.345.678/0001-90';
      case PixKeyType.cpf:
        return 'Ex: 123.456.789-00';
      case PixKeyType.email:
        return 'Ex: financeiro@gestaodefrota.com.br';
      case PixKeyType.telefone:
        return 'Ex: (11) 99999-8888 ou +5511999998888';
      case PixKeyType.aleatoria:
        return 'Ex: 123e4567-e89b-12d3-a456-426614174000';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updated = AdminPixConfig(
        keyType: _selectedType,
        pixKey: _keyController.text.trim(),
        merchantName: _nameController.text.trim(),
        merchantCity: _cityController.text.trim(),
        bankName: _bankController.text.trim().isEmpty ? null : _bankController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await _pixService.updateConfig(updated);

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chave PIX da empresa atualizada com sucesso! Todos os pagamentos de motoristas agora usarão esta chave.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar chave PIX: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: isWide ? 680 : double.infinity,
        constraints: const BoxConstraints(maxHeight: 750),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BDAE).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.pix,
                    color: Color(0xFF00BDAE),
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CADASTRAR CHAVE PIX',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Configure a chave para recebimento dos aluguéis dos motoristas',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo de Chave (Segmented Chips)
                      Text(
                        'TIPO DE CHAVE PIX',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PixKeyType.values.map((type) {
                          final isSelected = _selectedType == type;
                          return ChoiceChip(
                            label: Text(type.label),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: AppColors.surfaceContainerLow,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedType = type;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Input Chave PIX
                      Text(
                        'CHAVE PIX (${_selectedType.label}) *',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _keyController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: _getKeyHint(),
                          prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppColors.primary),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppColors.outlineVariant),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a chave PIX';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Nome do Titular / Razão Social
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NOME DO TITULAR / BENEFICIÁRIO *',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _nameController,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Ex: ARCHITECT FLEET LOCADORA',
                                    prefixIcon: const Icon(Icons.business, color: AppColors.primary),
                                    filled: true,
                                    fillColor: AppColors.surfaceContainerLowest,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: AppColors.outlineVariant),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Informe o titular';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CIDADE DA CONTA *',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _cityController,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Ex: SAO PAULO',
                                    prefixIcon: const Icon(Icons.location_city, color: AppColors.primary),
                                    filled: true,
                                    fillColor: AppColors.surfaceContainerLowest,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: AppColors.outlineVariant),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Informe a cidade';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Banco e Descrição
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BANCO / INSTITUIÇÃO (OPCIONAL)',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _bankController,
                                  decoration: InputDecoration(
                                    hintText: 'Ex: Banco Inter, Nubank, Itaú',
                                    prefixIcon: const Icon(Icons.account_balance_outlined, color: AppColors.onSurfaceVariant),
                                    filled: true,
                                    fillColor: AppColors.surfaceContainerLowest,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: AppColors.outlineVariant),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IDENTIFICADOR / TXID PADRÃO',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _descController,
                                  decoration: InputDecoration(
                                    hintText: 'Ex: ALUGUEL FROTA',
                                    prefixIcon: const Icon(Icons.tag, color: AppColors.onSurfaceVariant),
                                    filled: true,
                                    fillColor: AppColors.surfaceContainerLowest,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: AppColors.outlineVariant),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Live QR Code Preview Box
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00BDAE).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: _currentPreviewPayload,
                                version: QrVersions.auto,
                                size: 84,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Color(0xFF00BDAE), size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'PRÉ-VISUALIZAÇÃO EM TEMPO REAL',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: const Color(0xFF00BDAE),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Este QR Code será gerado automaticamente para todos os motoristas em cada vencimento de R\$ 750,00 ou quitação total.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: Text(
                    'CANCELAR',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('SALVAR CHAVE PIX'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
