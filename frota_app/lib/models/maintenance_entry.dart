enum MaintenanceType {
  oilChange,
  tires,
  brakes,
  suspension,
  generalRevision,
  motor,
  transmission,
  electrical,
  bodywork,
  other;

  String get label {
    switch (this) {
      case MaintenanceType.oilChange:
        return 'Troca de Óleo';
      case MaintenanceType.tires:
        return 'Pneus';
      case MaintenanceType.brakes:
        return 'Freios';
      case MaintenanceType.suspension:
        return 'Suspensão';
      case MaintenanceType.generalRevision:
        return 'Revisão Geral';
      case MaintenanceType.motor:
        return 'Motor';
      case MaintenanceType.transmission:
        return 'Transmissão';
      case MaintenanceType.electrical:
        return 'Elétrica';
      case MaintenanceType.bodywork:
        return 'Funilaria';
      case MaintenanceType.other:
        return 'Outros';
    }
  }

  String get dbValue {
    switch (this) {
      case MaintenanceType.generalRevision:
        return 'revisao_geral';
      case MaintenanceType.bodywork:
        return 'funilaria';
      case MaintenanceType.tires:
        return 'pneus';
      case MaintenanceType.electrical:
        return 'eletrica';
      case MaintenanceType.oilChange:
      case MaintenanceType.brakes:
      case MaintenanceType.suspension:
      case MaintenanceType.motor:
      case MaintenanceType.transmission:
        return 'corretiva';
      case MaintenanceType.other:
        return 'outro';
    }
  }
}

enum MaintenanceStatus {
  paid,
  pending,
  cancelled;

  String get label {
    switch (this) {
      case MaintenanceStatus.paid:
        return 'Pago';
      case MaintenanceStatus.pending:
        return 'Pendente';
      case MaintenanceStatus.cancelled:
        return 'Cancelado';
    }
  }
}

class MaintenancePart {
  final String? id;
  final String? maintenanceId;
  final String name;
  final int quantity;
  final double unitPrice;

  MaintenancePart({
    this.id,
    this.maintenanceId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
  double get value => total;

  factory MaintenancePart.fromMap(Map<String, dynamic> map) {
    return MaintenancePart(
      id: map['id']?.toString(),
      maintenanceId: map['manutencao_id']?.toString(),
      name: (map['descricao_peca'] ?? map['nome'] ?? map['name'] ?? '').toString(),
      quantity: (map['quantidade'] ?? map['quantity'] ?? 1) is int
          ? (map['quantidade'] ?? map['quantity'] ?? 1) as int
          : int.tryParse((map['quantidade'] ?? map['quantity'] ?? '1').toString()) ?? 1,
      unitPrice: (map['valor_unitario'] ?? map['unitPrice'] ?? map['value'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maintenanceId': maintenanceId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  Map<String, dynamic> toDatabaseMap(String parentMaintenanceId) {
    return {
      'manutencao_id': parentMaintenanceId,
      'descricao_peca': name,
      'quantidade': quantity > 0 ? quantity : 1,
      'valor_unitario': unitPrice >= 0 ? unitPrice : 0.0,
    };
  }
}

class MaintenanceEntry {
  final String id;
  final String vehicleId;
  final String? driverId;
  final String? driverName;
  final String? categoryId;
  final MaintenanceType type;
  final String description;
  final DateTime date;
  final int kmAtMaintenance;
  final double cost;
  final double laborCost;
  final double partsCost;
  final String workshop;
  final String? workshopId;
  final MaintenanceStatus status;
  final List<MaintenancePart> parts;
  final String? invoiceNumber;
  final String? invoiceUrl;
  final String? receiptUrl;

  MaintenanceEntry({
    required this.id,
    required this.vehicleId,
    this.driverId,
    this.driverName,
    this.categoryId,
    required this.type,
    required this.description,
    required this.date,
    required this.kmAtMaintenance,
    required this.cost,
    this.laborCost = 0.0,
    this.partsCost = 0.0,
    required this.workshop,
    this.workshopId,
    this.status = MaintenanceStatus.pending,
    this.parts = const [],
    this.invoiceNumber,
    this.invoiceUrl,
    this.receiptUrl,
  });

  factory MaintenanceEntry.fromMap(Map<String, dynamic> map) {
    MaintenanceStatus parseStatus(dynamic val) {
      if (val == null) return MaintenanceStatus.pending;
      final s = val.toString().toLowerCase();
      if (s == 'pago' || s == 'paid' || s == 'concluido') return MaintenanceStatus.paid;
      if (s == 'cancelado' || s == 'cancelled') return MaintenanceStatus.cancelled;
      return MaintenanceStatus.pending;
    }

    MaintenanceType parseType(dynamic val) {
      if (val == null) return MaintenanceType.oilChange;
      final s = val.toString().toLowerCase();
      if (s == 'revisao_geral') return MaintenanceType.generalRevision;
      if (s == 'funilaria') return MaintenanceType.bodywork;
      if (s == 'pneus') return MaintenanceType.tires;
      if (s == 'eletrica') return MaintenanceType.electrical;
      if (s == 'corretiva') return MaintenanceType.motor;
      return MaintenanceType.values.firstWhere(
        (e) => e.name == val,
        orElse: () => MaintenanceType.oilChange,
      );
    }

    List<MaintenancePart> partsList = [];
    if (map['itens_manutencao'] is List) {
      partsList = (map['itens_manutencao'] as List)
          .map((p) => MaintenancePart.fromMap(p as Map<String, dynamic>))
          .toList();
    } else if (map['parts'] is List || map['lista_pecas_json'] is List) {
      final list = (map['parts'] ?? map['lista_pecas_json']) as List;
      partsList = list
          .map((p) => MaintenancePart.fromMap(p is Map<String, dynamic> ? p : {}))
          .toList();
    }

    final totalCost = (map['custo_total'] ?? map['cost'] ?? 0.0).toDouble();
    final labor = (map['custo_mao_de_obra'] ?? map['laborCost'] ?? 0.0).toDouble();
    final partsCostCalculated = (map['custo_pecas'] ?? map['partsCost'] ?? (totalCost - labor)).toDouble();

    return MaintenanceEntry(
      id: (map['id'] ?? '').toString(),
      vehicleId: (map['veiculo_id'] ?? map['vehicleId'] ?? '').toString(),
      driverId: (map['motorista_id'] ?? map['driverId'])?.toString(),
      driverName: (map['motorista_nome'] ?? map['driverName'])?.toString(),
      categoryId: (map['categoria_id'] ?? map['categoryId'])?.toString(),
      type: parseType(map['tipo_manutencao'] ?? map['tipo'] ?? map['type']),
      description: (map['descricao'] ?? map['description'] ?? '').toString(),
      date: DateTime.tryParse((map['data_servico'] ?? map['date'] ?? '').toString()) ?? DateTime.now(),
      kmAtMaintenance: (map['odometro_km'] ?? map['kmAtMaintenance'] ?? 0) is int
          ? (map['odometro_km'] ?? map['kmAtMaintenance'] ?? 0) as int
          : int.tryParse((map['odometro_km'] ?? map['kmAtMaintenance'] ?? '0').toString()) ?? 0,
      cost: totalCost,
      laborCost: labor,
      partsCost: partsCostCalculated >= 0 ? partsCostCalculated : 0.0,
      workshop: (map['oficinas'] is Map ? (map['oficinas']['nome_fantasia'] ?? '') : (map['oficina_nome'] ?? map['workshop'] ?? '')).toString(),
      workshopId: (map['oficina_id'] ?? map['workshopId'])?.toString(),
      status: parseStatus(map['status']),
      parts: partsList,
      invoiceNumber: (map['numero_nfe'] ?? map['invoiceNumber'])?.toString(),
      invoiceUrl: (map['nota_fiscal_nfe_url'] ?? map['invoiceUrl'])?.toString(),
      receiptUrl: (map['comprovante_url'] ?? map['receiptUrl'])?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'driverName': driverName,
      'categoryId': categoryId,
      'type': type.name,
      'description': description,
      'date': date.toIso8601String(),
      'kmAtMaintenance': kmAtMaintenance,
      'cost': cost,
      'laborCost': laborCost,
      'partsCost': partsCost,
      'workshop': workshop,
      'workshopId': workshopId,
      'status': status.name,
      'parts': parts.map((p) => p.toMap()).toList(),
      'invoiceNumber': invoiceNumber,
      'invoiceUrl': invoiceUrl,
      'receiptUrl': receiptUrl,
    };
  }

  /// Mapeamento para inserção na tabela `manutencoes` do Supabase
  Map<String, dynamic> toDatabaseMap({String? defaultCategoryId, String? defaultWorkshopId}) {
    String statusStr = 'agendado';
    if (status == MaintenanceStatus.paid) {
      statusStr = 'concluido';
    } else if (status == MaintenanceStatus.cancelled) {
      statusStr = 'cancelado';
    }

    final data = <String, dynamic>{
      'veiculo_id': vehicleId,
      'oficina_id': workshopId ?? defaultWorkshopId ?? '10000000-0000-0000-0000-000000000001',
      'categoria_id': categoryId ?? defaultCategoryId ?? '20000000-0000-0000-0000-000000000002',
      'tipo_manutencao': type.dbValue,
      'descricao': description.trim(),
      'odometro_km': kmAtMaintenance,
      'data_servico': date.toIso8601String().split('T')[0],
      'custo_mao_de_obra': laborCost,
      'custo_pecas': partsCost > 0 ? partsCost : (cost - laborCost >= 0 ? cost - laborCost : 0.0),
      'custo_total': cost,
      'status': statusStr,
    };

    if (id.isNotEmpty && id.contains('-')) {
      data['id'] = id;
    }
    if (invoiceUrl != null && invoiceUrl!.isNotEmpty) {
      data['nota_fiscal_nfe_url'] = invoiceUrl;
    }
    if (receiptUrl != null && receiptUrl!.isNotEmpty) {
      data['comprovante_url'] = receiptUrl;
    }

    return data;
  }
}
