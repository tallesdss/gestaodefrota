import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/services/realtime_service.dart';

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() => _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  final RealtimeService _realtimeService = RealtimeService();

  @override
  void initState() {
    super.initState();
    _realtimeService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ValueListenableBuilder<List<AppNotification>>(
                valueListenable: _realtimeService.notificationsNotifier,
                builder: (context, notifications, _) {
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma notificação no momento.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) =>
                        _buildNotificationCard(notifications[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              TextButton(
                onPressed: () => _realtimeService.markAllAsRead(),
                child: const Text('Limpar Não Lidas'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'AVISOS & NOTIFICAÇÕES',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          Text('Mensagens da Gestão', style: AppTextStyles.headlineMedium),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification item) {
    Color typeColor;
    IconData typeIcon;

    switch (item.type) {
      case AppNotificationType.danger:
        typeColor = AppColors.error;
        typeIcon = Icons.priority_high;
        break;
      case AppNotificationType.warning:
        typeColor = AppColors.warning;
        typeIcon = Icons.warning_amber_rounded;
        break;
      case AppNotificationType.success:
        typeColor = AppColors.success;
        typeIcon = Icons.check_circle_outline;
        break;
      case AppNotificationType.info:
        typeColor = AppColors.primary;
        typeIcon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: item.isRead
            ? AppColors.surfaceContainerLowest
            : typeColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.isRead
              ? AppColors.outlineVariant.withValues(alpha: 0.2)
              : typeColor.withValues(alpha: 0.4),
          width: item.isRead ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(icon: typeIcon, color: typeColor, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(item.message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
