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
  final String name;
  final int quantity;
  final double unitPrice;

  MaintenancePart({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
  double get value => total;

  factory MaintenancePart.fromMap(Map<String, dynamic> map) {
    return MaintenancePart(
      name: map['nome'] ?? map['name'] ?? '',
      quantity: (map['quantidade'] ?? map['quantity'] ?? 1) as int,
      unitPrice: (map['valor_unitario'] ?? map['unitPrice'] ?? map['value'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'quantity': quantity, 'unitPrice': unitPrice};
  }
}

class MaintenanceEntry {
  final String id;
  final String vehicleId;
  final String? driverId;
  final String? driverName;
  final MaintenanceType type;
  final String description;
  final DateTime date;
  final int kmAtMaintenance;
  final double cost;
  final String workshop;
  final String? workshopId;
  final MaintenanceStatus status;
  final List<MaintenancePart> parts;
  final String? invoiceNumber;
  final String? invoiceUrl;

  MaintenanceEntry({
    required this.id,
    required this.vehicleId,
    this.driverId,
    this.driverName,
    required this.type,
    required this.description,
    required this.date,
    required this.kmAtMaintenance,
    required this.cost,
    required this.workshop,
    this.workshopId,
    this.status = MaintenanceStatus.pending,
    this.parts = const [],
    this.invoiceNumber,
    this.invoiceUrl,
  });

  factory MaintenanceEntry.fromMap(Map<String, dynamic> map) {
    MaintenanceStatus parseStatus(dynamic val) {
      if (val == null) return MaintenanceStatus.pending;
      final s = val.toString().toLowerCase();
      if (s == 'pago' || s == 'paid' || s == 'concluido') return MaintenanceStatus.paid;
      if (s == 'cancelado' || s == 'cancelled') return MaintenanceStatus.cancelled;
      return MaintenanceStatus.pending;
    }

    return MaintenanceEntry(
      id: (map['id'] ?? '').toString(),
      vehicleId: map['veiculo_id'] ?? map['vehicleId'] ?? '',
      driverId: map['motorista_id'] ?? map['driverId'],
      driverName: map['motorista_nome'] ?? map['driverName'],
      type: MaintenanceType.values.firstWhere(
        (e) => e.name == (map['tipo'] ?? map['type'] ?? 'oilChange'),
        orElse: () => MaintenanceType.oilChange,
      ),
      description: map['descricao'] ?? map['description'] ?? '',
      date: DateTime.tryParse(map['data_servico'] ?? map['date'] ?? '') ?? DateTime.now(),
      kmAtMaintenance: (map['odometro_km'] ?? map['kmAtMaintenance'] ?? 0) as int,
      cost: (map['custo_total'] ?? map['cost'] ?? 0.0).toDouble(),
      workshop: map['oficina_nome'] ?? map['workshop'] ?? '',
      workshopId: map['oficina_id'] ?? map['workshopId'],
      status: parseStatus(map['status']),
      parts: (map['lista_pecas_json'] ?? map['parts'] as List? ?? [])
          .map((p) => MaintenancePart.fromMap(p is Map<String, dynamic> ? p : {}))
          .toList(),
      invoiceNumber: map['numero_nfe'] ?? map['invoiceNumber'],
      invoiceUrl: map['nota_fiscal_nfe_url'] ?? map['invoiceUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'driverName': driverName,
      'type': type.name,
      'description': description,
      'date': date.toIso8601String(),
      'kmAtMaintenance': kmAtMaintenance,
      'cost': cost,
      'workshop': workshop,
      'workshopId': workshopId,
      'status': status.name,
      'parts': parts.map((p) => p.toMap()).toList(),
      'invoiceNumber': invoiceNumber,
      'invoiceUrl': invoiceUrl,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'veiculo_id': vehicleId,
      'oficina_id': workshopId,
      'descricao': description,
      'custo_total': cost,
      'data_servico': date.toIso8601String().split('T')[0],
      'odometro_km': kmAtMaintenance,
      'nota_fiscal_nfe_url': invoiceUrl,
      'status': status == MaintenanceStatus.paid ? 'concluido' : 'agendado',
      'lista_pecas_json': parts.map((p) => p.toMap()).toList(),
    };
  }
}
