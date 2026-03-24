enum InspectionType { 
  checkin, 
  checkout 
}

class Inspection {
  final String id;
  final String vehicleId;
  final String driverId;
  final InspectionType type;
  final DateTime dateTime;
  final int kmAtInspection;
  final double fuelLevel;
  final List<String> photos; // Asset paths or URLs
  final String notes;
  final bool hasNewDamage;

  Inspection({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.type,
    required this.dateTime,
    required this.kmAtInspection,
    required this.fuelLevel,
    required this.photos,
    required this.notes,
    required this.hasNewDamage,
  });

  factory Inspection.fromMap(Map<String, dynamic> map) {
    return Inspection(
      id: map['id'],
      vehicleId: map['vehicleId'],
      driverId: map['driverId'],
      type: InspectionType.values.firstWhere((e) => e.name == map['type']),
      dateTime: DateTime.parse(map['dateTime']),
      kmAtInspection: map['kmAtInspection'],
      fuelLevel: map['fuelLevel'].toDouble(),
      photos: List<String>.from(map['photos']),
      notes: map['notes'],
      hasNewDamage: map['hasNewDamage'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'type': type.name,
      'dateTime': dateTime.toIso8601String(),
      'kmAtInspection': kmAtInspection,
      'fuelLevel': fuelLevel,
      'photos': photos,
      'notes': notes,
      'hasNewDamage': hasNewDamage,
    };
  }
}
