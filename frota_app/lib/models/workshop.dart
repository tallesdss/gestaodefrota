class Workshop {
  final String id;
  final String name;
  final String cnpj;
  final String phone;
  final String email;
  final String address;
  final bool isAccredited;
  final double rating;
  final double totalSpent;
  final double pendingPayment;
  final List<String> specializedServices;
  final String? bankInfo;

  Workshop({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.phone,
    required this.email,
    required this.address,
    required this.isAccredited,
    this.rating = 5.0,
    this.totalSpent = 0.0,
    this.pendingPayment = 0.0,
    this.specializedServices = const [],
    this.bankInfo,
  });

  // Helper for balance
  double get balance => totalSpent - pendingPayment;

  factory Workshop.fromMap(Map<String, dynamic> map) {
    return Workshop(
      id: map['id'],
      name: map['name'],
      cnpj: map['cnpj'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      isAccredited: map['isAccredited'],
      rating: map['rating']?.toDouble() ?? 5.0,
      totalSpent: map['totalSpent']?.toDouble() ?? 0.0,
      pendingPayment: map['pendingPayment']?.toDouble() ?? 0.0,
      specializedServices: List<String>.from(map['specializedServices'] ?? []),
      bankInfo: map['bankInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cnpj': cnpj,
      'phone': phone,
      'email': email,
      'address': address,
      'isAccredited': isAccredited,
      'rating': rating,
      'totalSpent': totalSpent,
      'pendingPayment': pendingPayment,
      'specializedServices': specializedServices,
      'bankInfo': bankInfo,
    };
  }
}

class WorkshopParts {
  final String id;
  final String workshopId;
  final String name;
  final double price;
  final DateTime date;
  final String vehiclePlate;

  WorkshopParts({
    required this.id,
    required this.workshopId,
    required this.name,
    required this.price,
    required this.date,
    required this.vehiclePlate,
  });
}

class WorkshopDocument {
  final String id;
  final String workshopId;
  final String title;
  final String type; // 'NFe' or 'Recibo'
  final DateTime date;
  final double value;
  final String status; // 'Paid', 'Pending'
  final String? imageUrl;

  WorkshopDocument({
    required this.id,
    required this.workshopId,
    required this.title,
    required this.type,
    required this.date,
    required this.value,
    this.status = 'Paid',
    this.imageUrl,
  });
}
