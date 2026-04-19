import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../core/saas_financial_manager.dart';
import '../models/promo_code.dart';
import '../core/audit_manager.dart';
import '../models/audit_entry.dart';

class PromoManagementScreen extends StatefulWidget {
  const PromoManagementScreen({super.key});

  @override
  State<PromoManagementScreen> createState() => _PromoManagementScreenState();
}

class _PromoManagementScreenState extends State<PromoManagementScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cupons e Promoções',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gerencie códigos de desconto e campanhas de marketing.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddPromoDialog(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Novo Cupom'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(180, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.5,
              ),
              itemCount: _financialManager.promoCodes.length,
              itemBuilder: (context, index) {
                final promo = _financialManager.promoCodes[index];
                return _PromoCard(promo: promo, manager: _financialManager);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPromoDialog(BuildContext context) {
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    PromoType type = PromoType.percentage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          'Criar Novo Cupom',
          style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Código do Cupom',
                labelStyle: TextStyle(color: Colors.white54),
                hintText: 'Ex: VERÃO2026',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: valueController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<PromoType>(
                  value: type,
                  dropdownColor: const Color(0xFF1E293B),
                  items: PromoType.values.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t == PromoType.percentage ? '%' : 'R\$', style: const TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: (v) => type = v!,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final newPromo = PromoCode(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                code: codeController.text.toUpperCase(),
                type: type,
                value: double.tryParse(valueController.text) ?? 0,
              );
              _financialManager.addPromoCode(newPromo);
              AuditManager().logAction(
                action: AuditAction.promoCodeCreated,
                target: newPromo.code,
                details: 'Novo cupom de desconto criado: ${newPromo.discountLabel}',
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Criar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final PromoCode promo;
  final SaaSFinancialManager manager;

  const _PromoCard({required this.promo, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  promo.code,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              Switch(
                value: promo.isActive,
                onChanged: (_) => manager.togglePromoStatus(promo.id),
                activeThumbColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Desconto de ${promo.discountLabel}',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uso: ${promo.usageCount}${promo.usageLimit != null ? ' / ${promo.usageLimit}' : ''}',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                  ),
                  if (promo.expiryDate != null)
                    Text(
                      'Expira: ${DateFormat('dd/MM/yy').format(promo.expiryDate!)}',
                      style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 11),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
                onPressed: () => manager.removePromoCode(promo.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
