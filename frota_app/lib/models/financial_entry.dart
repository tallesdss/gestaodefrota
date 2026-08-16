enum FinancialType { income, expense }

class FinancialEntry {
  final String id;
  final FinancialType type;
  final String category; // aluguel / manutenção / ipva / seguro / multa / outro
  final String? categoryId;
  final String? contractId;
  final String? vehicleId;
  final String? driverId;
  final String? createdBy;
  final double amount;
  final DateTime date;
  final DateTime? paymentDate;
  final String description;
  final bool isPaid;
  final bool isLate;
  final String? pixCode;
  final String? pixQrCodeUrl;
  final String? paymentMethod;
  final String? receiptUrl;

  FinancialEntry({
    required this.id,
    required this.type,
    required this.category,
    this.categoryId,
    this.contractId,
    this.vehicleId,
    this.driverId,
    this.createdBy,
    required this.amount,
    required this.date,
    this.paymentDate,
    required this.description,
    required this.isPaid,
    this.isLate = false,
    this.pixCode,
    this.pixQrCodeUrl,
    this.paymentMethod,
    this.receiptUrl,
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
      id: (map['id'] ?? map['lancamento_id'] ?? '').toString(),
      type: parseType(map['tipo'] ?? map['type']),
      category: (map['categoria_nome'] ?? map['category'] ?? 'Geral').toString(),
      categoryId: (map['categoria_id'] ?? map['categoryId'])?.toString(),
      contractId: (map['contrato_id'] ?? map['contractId'])?.toString(),
      vehicleId: (map['veiculo_id'] ?? map['vehicleId'])?.toString(),
      driverId: (map['motorista_id'] ?? map['driverId'])?.toString(),
      createdBy: (map['criado_por'] ?? map['createdBy'])?.toString(),
      amount: (map['valor'] ?? map['amount'] ?? 0.0).toDouble(),
      date: DateTime.tryParse((map['data_vencimento'] ?? map['date'] ?? '').toString()) ?? DateTime.now(),
      paymentDate: map['data_pagamento'] != null ? DateTime.tryParse(map['data_pagamento'].toString()) : null,
      description: (map['titulo'] ?? map['description'] ?? '').toString(),
      isPaid: parseIsPaid(map['isPaid'], map['status']),
      isLate: parseIsLate(map['isLate'], map['status']),
      pixCode: (map['pix_copia_cola'] ?? map['pixCode'])?.toString(),
      pixQrCodeUrl: (map['pix_qr_code_url'] ?? map['pixQrCodeUrl'])?.toString(),
      paymentMethod: (map['metodo_pagamento'] ?? map['paymentMethod'] ?? 'pix').toString(),
      receiptUrl: (map['comprovante_url'] ?? map['receiptUrl'])?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'category': category,
      'categoryId': categoryId,
      'contractId': contractId,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'createdBy': createdBy,
      'amount': amount,
      'date': date.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'description': description,
      'isPaid': isPaid,
      'isLate': isLate,
      'pixCode': pixCode,
      'pixQrCodeUrl': pixQrCodeUrl,
      'paymentMethod': paymentMethod,
      'receiptUrl': receiptUrl,
    };
  }

  /// Mapeamento para inserção na tabela `lancamentos_financeiros` do Supabase
  Map<String, dynamic> toDatabaseMap({String? defaultCategoryId}) {
    String statusStr = 'pendente';
    if (isPaid) {
      statusStr = 'pago';
    } else if (isLate) {
      statusStr = 'atrasado';
    }

    final data = <String, dynamic>{
      'categoria_id': categoryId ?? defaultCategoryId ?? '10000000-0000-0000-0000-000000000001',
      'tipo': type == FinancialType.income ? 'receita' : 'despesa',
      'titulo': description.trim(),
      'valor': amount > 0 ? amount : 0.01,
      'data_vencimento': date.toIso8601String().split('T')[0],
      'status': statusStr,
      'metodo_pagamento': paymentMethod ?? 'pix',
    };

    if (id.isNotEmpty && id.contains('-')) {
      data['id'] = id;
    }
    if (vehicleId != null && vehicleId!.isNotEmpty) data['veiculo_id'] = vehicleId;
    if (driverId != null && driverId!.isNotEmpty) data['motorista_id'] = driverId;
    if (contractId != null && contractId!.isNotEmpty) data['contrato_id'] = contractId;
    if (createdBy != null && createdBy!.isNotEmpty) data['criado_por'] = createdBy;
    if (isPaid) {
      data['data_pagamento'] = (paymentDate ?? DateTime.now()).toIso8601String().split('T')[0];
    }
    if (pixCode != null && pixCode!.isNotEmpty) data['pix_copia_cola'] = pixCode;
    if (pixQrCodeUrl != null && pixQrCodeUrl!.isNotEmpty) data['pix_qr_code_url'] = pixQrCodeUrl;
    if (receiptUrl != null && receiptUrl!.isNotEmpty) data['comprovante_url'] = receiptUrl;

    return data;
  }

  FinancialEntry copyWith({
    String? id,
    FinancialType? type,
    String? category,
    String? categoryId,
    String? contractId,
    String? vehicleId,
    String? driverId,
    String? createdBy,
    double? amount,
    DateTime? date,
    DateTime? paymentDate,
    String? description,
    bool? isPaid,
    bool? isLate,
    String? pixCode,
    String? pixQrCodeUrl,
    String? paymentMethod,
    String? receiptUrl,
  }) {
    return FinancialEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      contractId: contractId ?? this.contractId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      createdBy: createdBy ?? this.createdBy,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentDate: paymentDate ?? this.paymentDate,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      isLate: isLate ?? this.isLate,
      pixCode: pixCode ?? this.pixCode,
      pixQrCodeUrl: pixQrCodeUrl ?? this.pixQrCodeUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
}
