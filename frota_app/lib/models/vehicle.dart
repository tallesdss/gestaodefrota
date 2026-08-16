enum VehicleStatus { available, rented, maintenance, inactive, sold }

enum ContractType { uber, prefecture }

enum RentalType { weekly, monthly }

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
      driverId: (map['driverId'] ?? map['motorista_id'] ?? '').toString(),
      driverName: (map['driverName'] ?? map['motorista_nome'] ?? '').toString(),
      startDate: DateTime.tryParse(map['startDate'] ?? map['data_inicio'] ?? '') ?? DateTime.now(),
      endDate: map['endDate'] != null || map['data_fim'] != null
          ? DateTime.tryParse((map['endDate'] ?? map['data_fim']).toString())
          : null,
      startKm: (map['startKm'] ?? map['km_inicial'] ?? 0) as int,
      endKm: map['endKm'] ?? map['km_final'],
      purpose: (map['purpose'] ?? map['motivo'] ?? '').toString(),
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

class RentalValueHistory {
  final double value;
  final DateTime date;

  RentalValueHistory({required this.value, required this.date});

  factory RentalValueHistory.fromMap(Map<String, dynamic> map) {
    return RentalValueHistory(
      value: (map['value'] ?? map['valor'] ?? 0.0).toDouble(),
      date: DateTime.tryParse(map['date'] ?? map['data'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'value': value, 'date': date.toIso8601String()};
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

  // Document Values
  final double? ipvaValue;
  final double? insuranceValue;
  final double? licensingValue;

  // Financing fields
  final int? financingInstallmentsPaid;
  final int? financingTotalInstallments;
  final double? financingInstallmentValue;
  final int? financingDueDay;

  // Identification & Insurance fields
  final String? renavam;
  final String? chassi;
  final String? insurancePolicyNumber;
  final String? insuranceCompany;
  final String? ipvaStatus;

  // Relational & Computed fields
  final String? currentDriverId;
  final String? currentDriverName;
  final DateTime? lastKmUpdateDate;
  final int? lastKmValue;
  final double? rentalValue;
  final List<VehicleUsage> usageHistory;
  final List<RentalValueHistory> rentalHistory;
  final RentalType? rentalType;
  final int? rentalDueDay;
  final double? purchaseValue;
  final double? fipeValue;
  final bool isEncumbered;
  final String? encumberedBank;

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
    this.ipvaValue,
    this.insuranceValue,
    this.licensingValue,
    this.financingInstallmentsPaid,
    this.financingTotalInstallments,
    this.financingInstallmentValue,
    this.financingDueDay,
    this.renavam,
    this.chassi,
    this.insurancePolicyNumber,
    this.insuranceCompany,
    this.ipvaStatus,
    this.rentalValue,
    this.currentDriverId,
    this.currentDriverName,
    this.lastKmUpdateDate,
    this.lastKmValue,
    this.usageHistory = const [],
    this.rentalHistory = const [],
    this.rentalType,
    this.rentalDueDay,
    this.purchaseValue,
    this.fipeValue,
    this.isEncumbered = false,
    this.encumberedBank,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    VehicleStatus parseStatus(dynamic val) {
      if (val == null) return VehicleStatus.available;
      final s = val.toString().toLowerCase();
      if (s == 'disponivel' || s == 'available') return VehicleStatus.available;
      if (s == 'alugado' || s == 'rented') return VehicleStatus.rented;
      if (s == 'manutencao' || s == 'maintenance') return VehicleStatus.maintenance;
      if (s == 'inativo' || s == 'inactive') return VehicleStatus.inactive;
      if (s == 'vendido' || s == 'sold') return VehicleStatus.sold;
      return VehicleStatus.available;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now().add(const Duration(days: 365));
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now().add(const Duration(days: 365));
    }

    int parseYear(dynamic val, dynamic anoFabricacao, dynamic anoModelo) {
      if (val != null) return int.tryParse(val.toString()) ?? 2024;
      if (anoFabricacao != null) return int.tryParse(anoFabricacao.toString()) ?? 2024;
      if (anoModelo != null) return int.tryParse(anoModelo.toString()) ?? 2024;
      return 2024;
    }

    return Vehicle(
      id: (map['id'] ?? '').toString(),
      plate: (map['placa'] ?? map['plate'] ?? '').toString(),
      brand: (map['marca'] ?? map['brand'] ?? '').toString(),
      model: (map['modelo'] ?? map['model'] ?? '').toString(),
      year: parseYear(map['ano'] ?? map['year'], map['ano_fabricacao'], map['ano_modelo']),
      color: (map['cor'] ?? map['color'] ?? 'Prata').toString(),
      status: parseStatus(map['status']),
      currentKm: (map['km_atual'] ?? map['currentKm'] ?? 0) is int
          ? (map['km_atual'] ?? map['currentKm'] ?? 0) as int
          : int.tryParse((map['km_atual'] ?? map['currentKm'] ?? '0').toString()) ?? 0,
      fuelLevel: (map['nivel_combustivel'] ?? map['fuelLevel'] ?? 1.0).toDouble(),
      contractType: map['contractType'] != null
          ? ContractType.values.firstWhere(
              (e) => e.name == map['contractType'],
              orElse: () => ContractType.uber,
            )
          : ContractType.uber,
      imageUrl: (map['crlv_url'] ?? map['imageUrl'] ?? '').toString(),
      ipvaExpiry: parseDate(map['vencimento_ipva'] ?? map['ipvaExpiry']),
      insuranceExpiry: parseDate(map['vencimento_seguro'] ?? map['insuranceExpiry']),
      licensingExpiry: parseDate(map['vencimento_licenciamento'] ?? map['licensingExpiry']),
      ipvaValue: (map['valor_ipva'] ?? map['ipvaValue']) != null
          ? double.tryParse((map['valor_ipva'] ?? map['ipvaValue']).toString())
          : null,
      insuranceValue: (map['valor_seguro'] ?? map['insuranceValue']) != null
          ? double.tryParse((map['valor_seguro'] ?? map['insuranceValue']).toString())
          : null,
      licensingValue: (map['valor_licenciamento'] ?? map['licensingValue']) != null
          ? double.tryParse((map['valor_licenciamento'] ?? map['licensingValue']).toString())
          : null,
      financingInstallmentsPaid: map['financiamento_parcelas_pagas'] ?? map['financingInstallmentsPaid'],
      financingTotalInstallments: map['financiamento_total_parcelas'] ?? map['financingTotalInstallments'],
      financingInstallmentValue: (map['financiamento_valor_parcela'] ?? map['financingInstallmentValue']) != null
          ? double.tryParse((map['financiamento_valor_parcela'] ?? map['financingInstallmentValue']).toString())
          : null,
      financingDueDay: map['financiamento_dia_vencimento'] ?? map['financingDueDay'],
      renavam: map['renavam']?.toString(),
      chassi: map['chassi']?.toString(),
      insurancePolicyNumber: (map['numero_apolice_seguro'] ?? map['insurancePolicyNumber'])?.toString(),
      insuranceCompany: (map['seguradora'] ?? map['insuranceCompany'])?.toString(),
      ipvaStatus: (map['status_ipva'] ?? map['ipvaStatus'])?.toString(),
      rentalValue: (map['valor_locacao'] ?? map['rentalValue']) != null
          ? double.tryParse((map['valor_locacao'] ?? map['rentalValue']).toString())
          : null,
      currentDriverId: (map['motorista_atual_id'] ?? map['motorista_id'] ?? map['currentDriverId'])?.toString(),
      currentDriverName: (map['motorista_atual_nome'] ?? map['motorista_nome'] ?? map['currentDriverName'])?.toString(),
      lastKmUpdateDate: map['lastKmUpdateDate'] != null || map['atualizado_em'] != null
          ? DateTime.tryParse((map['lastKmUpdateDate'] ?? map['atualizado_em']).toString())
          : null,
      lastKmValue: map['lastKmValue'],
      usageHistory: (map['usageHistory'] as List? ?? [])
          .map((e) => VehicleUsage.fromMap(e is Map<String, dynamic> ? e : {}))
          .toList(),
      rentalHistory: (map['rentalHistory'] as List? ?? [])
          .map((e) => RentalValueHistory.fromMap(e is Map<String, dynamic> ? e : {}))
          .toList(),
      rentalType: map['rentalType'] != null
          ? RentalType.values.firstWhere(
              (e) => e.name == map['rentalType'],
              orElse: () => RentalType.weekly,
            )
          : null,
      rentalDueDay: map['rentalDueDay'],
      purchaseValue: (map['purchaseValue'] ?? map['valor_compra']) != null
          ? double.tryParse((map['purchaseValue'] ?? map['valor_compra']).toString())
          : null,
      fipeValue: (map['fipeValue'] ?? map['valor_fipe']) != null
          ? double.tryParse((map['fipeValue'] ?? map['valor_fipe']).toString())
          : null,
      isEncumbered: map['isEncumbered'] ?? false,
      encumberedBank: map['encumberedBank']?.toString(),
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
      'ipvaValue': ipvaValue,
      'insuranceValue': insuranceValue,
      'licensingValue': licensingValue,
      'financingInstallmentsPaid': financingInstallmentsPaid,
      'financingTotalInstallments': financingTotalInstallments,
      'financingInstallmentValue': financingInstallmentValue,
      'financingDueDay': financingDueDay,
      'renavam': renavam,
      'chassi': chassi,
      'insurancePolicyNumber': insurancePolicyNumber,
      'insuranceCompany': insuranceCompany,
      'ipvaStatus': ipvaStatus,
      'rentalValue': rentalValue,
      'currentDriverId': currentDriverId,
      'currentDriverName': currentDriverName,
      'lastKmUpdateDate': lastKmUpdateDate?.toIso8601String(),
      'lastKmValue': lastKmValue,
      'usageHistory': usageHistory.map((e) => e.toMap()).toList(),
      'rentalHistory': rentalHistory.map((e) => e.toMap()).toList(),
      'rentalType': rentalType?.name,
      'rentalDueDay': rentalDueDay,
      'purchaseValue': purchaseValue,
      'fipeValue': fipeValue,
      'isEncumbered': isEncumbered,
      'encumberedBank': encumberedBank,
    };
  }

  /// Mapeamento para inserção/atualização direta na tabela `veiculos` do Supabase PostgreSQL
  Map<String, dynamic> toDatabaseMap() {
    String statusStr = 'disponivel';
    switch (status) {
      case VehicleStatus.available:
        statusStr = 'disponivel';
        break;
      case VehicleStatus.rented:
        statusStr = 'alugado';
        break;
      case VehicleStatus.maintenance:
        statusStr = 'manutencao';
        break;
      case VehicleStatus.inactive:
        statusStr = 'inativo';
        break;
      case VehicleStatus.sold:
        statusStr = 'vendido';
        break;
    }

    final data = <String, dynamic>{
      'placa': plate.toUpperCase().replaceAll('-', '').trim(),
      'marca': brand.trim(),
      'modelo': model.trim(),
      'ano_fabricacao': year,
      'ano_modelo': year,
      'cor': color.trim(),
      'status': statusStr,
      'km_atual': currentKm,
      'crlv_url': imageUrl.isNotEmpty ? imageUrl : null,
      'vencimento_ipva': ipvaExpiry.toIso8601String().split('T')[0],
      'vencimento_seguro': insuranceExpiry.toIso8601String().split('T')[0],
    };

    if (id.isNotEmpty && id.contains('-')) {
      data['id'] = id;
    }
    if (renavam != null && renavam!.isNotEmpty) data['renavam'] = renavam;
    if (chassi != null && chassi!.isNotEmpty) data['chassi'] = chassi;
    if (insurancePolicyNumber != null && insurancePolicyNumber!.isNotEmpty) {
      data['numero_apolice_seguro'] = insurancePolicyNumber;
    }
    if (insuranceCompany != null && insuranceCompany!.isNotEmpty) {
      data['seguradora'] = insuranceCompany;
    }
    if (ipvaValue != null) data['valor_ipva'] = ipvaValue;
    if (financingTotalInstallments != null) {
      data['financiamento_total_parcelas'] = financingTotalInstallments;
    }
    if (financingInstallmentsPaid != null) {
      data['financiamento_parcelas_pagas'] = financingInstallmentsPaid;
    }
    if (financingInstallmentValue != null) {
      data['financiamento_valor_parcela'] = financingInstallmentValue;
    }

    return data;
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
    double? ipvaValue,
    double? insuranceValue,
    double? licensingValue,
    int? financingInstallmentsPaid,
    int? financingTotalInstallments,
    double? financingInstallmentValue,
    int? financingDueDay,
    String? renavam,
    String? chassi,
    String? insurancePolicyNumber,
    String? insuranceCompany,
    String? ipvaStatus,
    double? rentalValue,
    String? currentDriverId,
    String? currentDriverName,
    DateTime? lastKmUpdateDate,
    int? lastKmValue,
    List<VehicleUsage>? usageHistory,
    List<RentalValueHistory>? rentalHistory,
    RentalType? rentalType,
    int? rentalDueDay,
    double? purchaseValue,
    double? fipeValue,
    bool? isEncumbered,
    String? encumberedBank,
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
      ipvaValue: ipvaValue ?? this.ipvaValue,
      insuranceValue: insuranceValue ?? this.insuranceValue,
      licensingValue: licensingValue ?? this.licensingValue,
      financingInstallmentsPaid:
          financingInstallmentsPaid ?? this.financingInstallmentsPaid,
      financingTotalInstallments:
          financingTotalInstallments ?? this.financingTotalInstallments,
      financingInstallmentValue:
          financingInstallmentValue ?? this.financingInstallmentValue,
      financingDueDay: financingDueDay ?? this.financingDueDay,
      renavam: renavam ?? this.renavam,
      chassi: chassi ?? this.chassi,
      insurancePolicyNumber: insurancePolicyNumber ?? this.insurancePolicyNumber,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      ipvaStatus: ipvaStatus ?? this.ipvaStatus,
      rentalValue: rentalValue ?? this.rentalValue,
      currentDriverId: currentDriverId ?? this.currentDriverId,
      currentDriverName: currentDriverName ?? this.currentDriverName,
      lastKmUpdateDate: lastKmUpdateDate ?? this.lastKmUpdateDate,
      lastKmValue: lastKmValue ?? this.lastKmValue,
      usageHistory: usageHistory ?? this.usageHistory,
      rentalHistory: rentalHistory ?? this.rentalHistory,
      rentalType: rentalType ?? this.rentalType,
      rentalDueDay: rentalDueDay ?? this.rentalDueDay,
      purchaseValue: purchaseValue ?? this.purchaseValue,
      fipeValue: fipeValue ?? this.fipeValue,
      isEncumbered: isEncumbered ?? this.isEncumbered,
      encumberedBank: encumberedBank ?? this.encumberedBank,
    );
  }
}
