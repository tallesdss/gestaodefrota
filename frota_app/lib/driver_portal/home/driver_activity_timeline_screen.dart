import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/repositories/timeline_repository.dart';
import '../../core/repositories/auth_repository.dart';
import '../../models/timeline_item.dart';

class DriverActivityTimelineScreen extends StatefulWidget {
  const DriverActivityTimelineScreen({super.key});

  @override
  State<DriverActivityTimelineScreen> createState() =>
      _DriverActivityTimelineScreenState();
}

class _DriverActivityTimelineScreenState
    extends State<DriverActivityTimelineScreen> {
  final TimelineRepository _timelineRepo = TimelineRepository();
  final AuthRepository _authRepo = AuthRepository();
  List<TimelineItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    setState(() => _isLoading = true);
    try {
      final uid = _authRepo.currentUserId;
      final data = uid != null
          ? await _timelineRepo.getDriverTimeline(driverId: uid, page: 1, pageSize: 30)
          : <TimelineItem>[];
      if (mounted) {
        setState(() {
          _items = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.history_toggle_off_outlined,
                          title: 'Nenhuma atividade registrada',
                          description:
                              'Seu histórico de atividades aparecerá aqui conforme você utilizar o aplicativo.',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTimeline,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              final timeStr =
                                  '${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')} às ${item.date.hour.toString().padLeft(2, '0')}:${item.date.minute.toString().padLeft(2, '0')}';
                              return _buildTimelineItem(
                                item.title,
                                item.description,
                                timeStr,
                                Icons.notifications_active_outlined,
                                AppColors.primary,
                              );
                            },
                          ),
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.onSurface,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'HISTÓRICO COMPLETO',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          Text('Linha do Tempo', style: AppTextStyles.headlineMedium),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppIcon(icon: icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
