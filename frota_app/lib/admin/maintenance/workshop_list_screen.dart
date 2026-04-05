import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../models/workshop.dart';

class WorkshopListScreen extends StatefulWidget {
  const WorkshopListScreen({super.key});

  @override
  State<WorkshopListScreen> createState() => _WorkshopListScreenState();
}

class _WorkshopListScreenState extends State<WorkshopListScreen> {
  final List<Workshop> _workshops = [
    Workshop(
      id: '1',
      name: 'Oficina Master Car',
      cnpj: '12.345.678/0001-90',
      phone: '(11) 98765-4321',
      email: 'contato@mastercar.com',
      address: 'Rua das Oficinas, 123 - São Paulo',
      isAccredited: true,
      rating: 4.8,
      totalSpent: 45000.00,
      pendingPayment: 12500.00,
      specializedServices: ['Motor', 'Suspensão', 'Freios'],
    ),
    Workshop(
      id: '2',
      name: 'Centro Automotivo Speed',
      cnpj: '98.765.432/0001-11',
      phone: '(11) 91234-5678',
      email: 'speed@centro.com',
      address: 'Av. Brasil, 5000 - São Paulo',
      isAccredited: true,
      rating: 4.5,
      totalSpent: 32000.00,
      pendingPayment: 0.00,
      specializedServices: ['Pneus', 'Alinhamento'],
    ),
    Workshop(
      id: '3',
      name: 'Mecânica do Juca',
      cnpj: '45.678.901/0001-22',
      phone: '(11) 99887-7665',
      email: 'juca@mecanica.com',
      address: 'Rua do Comercio, 45 - São Bernardo',
      isAccredited: false,
      rating: 3.9,
      totalSpent: 8500.00,
      pendingPayment: 4200.00,
      specializedServices: ['Motor', 'Câmbio'],
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredWorkshops = _workshops.where((w) {
      return w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.cnpj.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),
            _buildStats(),
            const SizedBox(height: AppSpacing.xl),
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: _buildWorkshopList(filteredWorkshops)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.adminWorkshopForm),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Oficina',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestão de Oficinas',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Controle de parceiros, manutenções e fluxo financeiro',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final totalWorkshops = _workshops.length;
    final accredited = _workshops.where((w) => w.isAccredited).length;
    final pendingTotal = _workshops.fold(
      0.0,
      (sum, w) => sum + w.pendingPayment,
    );

    return Row(
      children: [
        _buildStatCard(
          'Total de Oficinas',
          totalWorkshops.toString(),
          Icons.build_circle,
        ),
        const SizedBox(width: AppSpacing.md),
        _buildStatCard(
          'Credenciadas',
          accredited.toString(),
          Icons.verified_user,
          color: Colors.blue,
        ),
        const SizedBox(width: AppSpacing.md),
        _buildStatCard(
          'A Pagar Total',
          'R\$ ${pendingTotal.toStringAsFixed(2)}',
          Icons.payment,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Buscar oficina por nome ou CNPJ...',
          icon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildWorkshopList(List<Workshop> workshops) {
    if (workshops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhuma oficina encontrada', style: AppTextStyles.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: workshops.length,
      itemBuilder: (context, index) {
        final workshop = workshops[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Avatar or Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Workshop Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            workshop.name,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (workshop.isAccredited) ...[
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      Text(workshop.cnpj, style: AppTextStyles.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            workshop.rating.toString(),
                            style: AppTextStyles.labelSmall,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Icon(
                            Icons.payment,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pendentes: R\$ ${workshop.pendingPayment.toStringAsFixed(2)}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.analytics_outlined,
                      color: Colors.indigo,
                      tooltip: 'Ver Detalhes',
                      onTap: () => context.push(
                        '${AppRoutes.adminWorkshops}/detail/${workshop.id}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      color: Colors.blue,
                      tooltip: 'Editar',
                      onTap: () => context.push(
                        AppRoutes.adminWorkshopForm,
                        extra: workshop,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      color: Colors.red,
                      tooltip: 'Remover',
                      onTap: () => _confirmDelete(workshop),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  void _confirmDelete(Workshop workshop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Oficina'),
        content: Text('Deseja realmente remover a oficina "${workshop.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _workshops.removeWhere((w) => w.id == workshop.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Oficina removida com sucesso!')),
              );
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
