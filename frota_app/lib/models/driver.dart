enum DriverType { uber, prefecture }

enum DriverStatus { active, inactive, pendingApproval, blocked }

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
  final String? state;
  final String? street;
  final String? zip;
  final int trustScore;
  final double outstandingBalance;
  final double totalGenerated;

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
    this.state,
    this.street,
    this.zip,
    this.trustScore = 100,
    this.outstandingBalance = 0.0,
    this.totalGenerated = 0.0,
  });

  factory Driver.fromMap(Map<String, dynamic> map) {
    DriverStatus parseStatus(dynamic val) {
      if (val == null) return DriverStatus.active;
      final str = val.toString().toLowerCase();
      if (str == 'ativo' || str == 'active') return DriverStatus.active;
      if (str == 'inativo' || str == 'inactive') return DriverStatus.inactive;
      if (str == 'pendente_aprovacao' || str == 'pending_approval' || str == 'pendingapproval') {
        return DriverStatus.pendingApproval;
      }
      if (str == 'bloqueado' || str == 'blocked') return DriverStatus.blocked;
      return DriverStatus.active;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now().add(const Duration(days: 365));
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ??
          DateTime.now().add(const Duration(days: 365));
    }

    return Driver(
      id: (map['id'] ?? '').toString(),
      name: map['nome'] ?? map['name'] ?? '',
      cpf: map['cpf'] ?? '',
      phone: map['telefone'] ?? map['phone'] ?? '',
      email: map['email'] ?? '',
      type: map['type'] != null
          ? DriverType.values.firstWhere(
              (e) => e.name == map['type'],
              orElse: () => DriverType.uber,
            )
          : DriverType.uber,
      status: parseStatus(map['status']),
      cnhNumber: map['numero_cnh'] ?? map['cnhNumber'] ?? '',
      cnhExpiry: parseDate(map['validade_cnh'] ?? map['cnhExpiry']),
      cnhCategory: map['categoria_cnh'] ?? map['cnhCategory'] ?? 'B',
      currentVehicleId: map['veiculo_atual_id'] ?? map['currentVehicleId'],
      avatarUrl: map['foto_url'] ?? map['avatarUrl'] ?? '',
      isApproved: map['isApproved'] ??
          (map['status'] == 'ativo' || map['status'] == 'active'),
      city: map['endereco_cidade'] ?? map['city'],
      state: map['endereco_estado'] ?? map['state'],
      street: map['endereco_rua'] ?? map['street'],
      zip: map['endereco_cep'] ?? map['zip'],
      trustScore: (map['pontuacao_confianca'] ?? map['trustScore'] ?? 100) as int,
      outstandingBalance: (map['saldo_devedor'] ?? map['outstandingBalance'] ?? 0.0).toDouble(),
      totalGenerated: (map['valor_total_gerado'] ?? map['totalGenerated'] ?? 0.0).toDouble(),
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
      'state': state,
      'street': street,
      'zip': zip,
      'trustScore': trustScore,
      'outstandingBalance': outstandingBalance,
      'totalGenerated': totalGenerated,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'cpf': cpf,
      'numero_cnh': cnhNumber,
      'categoria_cnh': cnhCategory,
      'validade_cnh': cnhExpiry.toIso8601String().split('T')[0],
      'endereco_rua': street,
      'endereco_cidade': city,
      'endereco_estado': state,
      'endereco_cep': zip,
      'status': status == DriverStatus.active
          ? 'ativo'
          : (status == DriverStatus.blocked
              ? 'bloqueado'
              : (status == DriverStatus.pendingApproval
                  ? 'pendente_aprovacao'
                  : 'inativo')),
      'pontuacao_confianca': trustScore,
      'saldo_devedor': outstandingBalance,
      'valor_total_gerado': totalGenerated,
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
    String? state,
    String? street,
    String? zip,
    int? trustScore,
    double? outstandingBalance,
    double? totalGenerated,
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
      state: state ?? this.state,
      street: street ?? this.street,
      zip: zip ?? this.zip,
      trustScore: trustScore ?? this.trustScore,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      totalGenerated: totalGenerated ?? this.totalGenerated,
    );
  }
}
