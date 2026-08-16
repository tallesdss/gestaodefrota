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
  final String? cnhFrontUrl;
  final String? cnhBackUrl;
  final String? residenceProofUrl;
  final String? currentVehicleId;
  final String avatarUrl;
  final bool isApproved;
  final String? street;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? state;
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
    this.cnhFrontUrl,
    this.cnhBackUrl,
    this.residenceProofUrl,
    this.currentVehicleId,
    required this.avatarUrl,
    this.isApproved = true,
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
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

    // Suporte a JOINs entre public.motoristas e public.perfis
    final perfil = map['perfis'] is Map<String, dynamic> ? map['perfis'] as Map<String, dynamic> : null;

    final nomeFinal = (perfil?['nome'] ?? map['nome'] ?? map['name'] ?? '').toString();
    final emailFinal = (perfil?['email'] ?? map['email'] ?? '').toString();
    final telefoneFinal = (perfil?['telefone'] ?? map['telefone'] ?? map['phone'] ?? '').toString();
    final fotoFinal = (perfil?['foto_url'] ?? map['foto_url'] ?? map['avatarUrl'] ?? '').toString();

    final statusFinal = parseStatus(map['status']);

    return Driver(
      id: (map['id'] ?? '').toString(),
      name: nomeFinal,
      cpf: (map['cpf'] ?? '').toString(),
      phone: telefoneFinal,
      email: emailFinal,
      type: map['type'] != null
          ? DriverType.values.firstWhere(
              (e) => e.name == map['type'],
              orElse: () => DriverType.uber,
            )
          : DriverType.uber,
      status: statusFinal,
      cnhNumber: (map['numero_cnh'] ?? map['cnhNumber'] ?? '').toString(),
      cnhExpiry: parseDate(map['validade_cnh'] ?? map['cnhExpiry']),
      cnhCategory: (map['categoria_cnh'] ?? map['cnhCategory'] ?? 'B').toString(),
      cnhFrontUrl: (map['cnh_frente_url'] ?? map['cnhFrontUrl'])?.toString(),
      cnhBackUrl: (map['cnh_verso_url'] ?? map['cnhBackUrl'])?.toString(),
      residenceProofUrl: (map['comprovante_residencia_url'] ?? map['residenceProofUrl'])?.toString(),
      currentVehicleId: (map['veiculo_atual_id'] ?? map['veiculo_id'] ?? map['currentVehicleId'])?.toString(),
      avatarUrl: fotoFinal,
      isApproved: statusFinal == DriverStatus.active,
      street: (map['logradouro'] ?? map['endereco_rua'] ?? map['street'])?.toString(),
      number: (map['numero'] ?? map['number'])?.toString(),
      complement: (map['complemento'] ?? map['complement'])?.toString(),
      neighborhood: (map['bairro'] ?? map['neighborhood'])?.toString(),
      city: (map['cidade'] ?? map['endereco_cidade'] ?? map['city'])?.toString(),
      state: (map['estado'] ?? map['endereco_estado'] ?? map['state'])?.toString(),
      zip: (map['cep'] ?? map['endereco_cep'] ?? map['zip'])?.toString(),
      trustScore: (map['pontuacao_confianca'] ?? map['trustScore'] ?? 100) is int
          ? (map['pontuacao_confianca'] ?? map['trustScore'] ?? 100) as int
          : int.tryParse((map['pontuacao_confianca'] ?? map['trustScore'] ?? '100').toString()) ?? 100,
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
      'cnhFrontUrl': cnhFrontUrl,
      'cnhBackUrl': cnhBackUrl,
      'residenceProofUrl': residenceProofUrl,
      'currentVehicleId': currentVehicleId,
      'avatarUrl': avatarUrl,
      'isApproved': isApproved,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip': zip,
      'trustScore': trustScore,
      'outstandingBalance': outstandingBalance,
      'totalGenerated': totalGenerated,
    };
  }

  /// Mapeamento para inserção/atualização na tabela `motoristas` do Supabase
  Map<String, dynamic> toDatabaseMap() {
    String statusStr = 'pendente_aprovacao';
    switch (status) {
      case DriverStatus.active:
        statusStr = 'ativo';
        break;
      case DriverStatus.inactive:
        statusStr = 'inativo';
        break;
      case DriverStatus.pendingApproval:
        statusStr = 'pendente_aprovacao';
        break;
      case DriverStatus.blocked:
        statusStr = 'bloqueado';
        break;
    }

    final data = <String, dynamic>{
      'id': id,
      'cpf': cpf.replaceAll(RegExp(r'[^0-9]'), ''),
      'numero_cnh': cnhNumber.trim(),
      'categoria_cnh': cnhCategory.toUpperCase().trim(),
      'validade_cnh': cnhExpiry.toIso8601String().split('T')[0],
      'status': statusStr,
      'pontuacao_confianca': trustScore,
      'saldo_devedor': outstandingBalance,
      'valor_total_gerado': totalGenerated,
    };

    if (cnhFrontUrl != null && cnhFrontUrl!.isNotEmpty) {
      data['cnh_frente_url'] = cnhFrontUrl;
    }
    if (cnhBackUrl != null && cnhBackUrl!.isNotEmpty) {
      data['cnh_verso_url'] = cnhBackUrl;
    }
    if (residenceProofUrl != null && residenceProofUrl!.isNotEmpty) {
      data['comprovante_residencia_url'] = residenceProofUrl;
    }
    if (street != null) data['logradouro'] = street;
    if (number != null) data['numero'] = number;
    if (complement != null) data['complemento'] = complement;
    if (neighborhood != null) data['bairro'] = neighborhood;
    if (city != null) data['cidade'] = city;
    if (state != null) data['estado'] = state;
    if (zip != null) data['cep'] = zip;

    return data;
  }

  /// Mapeamento para inserção/atualização na tabela `perfis`
  Map<String, dynamic> toProfileDatabaseMap() {
    return {
      'id': id,
      'nome': name.trim(),
      'email': email.trim().toLowerCase(),
      'telefone': phone.trim(),
      'foto_url': avatarUrl.isNotEmpty ? avatarUrl : null,
      'cargo': 'motorista',
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
    String? cnhFrontUrl,
    String? cnhBackUrl,
    String? residenceProofUrl,
    String? currentVehicleId,
    String? avatarUrl,
    bool? isApproved,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
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
      cnhFrontUrl: cnhFrontUrl ?? this.cnhFrontUrl,
      cnhBackUrl: cnhBackUrl ?? this.cnhBackUrl,
      residenceProofUrl: residenceProofUrl ?? this.residenceProofUrl,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isApproved: isApproved ?? this.isApproved,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      trustScore: trustScore ?? this.trustScore,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      totalGenerated: totalGenerated ?? this.totalGenerated,
    );
  }
}
