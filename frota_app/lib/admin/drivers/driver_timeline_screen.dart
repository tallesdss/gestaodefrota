import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/timeline_item.dart';

class DriverTimelineScreen extends StatefulWidget {
  final String driverId;

  const DriverTimelineScreen({super.key, required this.driverId});

  @override
  State<DriverTimelineScreen> createState() => _DriverTimelineScreenState();
}

class _DriverTimelineScreenState extends State<DriverTimelineScreen> {
  final MockRepository _repository = MockRepository();
  final List<TimelineItem> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final newItems = await _repository.getDriverTimeline(
        driverId: widget.driverId,
        page: _currentPage,
        pageSize: 10,
      );

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _isLoading = false;
        if (newItems.length < 10) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        title: Text(
          'HISTÓRICO COMPLETO',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _items.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: _items.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final item = _items[index];
                return _buildTimelineItem(item);
              },
            ),
    );
  }

  Widget _buildTimelineItem(TimelineItem item) {
    final date = DateFormat('dd/MM/yyyy').format(item.date);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                      Text(date, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                  if (item.type != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _buildTypeTag(item.type!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTag(String type) {
    Color color;
    String label;

    switch (type) {
      case 'maintenance':
        color = AppColors.error;
        label = 'MANUTENÇÃO';
        break;
      case 'financial':
        color = AppColors.success;
        label = 'FINANCEIRO';
        break;
      case 'document':
        color = AppColors.primary;
        label = 'DOCUMENTO';
        break;
      case 'vehicle':
        color = AppColors.secondary;
        label = 'VEÍCULO';
        break;
      default:
        color = AppColors.onSurfaceVariant;
        label = 'OUTROS';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
