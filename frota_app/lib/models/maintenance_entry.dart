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
      case MaintenanceType.oilChange: return 'Troca de Óleo';
      case MaintenanceType.tires: return 'Pneus';
      case MaintenanceType.brakes: return 'Freios';
      case MaintenanceType.suspension: return 'Suspensão';
      case MaintenanceType.generalRevision: return 'Revisão Geral';
      case MaintenanceType.motor: return 'Motor';
      case MaintenanceType.transmission: return 'Transmissão';
      case MaintenanceType.electrical: return 'Elétrica';
      case MaintenanceType.bodywork: return 'Funilaria';
      case MaintenanceType.other: return 'Outros';
    }
  }
}

enum MaintenanceStatus {
  paid,
  pending,
  cancelled;

  String get label {
    switch (this) {
      case MaintenanceStatus.paid: return 'Pago';
      case MaintenanceStatus.pending: return 'Pendente';
      case MaintenanceStatus.cancelled: return 'Cancelado';
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
  // Proxy for simple value if needed
  double get value => total;

  factory MaintenancePart.fromMap(Map<String, dynamic> map) {
    return MaintenancePart(
      name: map['name'],
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unitPrice'] ?? map['value'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
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
    return MaintenanceEntry(
      id: map['id'],
      vehicleId: map['vehicleId'],
      driverId: map['driverId'],
      driverName: map['driverName'],
      type: MaintenanceType.values.firstWhere((e) => e.name == (map['type'] ?? 'oilChange'), orElse: () => MaintenanceType.oilChange),
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      kmAtMaintenance: map['kmAtMaintenance'] ?? 0,
      cost: (map['cost'] ?? 0.0).toDouble(),
      workshop: map['workshop'] ?? '',
      workshopId: map['workshopId'],
      status: MaintenanceStatus.values.firstWhere((e) => e.name == (map['status'] ?? 'pending'), orElse: () => MaintenanceStatus.pending),
      parts: (map['parts'] as List? ?? []).map((p) => MaintenancePart.fromMap(p)).toList(),
      invoiceNumber: map['invoiceNumber'],
      invoiceUrl: map['invoiceUrl'],
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
}
