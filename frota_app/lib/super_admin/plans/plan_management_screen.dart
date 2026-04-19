import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../core/saas_financial_manager.dart';
import '../models/saas_plan.dart';
import '../core/audit_manager.dart';
import '../models/audit_entry.dart';

class PlanManagementScreen extends StatefulWidget {
  const PlanManagementScreen({super.key});

  @override
  State<PlanManagementScreen> createState() => _PlanManagementScreenState();
}

class _PlanManagementScreenState extends State<PlanManagementScreen> {
  final _financialManager = SaaSFinancialManager();

  @override
  void initState() {
    super.initState();
    _financialManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _financialManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _showPlanDialog([SaaSPlan? plan]) {
    final isEditing = plan != null;
    final nameController = TextEditingController(text: plan?.name ?? '');
    final priceController = TextEditingController(text: plan?.price.toString() ?? '');
    final vehiclesController = TextEditingController(text: plan?.maxVehicles.toString() ?? '');
    final usersController = TextEditingController(text: plan?.maxUsers.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(isEditing ? 'Editar Plano' : 'Novo Plano', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Nome do Plano', nameController),
              _buildField('Preço Mensal (R\$)', priceController, isNumber: true),
              _buildField('Limite de Veículos (999=Ilimitado)', vehiclesController, isNumber: true),
              _buildField('Limite de Usuários (999=Ilimitado)', usersController, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPlan = SaaSPlan(
                id: plan?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0,
                maxVehicles: int.tryParse(vehiclesController.text) ?? 0,
                maxUsers: int.tryParse(usersController.text) ?? 0,
                color: plan?.color ?? AppColors.accent,
                isPopular: plan?.isPopular ?? false,
              );

              if (isEditing) {
                _financialManager.updatePlan(newPlan);
                AuditManager().logAction(
                  action: AuditAction.planUpdated,
                  target: newPlan.name,
                  details: 'Plano "${newPlan.name}" atualizado (R\$ ${newPlan.price}).',
                );
              } else {
                _financialManager.addPlan(newPlan);
                AuditManager().logAction(
                  action: AuditAction.planCreated,
                  target: newPlan.name,
                  details: 'Novo plano "${newPlan.name}" criado com limite de ${newPlan.maxVehicles} veículos.',
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black),
            child: Text(isEditing ? 'Salvar Alterações' : 'Criar Plano'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: _financialManager.plans.length,
              itemBuilder: (context, index) {
                final plan = _financialManager.plans[index];
                return _PlanCard(
                  plan: plan,
                  onEdit: () => _showPlanDialog(plan),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuração de Planos',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              'Gerencie os pacotes e limites oferecidos aos clientes.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showPlanDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Novo Plano'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SaaSPlan plan;
  final VoidCallback onEdit;

  const _PlanCard({
    required this.plan,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: plan.isPopular ? plan.color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
          width: plan.isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (plan.isPopular)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: plan.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MAIS VENDIDO',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.layers_outlined, color: plan.color, size: 32),
                const SizedBox(height: 24),
                Text(
                  plan.name,
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${plan.price.toInt()}',
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6, left: 4),
                      child: Text('/mês', style: TextStyle(color: Colors.white54)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(color: Colors.white10),
                const SizedBox(height: 24),
                _FeatureItem(icon: Icons.directions_car, label: plan.maxVehicles >= 999 ? 'Veículos Ilimitados' : 'Até ${plan.maxVehicles} veículos'),
                _FeatureItem(icon: Icons.people, label: plan.maxUsers >= 999 ? 'Usuários Ilimitados' : 'Até ${plan.maxUsers} usuários'),
                _FeatureItem(icon: Icons.support_agent, label: 'Suporte ${plan.maxVehicles > 50 ? 'Prioritário' : 'Normal'}'),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: plan.color.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Editar Definições', style: TextStyle(color: plan.color)),
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white38),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }
}

