import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frota_app/core/theme/app_colors.dart';
import 'package:frota_app/core/theme/app_text_styles.dart';
import 'package:frota_app/core/theme/app_spacing.dart';
import 'package:frota_app/core/widgets/app_button.dart';
import 'package:frota_app/core/widgets/app_icon.dart';
import 'package:frota_app/core/routes/app_routes.dart';

class OccurrenceReportScreen extends StatefulWidget {
  const OccurrenceReportScreen({super.key});

  @override
  State<OccurrenceReportScreen> createState() => _OccurrenceReportScreenState();
}

class _OccurrenceReportScreenState extends State<OccurrenceReportScreen> {
  String? _selectedCategory;
  final List<String> _categories = [
    'Dano Externo (Lataria)',
    'Problema Mecânico',
    'Ar Condicionado',
    'Pneu/Roda',
    'Vidros/Espelhos',
    'Outro (Especificar)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('RELATAR OCORRÊNCIA', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, letterSpacing: 2)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const AppIcon(icon: Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O que aconteceu com o veículo?',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Seu relato será enviado diretamente para a central de gestão para análise imediata.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSectionLabel('CATEGORIA DA OCORRÊNCIA'),
            const SizedBox(height: AppSpacing.md),
            _buildCategorySelector(),
            
            const SizedBox(height: AppSpacing.xl),
            _buildSectionLabel('ASPECTOS VISUAIS'),
            const SizedBox(height: AppSpacing.md),
            _buildPhotoUploader(),
            
            const SizedBox(height: AppSpacing.xl),
            _buildSectionLabel('DETALHAMENTO'),
            const SizedBox(height: AppSpacing.md),
            _buildDescriptionField(),
            
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'ENVIAR RELATÓRIO',
              onPressed: () {
                _showSentConfirmation();
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category : null;
            });
          },
          selectedColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundColor: AppColors.surfaceContainerLow,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent)),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoUploader() {
    return Row(
      children: [
        _buildUploadItem(Icons.photo_camera_outlined, 'Adicionar Foto'),
        const SizedBox(width: AppSpacing.md),
        _buildUploadItem(Icons.videocam_outlined, 'Adicionar Vídeo'),
      ],
    );
  }

  Widget _buildUploadItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.05), style: BorderStyle.none),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon: icon, color: AppColors.primary, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Descreva detalhadamente o ocorrido, KM aproximado e local se relevante...',
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showSentConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 60),
            const SizedBox(height: AppSpacing.lg),
            Text('Relatório Enviado!', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sua ocorrência foi registrada sob o protocolo #ORD-${DateTime.now().millisecond}. '
              'Nossos analistas entrarão em contato em breve.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'ENTENDIDO',
              onPressed: () {
                context.go(AppRoutes.driverHome);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
