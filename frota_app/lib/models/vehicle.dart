enum VehicleStatus { 
  available, 
  rented, 
  maintenance 
}

enum ContractType { 
  uber, 
  prefecture 
}

class VehicleUsage {
  final String driverId;
  final String driverName;
  final DateTime startDate;
  final DateTime? endDate;
  final int startKm;
  final int? endKm;
  final String purpose;

  VehicleUsage({
    required this.driverId,
    required this.driverName,
    required this.startDate,
    this.endDate,
    required this.startKm,
    this.endKm,
    required this.purpose,
  });

  factory VehicleUsage.fromMap(Map<String, dynamic> map) {
    return VehicleUsage(
      driverId: map['driverId'],
      driverName: map['driverName'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      startKm: map['startKm'],
      endKm: map['endKm'],
      purpose: map['purpose'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'startKm': startKm,
      'endKm': endKm,
      'purpose': purpose,
    };
  }
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
  
  // New fields
  final String? currentDriverId;
  final String? currentDriverName;
  final DateTime? lastKmUpdateDate;
  final int? lastKmValue;
  final double? rentalValue;
  final List<VehicleUsage> usageHistory;

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
    this.rentalValue,
    this.currentDriverId,
    this.currentDriverName,
    this.lastKmUpdateDate,
    this.lastKmValue,
    this.usageHistory = const [],
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
      rentalValue: map['rentalValue']?.toDouble(),
      currentDriverId: map['currentDriverId'],
      currentDriverName: map['currentDriverName'],
      lastKmUpdateDate: map['lastKmUpdateDate'] != null ? DateTime.parse(map['lastKmUpdateDate']) : null,
      lastKmValue: map['lastKmValue'],
      usageHistory: (map['usageHistory'] as List? ?? []).map((e) => VehicleUsage.fromMap(e)).toList(),
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
      'rentalValue': rentalValue,
      'currentDriverId': currentDriverId,
      'currentDriverName': currentDriverName,
      'lastKmUpdateDate': lastKmUpdateDate?.toIso8601String(),
      'lastKmValue': lastKmValue,
      'usageHistory': usageHistory.map((e) => e.toMap()).toList(),
    };
  }
  Vehicle copyWith({
    String? id,
    String? plate,
    String? brand,
    String? model,
    int? year,
    String? color,
    VehicleStatus? status,
    int? currentKm,
    double? fuelLevel,
    ContractType? contractType,
    String? imageUrl,
    DateTime? ipvaExpiry,
    DateTime? insuranceExpiry,
    DateTime? licensingExpiry,
    String? currentDriverId,
    String? currentDriverName,
    DateTime? lastKmUpdateDate,
    int? lastKmValue,
    double? rentalValue,
    List<VehicleUsage>? usageHistory,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      status: status ?? this.status,
      currentKm: currentKm ?? this.currentKm,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      contractType: contractType ?? this.contractType,
      imageUrl: imageUrl ?? this.imageUrl,
      ipvaExpiry: ipvaExpiry ?? this.ipvaExpiry,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      licensingExpiry: licensingExpiry ?? this.licensingExpiry,
      currentDriverId: currentDriverId ?? this.currentDriverId,
      currentDriverName: currentDriverName ?? this.currentDriverName,
      lastKmUpdateDate: lastKmUpdateDate ?? this.lastKmUpdateDate,
      lastKmValue: lastKmValue ?? this.lastKmValue,
      rentalValue: rentalValue ?? this.rentalValue,
      usageHistory: usageHistory ?? this.usageHistory,
    );
  }
}
