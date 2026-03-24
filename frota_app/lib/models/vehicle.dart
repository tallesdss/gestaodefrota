enum VehicleStatus { 
  available, 
  rented, 
  maintenance 
}

enum ContractType { 
  uber, 
  prefecture 
}

class Vehicle {
  final String id;
  final String plate;
  final String brand;
  final String model;
  final int year;
  final String color;
  final VehicleStatus status;
  final int currentKm;
  final double fuelLevel;
  final ContractType contractType;
  final String imageUrl;
  final DateTime ipvaExpiry;
  final DateTime insuranceExpiry;
  final DateTime licensingExpiry;

  Vehicle({
    required this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.status,
    required this.currentKm,
    required this.fuelLevel,
    required this.contractType,
    required this.imageUrl,
    required this.ipvaExpiry,
    required this.insuranceExpiry,
    required this.licensingExpiry,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      plate: map['plate'],
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      color: map['color'],
      status: VehicleStatus.values.firstWhere((e) => e.name == map['status']),
      currentKm: map['currentKm'],
      fuelLevel: map['fuelLevel'].toDouble(),
      contractType: ContractType.values.firstWhere((e) => e.name == map['contractType']),
      imageUrl: map['imageUrl'],
      ipvaExpiry: DateTime.parse(map['ipvaExpiry']),
      insuranceExpiry: DateTime.parse(map['insuranceExpiry']),
      licensingExpiry: DateTime.parse(map['licensingExpiry']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plate': plate,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'status': status.name,
      'currentKm': currentKm,
      'fuelLevel': fuelLevel,
      'contractType': contractType.name,
      'imageUrl': imageUrl,
      'ipvaExpiry': ipvaExpiry.toIso8601String(),
      'insuranceExpiry': insuranceExpiry.toIso8601String(),
      'licensingExpiry': licensingExpiry.toIso8601String(),
    };
  }
}
