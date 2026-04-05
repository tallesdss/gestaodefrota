import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../core/widgets/vehicle_grid_card.dart';
import '../../models/vehicle.dart';
import '../../core/routes/app_routes.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final MockRepository _repository = MockRepository();
  List<Vehicle> _vehicles = [];
  List<Vehicle> _filteredVehicles = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    final list = await _repository.getVehicles();
    setState(() {
      _vehicles = list;
      _filteredVehicles = list;
      _isLoading = false;
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Todos') {
        _filteredVehicles = _vehicles;
      } else if (filter == 'Alugados') {
        _filteredVehicles = _vehicles
            .where((v) => v.status == VehicleStatus.rented)
            .toList();
      } else if (filter == 'Livres') {
        _filteredVehicles = _vehicles
            .where((v) => v.status == VehicleStatus.available)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'MINHA FROTA',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.onSurface),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.filter_list_outlined,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Fast Filter Row
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    children: [
                      _buildFilterChip('Todos'),
                      const SizedBox(width: AppSpacing.md),
                      _buildFilterChip('Alugados'),
                      const SizedBox(width: AppSpacing.md),
                      _buildFilterChip('Livres'),
                    ],
                  ),
                ),
                // Grid View
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: AppSpacing.xl,
                            mainAxisSpacing: AppSpacing.xl,
                            childAspectRatio: 0.82,
                          ),
                      itemCount: _filteredVehicles.length,
                      itemBuilder: (context, index) {
                        return VehicleGridCard(
                          vehicle: _filteredVehicles[index],
                          onTap: () => context.push(
                            '/admin/vehicles/detail/${_filteredVehicles[index].id}',
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.adminVehicleForm),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _applyFilter(label);
      },
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    );
  }
}
