import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/workshop.dart';
import '../../models/maintenance_entry.dart';
import '../../models/vehicle.dart';
import '../../core/repositories/mock_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';


class WorkshopDetailScreen extends StatefulWidget {
  final String workshopId;

  const WorkshopDetailScreen({super.key, required this.workshopId});

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockRepository _repository = MockRepository();

  // Mock Workshop Data
  late Workshop workshop;
  bool _isLoadingMaintenances = true;

  // Mock data for tabs
  late List<WorkshopDocument> _invoices;
  late List<WorkshopParts> _parts;
  late List<MaintenanceEntry> _maintenances = [];
  List<Vehicle> _vehicles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMaintenances();
    _loadVehicles();

    _invoices = [
      WorkshopDocument(
        id: '101',
        workshopId: '1',
        title: 'NFe #2045 - Retífica de Cabeçote',
        type: 'NFe',
        date: DateTime.now().subtract(const Duration(days: 5)),
        value: 3500.00,
        status: 'Paid',
        imageUrl:
            'https://img.freepik.com/vetores-premium/fatura-da-conta-ou-documento-comprovante-fiscal-pagamento-concluido-extrato-de-recibo-faturado_212005-555.jpg',
      ),
      WorkshopDocument(
        id: '102',
        workshopId: '1',
        title: 'Recibo #892 - Mão de Obra Suspensão',
        type: 'Recibo',
        date: DateTime.now().subtract(const Duration(days: 12)),
        value: 850.00,
        status: 'Paid',
        imageUrl:
            'https://static.vecteezy.com/system/resources/previews/007/358/899/original/receipt-invoice-icon-on-transparent-background-free-vector.jpg',
      ),
      WorkshopDocument(
        id: '103',
        workshopId: '1',
        title: 'NFe #2089 - Troca de Turbina',
        type: 'NFe',
        date: DateTime.now().subtract(const Duration(days: 2)),
        value: 7200.00,
        status: 'Pending',
        imageUrl:
            'https://img.freepik.com/vetores-premium/fatura-da-conta-ou-documento-comprovante-fiscal-pagamento-concluido-extrato-de-recibo-faturado_212005-555.jpg',
      ),
    ];

    _parts = [
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
      specializedServices: [
        'Motor',
        'Suspensão',
        'Freios',
        'Transmissão',
        'Injeção',
      ],
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

  Future<void> _loadMaintenances() async {
    final list = await _repository.getMaintenances();
    if (mounted) {
      setState(() {
        _maintenances = list
            .where(
              (m) => m.workshopId == widget.workshopId || m.workshopId == 'w1',
            )
            .toList();
        _isLoadingMaintenances = false;
      });
    }
  }

  Future<void> _loadVehicles() async {
    final list = await _repository.getVehicles();
    if (mounted) {
      setState(() {
        _vehicles = list;
      });
    }
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
            child: const Icon(
              Icons.storefront,
              color: AppColors.primary,
              size: 32,
            ),
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
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ),
                Text(
                  workshop.cnpj,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      workshop.rating.toString(),
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.phone,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(workshop.phone, style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          _buildSummaryKPI(
            'R\$ ${workshop.totalSpent.toStringAsFixed(0)}',
            'Total Gasto',
          ),
          const SizedBox(width: AppSpacing.lg),
          _buildSummaryKPI(
            'R\$ ${workshop.pendingPayment.toStringAsFixed(0)}',
            'A Pagar',
            color: Colors.orange,
          ),
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
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
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
            _buildBalanceCard(
              'Total Pago',
              'R\$ ${(workshop.totalSpent - workshop.pendingPayment).toStringAsFixed(2)}',
              Icons.check_circle_outline,
              Colors.teal,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildBalanceCard(
              'Saldo Devedor',
              'R\$ ${workshop.pendingPayment.toStringAsFixed(2)}',
              Icons.payment,
              Colors.orange,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildBalanceCard(
              'Gasto Médio',
              'R\$ 2.450,00',
              Icons.trending_up,
              Colors.indigo,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('NF-e e Recibos'),
            TextButton.icon(
              onPressed: () => _showDocumentModal(),
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
            side: BorderSide(color: AppColors.outlineVariant),
          ),
          child: Column(
            children: _invoices.map((doc) => _buildInvoiceItem(doc)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
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
          color: (doc.type == 'NFe' ? Colors.blue : Colors.purple).withValues(
            alpha: 0.1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          doc.type == 'NFe' ? Icons.description_outlined : Icons.receipt_long,
          color: doc.type == 'NFe' ? Colors.blue : Colors.purple,
          size: 20,
        ),
      ),
      title: Text(
        doc.title,
        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Data: ${doc.date.day}/${doc.date.month}/${doc.date.year}',
        style: AppTextStyles.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'R\$ ${doc.value.toStringAsFixed(2)}',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            doc.status == 'Paid' ? 'Pago' : 'Pendente',
            style: AppTextStyles.labelSmall.copyWith(
              color: doc.status == 'Paid' ? Colors.teal : Colors.orange,
            ),
          ),
        ],
      ),
      onTap: () => _showDocumentImage(doc),
      onLongPress: () => _showDocumentModal(doc),
    );
  }

  void _showDocumentImage(WorkshopDocument doc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.white,
              title: Text(doc.title, style: AppTextStyles.labelLarge),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: doc.imageUrl != null
                    ? (doc.imageUrl!.startsWith('http')
                        ? Image.network(
                          doc.imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => _errorWidget(),
                        )
                        : Image.file(
                          File(doc.imageUrl!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => _errorWidget(),
                        ))
                    : const Center(child: Text('Documento sem imagem')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 64, color: AppColors.outlineVariant),
          SizedBox(height: 16),
          Text('Erro ao carregar imagem'),
        ],
      ),
    );
  }

  void _showDocumentModal([WorkshopDocument? doc]) {
    final isEditing = doc != null;
    final titleController = TextEditingController(text: doc?.title ?? '');
    final valueController = TextEditingController(
      text: doc?.value.toString() ?? '',
    );
    String type = doc?.type ?? 'NFe';
    String status = doc?.status ?? 'Paid';
    XFile? localImage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Documento' : 'Lançar Documento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título/Descrição',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: ['NFe', 'Recibo']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => type = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Paid', child: Text('Pago')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pendente')),
                ],
                onChanged: (v) => status = v!,
              ),
              const SizedBox(height: 24),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    children: [
                      if (localImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(localImage!.path),
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (doc?.imageUrl != null && doc!.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: doc.imageUrl!.startsWith('http')
                              ? Image.network(
                                doc.imageUrl!,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                              : Image.file(
                                File(doc.imageUrl!),
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final img = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (img != null) {
                            setModalState(() {
                              localImage = img;
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Selecionar Imagem'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () {
                setState(() => _invoices.removeWhere((i) => i.id == doc.id));
                Navigator.pop(context);
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newDoc = WorkshopDocument(
                id: isEditing
                    ? doc.id
                    : DateTime.now().millisecondsSinceEpoch.toString(),
                workshopId: workshop.id,
                title: titleController.text,
                type: type,
                date: isEditing ? doc.date : DateTime.now(),
                value: double.tryParse(valueController.text) ?? 0.0,
                status: status,
                imageUrl: localImage?.path ?? (isEditing ? doc.imageUrl : 'https://img.freepik.com/vetores-premium/fatura-da-conta-ou-documento-comprovante-fiscal-pagamento-concluido-extrato-de-recibo-faturado_212005-555.jpg'),
              );

              setState(() {
                if (isEditing) {
                  final index = _invoices.indexWhere((i) => i.id == doc.id);
                  _invoices[index] = newDoc;
                } else {
                  _invoices.add(newDoc);
                }
              });
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Salvar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    if (_isLoadingMaintenances) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Serviços Realizados'),
            TextButton.icon(
              onPressed: () => _showMaintenanceModal(),
              icon: const Icon(Icons.add_task, size: 18),
              label: const Text('Nova Manutenção'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ..._maintenances.map(
          (m) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.outlineVariant),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(
                  Icons.car_repair,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                m.description,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'ID: #${m.id} | ${m.date.day}/${m.date.month}/${m.date.year} | ${m.kmAtMaintenance} KM',
                style: AppTextStyles.bodySmall,
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
              ),
              onTap: () => _showMaintenanceModal(m),
            ),
          ),
        ),
      ],
    );
  }

  void _showMaintenanceModal([MaintenanceEntry? entry]) {
    final isEditing = entry != null;
    final descController = TextEditingController(
      text: entry?.description ?? '',
    );
    final kmController = TextEditingController(
      text: entry?.kmAtMaintenance.toString() ?? '',
    );
    final costController = TextEditingController(
      text: entry?.cost.toString() ?? '',
    );
    MaintenanceType type = entry?.type ?? MaintenanceType.oilChange;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Manutenção' : 'Nova Manutenção'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descrição do Serviço',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kmController,
                decoration: const InputDecoration(labelText: 'KM do Veículo'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costController,
                decoration: const InputDecoration(
                  labelText: 'Custo Total (R\$)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MaintenanceType>(
                initialValue: type,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Manutenção',
                ),
                items: MaintenanceType.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => type = v!,
              ),
            ],
          ),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () {
                _repository.deleteMaintenance(entry.id);
                setState(
                  () => _maintenances.removeWhere((m) => m.id == entry.id),
                );
                Navigator.pop(context);
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newEntry = MaintenanceEntry(
                id: isEditing
                    ? entry.id
                    : DateTime.now().millisecondsSinceEpoch.toString(),
                vehicleId: isEditing
                    ? entry.vehicleId
                    : '1', // Default mock vehicle
                driverId: null,
                driverName: null,
                type: type,
                description: descController.text,
                date: isEditing ? entry.date : DateTime.now(),
                kmAtMaintenance: int.tryParse(kmController.text) ?? 0,
                cost: double.tryParse(costController.text) ?? 0.0,
                workshop: workshop.name,
                workshopId: workshop.id,
                status: isEditing ? entry.status : MaintenanceStatus.pending,
              );

              if (isEditing) {
                _repository.updateMaintenance(newEntry);
                setState(() {
                  final index = _maintenances.indexWhere(
                    (m) => m.id == entry.id,
                  );
                  _maintenances[index] = newEntry;
                });
              } else {
                _repository.addMaintenance(newEntry);
                setState(() => _maintenances.add(newEntry));
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Salvar' : 'Adicionar'),
          ),
        ],
      ),
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
              onPressed: () => _showPartModal(),
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
          rows: _parts
              .map(
                (part) => DataRow(
                  onLongPress: () => _showPartModal(part),
                  cells: [
                    DataCell(Text(part.name, style: AppTextStyles.bodySmall)),
                    DataCell(
                      Text(part.vehiclePlate, style: AppTextStyles.bodySmall),
                    ),
                    DataCell(
                      Text(
                        '${part.date.day}/${part.date.month}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    DataCell(
                      Text(
                        'R\$ ${part.price.toStringAsFixed(0)}',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _showPartModal([WorkshopParts? part]) {
    final isEditing = part != null;
    final nameController = TextEditingController(text: part?.name ?? '');
    final plateController = TextEditingController(
      text: part?.vehiclePlate ?? '',
    );
    final priceController = TextEditingController(
      text: part?.price.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Peça' : 'Adicionar Peça'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome da Peça'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: plateController.text.isEmpty ? null : plateController.text,
                decoration: const InputDecoration(labelText: 'Veículo'),
                items: _vehicles.map((v) => DropdownMenuItem(
                  value: v.plate,
                  child: Text('${v.model} (${v.plate})'),
                )).toList(),
                onChanged: (v) => plateController.text = v ?? '',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () {
                setState(() => _parts.removeWhere((p) => p.id == part.id));
                Navigator.pop(context);
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPart = WorkshopParts(
                id: isEditing
                    ? part.id
                    : DateTime.now().millisecondsSinceEpoch.toString(),
                workshopId: workshop.id,
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                date: isEditing ? part.date : DateTime.now(),
                vehiclePlate: plateController.text,
              );

              setState(() {
                if (isEditing) {
                  final index = _parts.indexWhere((p) => p.id == part.id);
                  _parts[index] = newPart;
                } else {
                  _parts.add(newPart);
                }
              });
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Salvar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildDetailRow(Icons.pin_drop_outlined, 'Endereço', workshop.address),
        _buildDetailRow(Icons.email_outlined, 'E-mail', workshop.email),
        _buildDetailRow(
          Icons.phone_android_outlined,
          'Celular',
          workshop.phone,
        ),
        _buildDetailRow(
          Icons.account_balance_outlined,
          'Dados Bancários',
          workshop.bankInfo ?? 'Não informado',
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionTitle('Especialidades'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: workshop.specializedServices
              .map(
                (service) => Chip(
                  label: Text(service),
                  backgroundColor: AppColors.primaryContainer,
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                  side: BorderSide.none,
                ),
              )
              .toList(),
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
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }
}
