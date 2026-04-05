import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_filter_bar.dart';
import '../../core/widgets/app_icon.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'todos';

  final List<AppFilterItem> _filters = [
    AppFilterItem(label: 'Todos', value: 'todos', isSelected: true),
    AppFilterItem(label: 'Urgente', value: 'urgente'),
    AppFilterItem(label: 'Manutenção', value: 'manutencao'),
    AppFilterItem(label: 'Financeiro', value: 'financeiro'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CENTRAL DE NOTIFICAÇÕES',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppFilterBar(
                  filters: _filters
                      .map(
                        (f) => AppFilterItem(
                          label: f.label,
                          value: f.value,
                          isSelected: f.value == _selectedFilter,
                        ),
                      )
                      .toList(),
                  onFilterSelected: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildNotificationItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    final bool isUrgente = index % 3 == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: isUrgente
            ? Border.all(
                color: AppColors.error.withValues(alpha: 0.1),
                width: 1,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(
            icon: isUrgente
                ? Icons.priority_high_rounded
                : Icons.notifications_active_outlined,
            layer: isUrgente ? AppIconLayer.error : AppIconLayer.onSurface,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUrgente ? 'ALERTA CRÍTICO' : 'MANUTENÇÃO PROGRAMADA',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isUrgente ? AppColors.error : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Há 10 min',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isUrgente
                      ? 'O veículo ABC-1234 (Toyota Corolla) reportou falha crítica no sistema de freios.'
                      : 'Lembrete: O veículo XYZ-5678 deve passar pela revisão periódica amanhã.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return IconButton(
      onPressed: () {},
      icon: const Icon(
        Icons.more_horiz_rounded,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
