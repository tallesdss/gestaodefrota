import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class CashFlowFormScreen extends StatefulWidget {
  const CashFlowFormScreen({super.key});

  @override
  State<CashFlowFormScreen> createState() => _CashFlowFormScreenState();
}

class _CashFlowFormScreenState extends State<CashFlowFormScreen> {
  String type = 'Saída'; 
  final List<String> categories = ['Manutenção', 'Combustível', 'Limpeza', 'Outros'];
  String selectedCategory = 'Manutenção';

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
        leading: BackButton(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar Movimentação Manual',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurfaceVariant),
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
            _buildFieldLabel(r'Valor (R$)'),
            TextField(
              decoration: InputDecoration(
                hintText: '0,00',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            _buildFieldLabel('Categoria'),
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
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            _buildFieldLabel('Descrição / Observação'),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Troca de óleo - Veículo XYZ-1234',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl * 2),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Confirmar Registro',
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
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
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurfaceVariant),
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
            border: isSelected ? null : Border.all(color: AppColors.surfaceContainerLow),
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
