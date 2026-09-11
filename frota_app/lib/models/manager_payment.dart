class ManagerPayment {
  final String id;
  final String managerId;
  final double baseSalary;
  final double commission;
  final String referenceMonth; // YYYY-MM
  final String status; // 'pendente' or 'pago'
  final DateTime? createdAt;
  
  // Virtual field
  final String? managerName;

  ManagerPayment({
    required this.id,
    required this.managerId,
    required this.baseSalary,
    required this.commission,
    required this.referenceMonth,
    required this.status,
    this.createdAt,
    this.managerName,
  });

  double get totalAmount => baseSalary + commission;

  factory ManagerPayment.fromMap(Map<String, dynamic> map) {
    // Handling nested relations (e.g. from Supabase join)
    String? mName;
    if (map['gestores'] != null && map['gestores']['perfis'] != null) {
      mName = map['gestores']['perfis']['nome'];
    }

    return ManagerPayment(
      id: map['id'] ?? '',
      managerId: map['gestor_id'] ?? '',
      baseSalary: (map['valor_salario'] ?? 0.0).toDouble(),
      commission: (map['valor_comissao'] ?? 0.0).toDouble(),
      referenceMonth: map['mes_referencia'] ?? '',
      status: map['status'] ?? 'pendente',
      createdAt: map['criado_em'] != null ? DateTime.tryParse(map['criado_em']) : null,
      managerName: mName,
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'gestor_id': managerId,
      'valor_salario': baseSalary,
      'valor_comissao': commission,
      'mes_referencia': referenceMonth,
      'status': status,
    };
  }

  ManagerPayment copyWith({
    String? id,
    String? managerId,
    double? baseSalary,
    double? commission,
    String? referenceMonth,
    String? status,
    DateTime? createdAt,
    String? managerName,
  }) {
    return ManagerPayment(
      id: id ?? this.id,
      managerId: managerId ?? this.managerId,
      baseSalary: baseSalary ?? this.baseSalary,
      commission: commission ?? this.commission,
      referenceMonth: referenceMonth ?? this.referenceMonth,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      managerName: managerName ?? this.managerName,
    );
  }
}
