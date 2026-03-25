enum DriverType { 
  uber, 
  prefecture 
}

enum DriverStatus { 
  active, 
  inactive 
}

class Driver {
  final String id;
  final String name;
  final String cpf;
  final String phone;
  final String email;
  final DriverType type;
  final DriverStatus status;
  final String cnhNumber;
  final DateTime cnhExpiry;
  final String cnhCategory;
  final String? currentVehicleId;
  final String avatarUrl;
  final bool isApproved;

  Driver({
    required this.id,
    required this.name,
    required this.cpf,
    required this.phone,
    required this.email,
    required this.type,
    required this.status,
    required this.cnhNumber,
    required this.cnhExpiry,
    required this.cnhCategory,
    this.currentVehicleId,
    required this.avatarUrl,
    this.isApproved = true,
  });

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'],
      name: map['name'],
      cpf: map['cpf'],
      phone: map['phone'],
      email: map['email'],
      type: DriverType.values.firstWhere((e) => e.name == map['type']),
      status: DriverStatus.values.firstWhere((e) => e.name == map['status']),
      cnhNumber: map['cnhNumber'],
      cnhExpiry: DateTime.parse(map['cnhExpiry']),
      cnhCategory: map['cnhCategory'],
      currentVehicleId: map['currentVehicleId'],
      avatarUrl: map['avatarUrl'],
      isApproved: map['isApproved'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'phone': phone,
      'email': email,
      'type': type.name,
      'status': status.name,
      'cnhNumber': cnhNumber,
      'cnhExpiry': cnhExpiry.toIso8601String(),
      'cnhCategory': cnhCategory,
      'currentVehicleId': currentVehicleId,
      'avatarUrl': avatarUrl,
      'isApproved': isApproved,
    };
  }
}
