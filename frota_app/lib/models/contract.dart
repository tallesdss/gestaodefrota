enum ContractStatus { active, expired, cancelled, concluded, defaultStatus }

class Contract {
  final String id;
  final String? contractNumber;
  final String vehicleId;
  final String driverId;
  final String type; // uber / prefecture
  final DateTime startDate;
  final DateTime endDate;
  final double weeklyValue;
  final double monthlyValue;
  final ContractStatus status;
  final bool depositPaid;
  final double depositAmount;
  final String? billingFrequency;

  Contract({
    required this.id,
    this.contractNumber,
    required this.vehicleId,
    required this.driverId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.weeklyValue,
    required this.monthlyValue,
    required this.status,
    required this.depositPaid,
    this.depositAmount = 0.0,
    this.billingFrequency,
  });

  factory Contract.fromMap(Map<String, dynamic> map) {
    ContractStatus parseStatus(dynamic val) {
      if (val == null) return ContractStatus.active;
      final s = val.toString().toLowerCase();
      if (s == 'ativo' || s == 'active') return ContractStatus.active;
      if (s == 'concluido' || s == 'expired' || s == 'concluded') return ContractStatus.concluded;
      if (s == 'cancelado' || s == 'cancelled') return ContractStatus.cancelled;
      return ContractStatus.active;
    }

    final rentalVal = (map['valor_locacao'] ?? map['monthlyValue'] ?? map['weeklyValue'] ?? 0.0).toDouble();

    return Contract(
      id: (map['id'] ?? '').toString(),
      contractNumber: map['numero_contrato'] ?? map['contractNumber'],
      vehicleId: map['veiculo_id'] ?? map['vehicleId'] ?? '',
      driverId: map['motorista_id'] ?? map['driverId'] ?? '',
      type: map['type'] ?? 'uber',
      startDate: DateTime.tryParse(map['data_inicio'] ?? map['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['data_fim'] ?? map['endDate'] ?? '') ?? DateTime.now().add(const Duration(days: 365)),
      weeklyValue: map['weeklyValue'] != null ? (map['weeklyValue'] as num).toDouble() : rentalVal / 4,
      monthlyValue: map['monthlyValue'] != null ? (map['monthlyValue'] as num).toDouble() : rentalVal,
      status: parseStatus(map['status']),
      depositPaid: (map['depositPaid'] ?? ((map['valor_caucao'] ?? 0.0) > 0)) as bool,
      depositAmount: (map['valor_caucao'] ?? map['depositAmount'] ?? 0.0).toDouble(),
      billingFrequency: map['frequencia_cobranca'] ?? map['billingFrequency'] ?? 'mensal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contractNumber': contractNumber,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'weeklyValue': weeklyValue,
      'monthlyValue': monthlyValue,
      'status': status.name,
      'depositPaid': depositPaid,
      'depositAmount': depositAmount,
      'billingFrequency': billingFrequency,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'numero_contrato': contractNumber,
      'motorista_id': driverId,
      'veiculo_id': vehicleId,
      'data_inicio': startDate.toIso8601String().split('T')[0],
      'data_fim': endDate.toIso8601String().split('T')[0],
      'valor_locacao': monthlyValue,
      'valor_caucao': depositAmount,
      'frequencia_cobranca': billingFrequency ?? 'mensal',
      'status': status == ContractStatus.active
          ? 'ativo'
          : (status == ContractStatus.cancelled ? 'cancelado' : 'concluido'),
    };
  }
}
