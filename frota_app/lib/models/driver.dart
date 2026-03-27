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
  final String? city;

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
    this.city,
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
      city: map['city'],
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
      'city': city,
    };
  }

  Driver copyWith({
    String? id,
    String? name,
    String? cpf,
    String? phone,
    String? email,
    DriverType? type,
    DriverStatus? status,
    String? cnhNumber,
    DateTime? cnhExpiry,
    String? cnhCategory,
    String? currentVehicleId,
    String? avatarUrl,
    bool? isApproved,
    String? city,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      type: type ?? this.type,
      status: status ?? this.status,
      cnhNumber: cnhNumber ?? this.cnhNumber,
      cnhExpiry: cnhExpiry ?? this.cnhExpiry,
      cnhCategory: cnhCategory ?? this.cnhCategory,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isApproved: isApproved ?? this.isApproved,
      city: city ?? this.city,
    );
  }
}
