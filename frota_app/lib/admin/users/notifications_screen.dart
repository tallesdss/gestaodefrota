import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_filter_bar.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/services/realtime_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final RealtimeService _realtimeService = RealtimeService();
  String _selectedFilter = 'todos';

  final List<AppFilterItem> _filters = [
    AppFilterItem(label: 'Todos', value: 'todos', isSelected: true),
    AppFilterItem(label: 'Urgente', value: 'urgente'),
    AppFilterItem(label: 'Manutenção', value: 'manutencao'),
    AppFilterItem(label: 'Financeiro', value: 'financeiro'),
  ];

  @override
  void initState() {
    super.initState();
    _realtimeService.initialize();
  }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CENTRAL DE NOTIFICAÇÕES (IN-APP REALTIME)',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _realtimeService.markAllAsRead(),
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Marcar todas como lidas'),
                    ),
                  ],
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
            child: ValueListenableBuilder<List<AppNotification>>(
              valueListenable: _realtimeService.notificationsNotifier,
              builder: (context, notifications, _) {
                final filtered = notifications.where((n) {
                  if (_selectedFilter == 'todos') return true;
                  if (_selectedFilter == 'urgente') return n.type == AppNotificationType.danger;
                  if (_selectedFilter == 'manutencao') {
                    return n.category?.toLowerCase().contains('manutencao') == true ||
                        n.type == AppNotificationType.warning;
                  }
                  if (_selectedFilter == 'financeiro') {
                    return n.category?.toLowerCase().contains('financ') == true;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma notificação no momento.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification item) {
    final bool isUrgente = item.type == AppNotificationType.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.isRead
            ? AppColors.surfaceContainerLowest
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: isUrgente
            ? Border.all(
                color: AppColors.error.withValues(alpha: 0.2),
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
                : (item.type == AppNotificationType.success
                    ? Icons.check_circle_outline
                    : Icons.notifications_active_outlined),
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
                      item.title,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isUrgente ? AppColors.error : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
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
                  item.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _realtimeService.markAsRead(item.id),
            icon: Icon(
              item.isRead ? Icons.done : Icons.mark_email_read_outlined,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
