import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/financial_repository.dart';
import '../../models/financial_entry.dart';

class CashFlowFormScreen extends StatefulWidget {
  const CashFlowFormScreen({super.key});

  @override
  State<CashFlowFormScreen> createState() => _CashFlowFormScreenState();
}

class _CashFlowFormScreenState extends State<CashFlowFormScreen> {
  final FinancialRepository _financialRepo = FinancialRepository();
  String type = 'Saída';
  final List<String> categories = [
    'Manutenção',
    'Combustível',
    'Limpeza',
    'IPVA/Licenciamento',
    'Seguro',
    'Multa',
    'Aluguel',
    'Outros',
  ];
  String selectedCategory = 'Manutenção';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe um valor válido.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isIncome = type == 'Entrada';
      final entry = FinancialEntry(
        id: '',
        type: isIncome ? FinancialType.income : FinancialType.expense,
        category: selectedCategory,
        amount: amount,
        date: DateTime.now(),
        paymentDate: DateTime.now(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : '$type manual - $selectedCategory',
        isPaid: true,
        paymentMethod: 'pix',
      );

      await _financialRepo.createFinancialEntry(entry);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lançamento de R\$ ${amount.toStringAsFixed(2)} registrado no Supabase!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar lançamento: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Função de Caixa',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),
        leading: const BackButton(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar Movimentação Manual no Supabase',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Type Selector (Entrada / Saída)
            Row(
              children: [
                _buildTypeButton('Saída', AppColors.error),
                const SizedBox(width: AppSpacing.md),
                _buildTypeButton('Entrada', AppColors.success),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Form Fields
            _buildFieldLabel(r'Valor (R$) *'),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: '0,00',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: AppSpacing.xl),

            _buildFieldLabel('Categoria *'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: AppTextStyles.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            _buildFieldLabel('Descrição / Observações'),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Abastecimento de emergência ou taxa bancária...',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirmar e Salvar no Supabase',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, Color color) {
    final bool isSelected = type == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => type = label),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(color: AppColors.surfaceContainerLow),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.titleMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
