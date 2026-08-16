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
  final String? pixCode;
  final String? paymentMethod;

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
    this.pixCode,
    this.paymentMethod,
  });

  factory FinancialEntry.fromMap(Map<String, dynamic> map) {
    FinancialType parseType(dynamic val) {
      if (val == null) return FinancialType.expense;
      final s = val.toString().toLowerCase();
      if (s == 'receita' || s == 'income') return FinancialType.income;
      return FinancialType.expense;
    }

    bool parseIsPaid(dynamic val, dynamic statusVal) {
      if (val is bool) return val;
      if (statusVal != null) {
        return statusVal.toString().toLowerCase() == 'pago' ||
            statusVal.toString().toLowerCase() == 'paid';
      }
      return false;
    }

    bool parseIsLate(dynamic val, dynamic statusVal) {
      if (val is bool) return val;
      if (statusVal != null) {
        return statusVal.toString().toLowerCase() == 'atrasado' ||
            statusVal.toString().toLowerCase() == 'overdue';
      }
      return false;
    }

    return FinancialEntry(
      id: (map['id'] ?? '').toString(),
      type: parseType(map['tipo'] ?? map['type']),
      category: map['categoria_nome'] ?? map['category'] ?? 'Geral',
      vehicleId: map['veiculo_id'] ?? map['vehicleId'],
      driverId: map['motorista_id'] ?? map['driverId'],
      amount: (map['valor'] ?? map['amount'] ?? 0.0).toDouble(),
      date: DateTime.tryParse(map['data_vencimento'] ?? map['date'] ?? '') ?? DateTime.now(),
      description: map['titulo'] ?? map['description'] ?? '',
      isPaid: parseIsPaid(map['isPaid'], map['status']),
      isLate: parseIsLate(map['isLate'], map['status']),
      pixCode: map['pix_copia_cola'] ?? map['pixCode'],
      paymentMethod: map['metodo_pagamento'] ?? map['paymentMethod'],
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
      'pixCode': pixCode,
      'paymentMethod': paymentMethod,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'tipo': type == FinancialType.income ? 'receita' : 'despesa',
      'veiculo_id': vehicleId,
      'motorista_id': driverId,
      'valor': amount,
      'data_vencimento': date.toIso8601String().split('T')[0],
      'titulo': description,
      'status': isPaid ? 'pago' : (isLate ? 'atrasado' : 'pendente'),
      'pix_copia_cola': pixCode,
      'metodo_pagamento': paymentMethod ?? 'pix',
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
    String? pixCode,
    String? paymentMethod,
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
      pixCode: pixCode ?? this.pixCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
