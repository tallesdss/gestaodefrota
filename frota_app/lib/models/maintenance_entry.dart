enum MaintenanceType { 
  oilChange, 
  tires, 
  brakes, 
  suspension, 
  generalRevision, 
  other 
}

class MaintenanceEntry {
  final String id;
  final String vehicleId;
  final MaintenanceType type;
  final String description;
  final DateTime date;
  final int kmAtMaintenance;
  final double cost;
  final String workshop;

  MaintenanceEntry({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.description,
    required this.date,
    required this.kmAtMaintenance,
    required this.cost,
    required this.workshop,
  });

  factory MaintenanceEntry.fromMap(Map<String, dynamic> map) {
    return MaintenanceEntry(
      id: map['id'],
      vehicleId: map['vehicleId'],
      type: MaintenanceType.values.firstWhere((e) => e.name == map['type']),
      description: map['description'],
      date: DateTime.parse(map['date']),
      kmAtMaintenance: map['kmAtMaintenance'],
      cost: map['cost'].toDouble(),
      workshop: map['workshop'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'type': type.name,
      'description': description,
      'date': date.toIso8601String(),
      'kmAtMaintenance': kmAtMaintenance,
      'cost': cost,
      'workshop': workshop,
    };
  }
}
