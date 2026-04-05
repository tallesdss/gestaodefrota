enum FinancialType { income, expense }

class FinancialEntry {
  final String id;
  final FinancialType type;
  final String category; // aluguel / manutenção / ipva / seguro / multa / outro
  final String? vehicleId;
  final String? driverId;
  final double amount;
  final DateTime date;
  final String description;
  final bool isPaid;
  final bool isLate;

  FinancialEntry({
    required this.id,
    required this.type,
    required this.category,
    this.vehicleId,
    this.driverId,
    required this.amount,
    required this.date,
    required this.description,
    required this.isPaid,
    this.isLate = false,
  });

  factory FinancialEntry.fromMap(Map<String, dynamic> map) {
    return FinancialEntry(
      id: map['id'],
      type: FinancialType.values.firstWhere((e) => e.name == map['type']),
      category: map['category'],
      vehicleId: map['vehicleId'],
      driverId: map['driverId'],
      amount: map['amount'].toDouble(),
      date: DateTime.parse(map['date']),
      description: map['description'],
      isPaid: map['isPaid'] as bool,
      isLate: map['isLate'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'category': category,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'isPaid': isPaid,
      'isLate': isLate,
    };
  }

  FinancialEntry copyWith({
    String? id,
    FinancialType? type,
    String? category,
    String? vehicleId,
    String? driverId,
    double? amount,
    DateTime? date,
    String? description,
    bool? isPaid,
    bool? isLate,
  }) {
    return FinancialEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      isLate: isLate ?? this.isLate,
    );
  }
}
