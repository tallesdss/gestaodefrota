import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';

enum NotificationType { info, warning, danger }

class NotificationItem {
  final String title;
  final String description;
  final DateTime date;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.isRead = false,
  });
}

class DriverNotificationsScreen extends StatelessWidget {
  const DriverNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      NotificationItem(
        title: 'VENCIMENTO DE MENSALIDADE',
        description: 'Sua parcela da semana 12/03 vence em 2 dias. Evite multas e juros realizando o pagamento via PIX.',
        date: DateTime.now(),
        type: NotificationType.danger,
        isRead: false,
      ),
      NotificationItem(
        title: 'VISTORIA APROVADA',
        description: 'A vistoria do veículo ABC-1234 realizada em 25/03 foi aprovada sem ressalvas pela auditoria.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.info,
        isRead: true,
      ),
      NotificationItem(
        title: 'ALERTA DE MANUTENÇÃO',
        description: 'Faltam 500km para a próxima troca de óleo. Agende pelo suporte técnico.',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.warning,
        isRead: true,
      ),
      NotificationItem(
        title: 'MENSAGEM DA GESTÃO',
        description: 'Lembramos que o uso de rastreador é obrigatório. Mantenha o equipamento sempre ligado.',
        date: DateTime.now().subtract(const Duration(days: 4)),
        type: NotificationType.info,
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) => _buildNotificationCard(notifications[index]),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface, size: 20),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'NOTIFICAÇÕES',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          Text(
            'Central de Alertas',
            style: AppTextStyles.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    Color iconColor;
    IconData iconData;
    Color bgColor;

    switch (item.type) {
      case NotificationType.danger:
        iconColor = AppColors.error;
        iconData = Icons.error_outline;
        bgColor = AppColors.error.withValues(alpha: 0.1);
        break;
      case NotificationType.warning:
        iconColor = const Color(0xFFFFB300);
        iconData = Icons.warning_amber_rounded;
        bgColor = const Color(0xFFFFB300).withValues(alpha: 0.1);
        break;
      case NotificationType.info:
        iconColor = AppColors.primary;
        iconData = Icons.info_outline;
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              icon: iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
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
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _formatDate(item.date),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Hoje';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
