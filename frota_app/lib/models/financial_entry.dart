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
  final bool isCancelled;
  final double? originalAmount;
  final double discountPercentage;
  final String? discountReason;
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
    this.isCancelled = false,
    this.originalAmount,
    this.discountPercentage = 0,
    this.discountReason,
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

    final dueDate =
        DateTime.tryParse(
          (map['data_vencimento'] ?? map['date'] ?? '').toString(),
        ) ??
        DateTime.now();
    final isPaidValue = parseIsPaid(map['isPaid'], map['status']);
    final isCancelledValue =
        map['isCancelled'] == true ||
        const {
          'cancelado',
          'cancelled',
        }.contains(map['status']?.toString().toLowerCase());

    bool computeIsLate(
      dynamic val,
      dynamic statusVal,
      DateTime due,
      bool paid,
    ) {
      if (paid) return false;
      if (val == true) return true;
      if (statusVal != null) {
        final s = statusVal.toString().toLowerCase();
        if (s == 'atrasado' || s == 'overdue') return true;
      }
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final dueOnly = DateTime(due.year, due.month, due.day);
      return dueOnly.isBefore(today);
    }

    return FinancialEntry(
      id: (map['id'] ?? map['lancamento_id'] ?? '').toString(),
      type: parseType(map['tipo'] ?? map['type']),
      category: (map['categoria_nome'] ?? map['category'] ?? 'Geral')
          .toString(),
      categoryId: (map['categoria_id'] ?? map['categoryId'])?.toString(),
      contractId: (map['contrato_id'] ?? map['contractId'])?.toString(),
      vehicleId: (map['veiculo_id'] ?? map['vehicleId'])?.toString(),
      driverId: (map['motorista_id'] ?? map['driverId'])?.toString(),
      createdBy: (map['criado_por'] ?? map['createdBy'])?.toString(),
      amount: (map['valor'] ?? map['amount'] ?? 0.0).toDouble(),
      date: dueDate,
      paymentDate: map['data_pagamento'] != null
          ? DateTime.tryParse(map['data_pagamento'].toString())
          : null,
      description: (map['titulo'] ?? map['description'] ?? '').toString(),
      isPaid: isPaidValue,
      isLate: isCancelledValue
          ? false
          : computeIsLate(map['isLate'], map['status'], dueDate, isPaidValue),
      isCancelled: isCancelledValue,
      originalAmount: map['valor_original'] == null
          ? null
          : double.tryParse(map['valor_original'].toString()),
      discountPercentage:
          double.tryParse((map['desconto_percentual'] ?? 0).toString()) ?? 0,
      discountReason: map['motivo_desconto']?.toString(),
      pixCode: (map['pix_copia_cola'] ?? map['pixCode'])?.toString(),
      pixQrCodeUrl: (map['pix_qr_code_url'] ?? map['pixQrCodeUrl'])?.toString(),
      paymentMethod: (map['metodo_pagamento'] ?? map['paymentMethod'] ?? 'pix')
          .toString(),
      receiptUrl: (map['comprovante_url'] ?? map['receiptUrl'])?.toString(),
    );
  }

  /// Indica se o comprovante foi enviado e está aguardando baixa/confirmação
  bool get isUnderReview =>
      isOutstanding && receiptUrl != null && receiptUrl!.isNotEmpty;
  bool get isOutstanding => !isPaid && !isCancelled;

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
      'isCancelled': isCancelled,
      'originalAmount': originalAmount,
      'discountPercentage': discountPercentage,
      'discountReason': discountReason,
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
    } else if (isCancelled) {
      statusStr = 'cancelado';
    } else if (isLate) {
      statusStr = 'atrasado';
    }

    final data = <String, dynamic>{
      'categoria_id':
          categoryId ??
          defaultCategoryId ??
          '10000000-0000-0000-0000-000000000001',
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
    if (vehicleId != null && vehicleId!.isNotEmpty)
      data['veiculo_id'] = vehicleId;
    if (driverId != null && driverId!.isNotEmpty)
      data['motorista_id'] = driverId;
    if (contractId != null && contractId!.isNotEmpty)
      data['contrato_id'] = contractId;
    if (createdBy != null && createdBy!.isNotEmpty)
      data['criado_por'] = createdBy;
    if (isPaid) {
      data['data_pagamento'] = (paymentDate ?? DateTime.now())
          .toIso8601String()
          .split('T')[0];
    }
    if (pixCode != null && pixCode!.isNotEmpty)
      data['pix_copia_cola'] = pixCode;
    if (pixQrCodeUrl != null && pixQrCodeUrl!.isNotEmpty)
      data['pix_qr_code_url'] = pixQrCodeUrl;
    if (receiptUrl != null && receiptUrl!.isNotEmpty)
      data['comprovante_url'] = receiptUrl;
    if (originalAmount != null) data['valor_original'] = originalAmount;
    if (discountPercentage > 0) {
      data['desconto_percentual'] = discountPercentage;
      data['motivo_desconto'] = discountReason;
    }

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
    bool clearPaymentDate = false,
    String? description,
    bool? isPaid,
    bool? isLate,
    bool? isCancelled,
    double? originalAmount,
    double? discountPercentage,
    String? discountReason,
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
      paymentDate: clearPaymentDate ? null : (paymentDate ?? this.paymentDate),
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      isLate: isLate ?? this.isLate,
      isCancelled: isCancelled ?? this.isCancelled,
      originalAmount: originalAmount ?? this.originalAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountReason: discountReason ?? this.discountReason,
      pixCode: pixCode ?? this.pixCode,
      pixQrCodeUrl: pixQrCodeUrl ?? this.pixQrCodeUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
}
