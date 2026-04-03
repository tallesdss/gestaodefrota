import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/workshop.dart';

class WorkshopDetailScreen extends StatefulWidget {
  final String workshopId;

  const WorkshopDetailScreen({super.key, required this.workshopId});

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock Workshop Data
  late Workshop workshop;

  // Mock data for tabs
  final List<WorkshopDocument> invoices = [
    WorkshopDocument(
      id: '101',
      workshopId: '1',
      title: 'NFe #2045 - Retífica de Cabeçote',
      type: 'NFe',
      date: DateTime.now().subtract(const Duration(days: 5)),
      value: 3500.00,
      status: 'Paid',
    ),
    WorkshopDocument(
      id: '102',
      workshopId: '1',
      title: 'Recibo #892 - Mão de Obra Suspensão',
      type: 'Recibo',
      date: DateTime.now().subtract(const Duration(days: 12)),
      value: 850.00,
      status: 'Paid',
    ),
    WorkshopDocument(
      id: '103',
      workshopId: '1',
      title: 'NFe #2089 - Troca de Turbina',
      type: 'NFe',
      date: DateTime.now().subtract(const Duration(days: 2)),
      value: 7200.00,
      status: 'Pending',
    ),
  ];

  final List<WorkshopParts> parts = [
    WorkshopParts(
      id: 'p1',
      workshopId: '1',
      name: 'Amortecedores Monroe Dianteiros',
      price: 1200.00,
      date: DateTime.now().subtract(const Duration(days: 15)),
      vehiclePlate: 'ABC-1234',
    ),
    WorkshopParts(
      id: 'p2',
      workshopId: '1',
      name: 'Kit de Embreagem LUK',
      price: 2450.00,
      date: DateTime.now().subtract(const Duration(days: 20)),
      vehiclePlate: 'XYZ-9876',
    ),
    WorkshopParts(
      id: 'p3',
      workshopId: '1',
      name: 'Bomba d\'Água Bosch',
      price: 680.00,
      date: DateTime.now().subtract(const Duration(days: 30)),
      vehiclePlate: 'DEF-5678',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Initialize mock workshop based on ID
    workshop = Workshop(
      id: widget.workshopId,
      name: 'Oficina Master Car',
      cnpj: '12.345.678/0001-90',
      phone: '(11) 98765-4321',
      email: 'contato@mastercar.com',
      address: 'Rua das Oficinas, 123 - São Paulo',
      isAccredited: true,
      rating: 4.8,
      totalSpent: 45000.00,
      pendingPayment: 12500.00,
      specializedServices: ['Motor', 'Suspensão', 'Freios', 'Transmissão', 'Injeção'],
      bankInfo: 'Banco do Brasil - AG: 4567 - CC: 12345-6',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(workshop.name, style: AppTextStyles.headlineSmall),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildWorkshopSummary(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFinanceTab(),
                _buildMaintenanceTab(),
                _buildPartsTab(),
                _buildDetailsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      workshop.name,
                      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ),
                Text(workshop.cnpj, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(workshop.rating.toString(), style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.phone, size: 18, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(workshop.phone, style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          _buildSummaryKPI('R\$ ${workshop.totalSpent.toStringAsFixed(0)}', 'Total Gasto'),
          const SizedBox(width: AppSpacing.lg),
          _buildSummaryKPI('R\$ ${workshop.pendingPayment.toStringAsFixed(0)}', 'A Pagar', color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildSummaryKPI(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Financeiro'),
          Tab(text: 'Manutenções'),
          Tab(text: 'Peças'),
          Tab(text: 'Informações'),
        ],
      ),
    );
  }

  Widget _buildFinanceTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSectionTitle('Faturamento & Saldo'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildBalanceCard('Total Pago', 'R\$ ${(workshop.totalSpent - workshop.pendingPayment).toStringAsFixed(2)}', Icons.check_circle_outline, Colors.teal),
            const SizedBox(width: AppSpacing.md),
            _buildBalanceCard('Saldo Devedor', 'R\$ ${workshop.pendingPayment.toStringAsFixed(2)}', Icons.payment, Colors.orange),
            const SizedBox(width: AppSpacing.md),
            _buildBalanceCard('Gasto Médio', 'R\$ 2.450,00', Icons.trending_up, Colors.indigo),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('NF-e e Recibos'),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Lançar Documento'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.outlineVariant)),
          child: Column(
            children: invoices.map((doc) => _buildInvoiceItem(doc)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.md),
            Text(value, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(WorkshopDocument doc) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: (doc.type == 'NFe' ? Colors.blue : Colors.purple).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(doc.type == 'NFe' ? Icons.description_outlined : Icons.receipt_long, 
                    color: doc.type == 'NFe' ? Colors.blue : Colors.purple, size: 20),
      ),
      title: Text(doc.title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text('Data: ${doc.date.day}/${doc.date.month}/${doc.date.year}', style: AppTextStyles.bodySmall),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('R\$ ${doc.value.toStringAsFixed(2)}', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          Text(doc.status == 'Paid' ? 'Pago' : 'Pendente', 
               style: AppTextStyles.labelSmall.copyWith(color: doc.status == 'Paid' ? Colors.teal : Colors.orange)),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildMaintenanceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.outlineVariant)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.car_repair, color: AppColors.primary, size: 20),
            ),
            title: Text('Troca de Embreagem - Veículo ABC-1234', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('ID: #89201 | 12/03/2026 | 145.000 KM', style: AppTextStyles.bodySmall),
            trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ),
        );
      },
    );
  }

  Widget _buildPartsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Histórico de Peças Adquiridas'),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Adicionar Peça'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        DataTable(
          columnSpacing: 20,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          columns: const [
            DataColumn(label: Text('Peça')),
            DataColumn(label: Text('Placa')),
            DataColumn(label: Text('Data')),
            DataColumn(label: Text('Valor')),
          ],
          rows: parts.map((part) => DataRow(cells: [
            DataCell(Text(part.name, style: AppTextStyles.bodySmall)),
            DataCell(Text(part.vehiclePlate, style: AppTextStyles.bodySmall)),
            DataCell(Text('${part.date.day}/${part.date.month}', style: AppTextStyles.bodySmall)),
            DataCell(Text('R\$ ${part.price.toStringAsFixed(0)}', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold))),
          ])).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildDetailRow(Icons.pin_drop_outlined, 'Endereço', workshop.address),
        _buildDetailRow(Icons.email_outlined, 'E-mail', workshop.email),
        _buildDetailRow(Icons.phone_android_outlined, 'Celular', workshop.phone),
        _buildDetailRow(Icons.account_balance_outlined, 'Dados Bancários', workshop.bankInfo ?? 'Não informado'),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionTitle('Especialidades'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: workshop.specializedServices.map((service) => Chip(
            label: Text(service),
            backgroundColor: AppColors.primaryContainer,
            labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
            side: BorderSide.none,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
              Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
    );
  }
}
