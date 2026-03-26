import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONFIGURAÇÕES DO SISTEMA',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            _buildSection(
              title: 'Interface e Experiência',
              children: [
                _buildSwitchTile('Modo Escuro (Manual)', 'Alternar tema do sistema', false),
                _buildSwitchTile('Reduzir Movimento', 'Otimizar animações', true),
                _buildSwitchTile('Notificações Push', 'Receber no desktop', true),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            _buildSection(
              title: 'Unidades e Formatos',
              children: [
                _buildDropdownTile('Unidade de Medida', 'Quilômetros (Km)', ['Quilômetros (Km)', 'Milhas (Mi)']),
                _buildDropdownTile('Consumo Médio', 'Km/L', ['Km/L', 'L/100km']),
                _buildDropdownTile('Moeda', 'Real (BRL)', ['Real (BRL)', 'Dólar (USD)']),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            _buildSection(
              title: 'Configurações de API e Integração',
              children: [
                _buildTextTile('Webhook URL', 'https://api.gestaodefrota.com/v1/events'),
                _buildTextTile('API Key', '• • • • • • • • • • • • • • • •'),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xxxl),
            
            Row(
              children: [
                AppButton(
                  label: 'Salvar Alterações',
                  onPressed: () {},
                  variant: AppButtonVariant.primary,
                ),
                const SizedBox(width: 16),
                AppButton(
                  label: 'Restaurar Padrões',
                  onPressed: () {},
                  variant: AppButtonVariant.ghost,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final int index = entry.key;
              final Widget widget = entry.value;
              final bool isLast = index == children.length - 1;
              return Column(
                children: [
                  widget,
                  if (!isLast) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value) {
    return ListTile(
      title: Text(title, style: AppTextStyles.labelLarge),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Switch(
        value: value,
        onChanged: (val) {},
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDropdownTile(String title, String current, List<String> options) {
    return ListTile(
      title: Text(title, style: AppTextStyles.labelLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(current, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildTextTile(String title, String value) {
    return ListTile(
      title: Text(title, style: AppTextStyles.labelLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 12),
          const Icon(Icons.content_copy_rounded, size: 16),
        ],
      ),
      onTap: () {},
    );
  }
}
