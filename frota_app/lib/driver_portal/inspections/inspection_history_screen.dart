import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frota_app/core/theme/app_colors.dart';
import 'package:frota_app/core/theme/app_text_styles.dart';
import 'package:frota_app/core/theme/app_spacing.dart';
import 'package:frota_app/core/widgets/app_icon.dart';
import 'package:frota_app/core/widgets/app_empty_state.dart';
import 'package:frota_app/core/routes/app_routes.dart';
import 'package:frota_app/core/repositories/inspection_repository.dart';
import 'package:frota_app/core/repositories/auth_repository.dart';
import 'package:frota_app/models/inspection.dart';

class InspectionHistoryScreen extends StatefulWidget {
  const InspectionHistoryScreen({super.key});

  @override
  State<InspectionHistoryScreen> createState() =>
      _InspectionHistoryScreenState();
}

class _InspectionHistoryScreenState extends State<InspectionHistoryScreen> {
  final InspectionRepository _inspectionRepo = InspectionRepository();
  final AuthRepository _authRepo = AuthRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Inspection> _inspections = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tudo';
  final List<String> _filters = ['Tudo', 'Check-in', 'Check-out'];

  @override
  void initState() {
    super.initState();
    _loadInspections();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInspections() async {
    setState(() => _isLoading = true);
    try {
      final uid = _authRepo.currentUserId;
      final data = uid != null
          ? await _inspectionRepo.getInspections(driverId: uid)
          : <Inspection>[];
      if (mounted) {
        setState(() {
          _inspections = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchTerm = _searchController.text.trim().toLowerCase();
    final filtered = _inspections.where((insp) {
      if (_selectedFilter == 'Check-in' && insp.type != InspectionType.checkin) return false;
      if (_selectedFilter == 'Check-out' && insp.type != InspectionType.checkout) return false;

      if (searchTerm.isNotEmpty) {
        final matchesId = insp.id.toLowerCase().contains(searchTerm) ||
            insp.vehicleId.toLowerCase().contains(searchTerm);
        if (!matchesId) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'HISTÓRICO DE VISTORIAS',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const AppIcon(icon: Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Nenhuma vistoria encontrada',
                        description: 'Suas vistorias realizadas aparecerão aqui.',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadInspections,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.lg),
                          itemBuilder: (context, index) {
                            return _buildHistoryCard(context, filtered[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      color: AppColors.surface,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar por ID ou veículo...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (v) => setState(() => _selectedFilter = filter),
                    backgroundColor: AppColors.surfaceContainerLow,
                    selectedColor: AppColors.primary,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Inspection inspection) {
    final isCheckIn = inspection.type == InspectionType.checkin;
    final isCheckOut = inspection.type == InspectionType.checkout;

    final type = isCheckIn ? 'CHECK-IN' : (isCheckOut ? 'CHECK-OUT' : 'VISTORIA');
    final typeColor = isCheckIn ? AppColors.success : (isCheckOut ? AppColors.primary : AppColors.warning);

    final dateStr =
        '${inspection.dateTime.day.toString().padLeft(2, '0')}/${inspection.dateTime.month.toString().padLeft(2, '0')}/${inspection.dateTime.year}';
    final timeStr =
        '${inspection.dateTime.hour.toString().padLeft(2, '0')}:${inspection.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCheckIn ? Icons.login : (isCheckOut ? Icons.logout : Icons.sync),
                      size: 14,
                      color: typeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'KM: ${inspection.kmAtInspection}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vistoria Digital',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: #${inspection.id.substring(0, inspection.id.length > 8 ? 8 : inspection.id.length)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dateStr,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _buildInfoChip(
                Icons.photo_library_outlined,
                '${inspection.photos.length} fotos',
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildInfoChip(
                Icons.checklist_outlined,
                '${inspection.checklist.length} itens',
              ),
              const Spacer(),
              InkWell(
                onTap: () => context.push(
                  AppRoutes.driverInspectionDetail.replaceFirst(':id', inspection.id),
                  extra: inspection,
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'DETALHES',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
