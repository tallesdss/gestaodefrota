enum ManagerStatus { active, inactive }

class Manager {
  final String id;
  final String name;
  final String? cpf;
  final String phone;
  final String email;
  final ManagerStatus status;
  final String avatarUrl;
  final bool isApproved;
  final double baseSalary;
  final double commissionPercentage;
  final Map<String, dynamic> permissions;
  final List<String> permissionCodes;

  Manager({
    required this.id,
    required this.name,
    this.cpf,
    required this.phone,
    required this.email,
    required this.status,
    required this.avatarUrl,
    this.isApproved = true,
    this.baseSalary = 0.0,
    this.commissionPercentage = 0.0,
    this.permissions = const {},
    this.permissionCodes = const [],
  });

  factory Manager.fromMap(Map<String, dynamic> map) {
    ManagerStatus parseStatus(dynamic val, dynamic ativoVal) {
      if (ativoVal != null && ativoVal is bool) {
        return ativoVal ? ManagerStatus.active : ManagerStatus.inactive;
      }
      if (val == null) return ManagerStatus.active;
      final s = val.toString().toLowerCase();
      if (s == 'inativo' || s == 'inactive') return ManagerStatus.inactive;
      return ManagerStatus.active;
    }

    final perfil = map['perfis'] is Map<String, dynamic> ? map['perfis'] as Map<String, dynamic> : null;

    final nomeFinal = (perfil?['nome'] ?? map['nome'] ?? map['name'] ?? '').toString();
    final emailFinal = (perfil?['email'] ?? map['email'] ?? '').toString();
    final telefoneFinal = (perfil?['telefone'] ?? map['telefone'] ?? map['phone'] ?? '').toString();
    final fotoFinal = (perfil?['foto_url'] ?? map['foto_url'] ?? map['avatarUrl'] ?? '').toString();

    List<String> codes = [];
    if (map['gestor_permissoes'] is List) {
      codes = (map['gestor_permissoes'] as List)
          .map((gp) => (gp['permissoes'] != null ? gp['permissoes']['codigo'] : gp['permissao_codigo'])?.toString() ?? '')
          .where((c) => c.isNotEmpty)
          .toList();
    } else if (map['permissionCodes'] is List) {
      codes = List<String>.from(map['permissionCodes']);
    }

    return Manager(
      id: (map['id'] ?? '').toString(),
      name: nomeFinal,
      cpf: map['cpf']?.toString(),
      phone: telefoneFinal,
      email: emailFinal,
      status: parseStatus(map['status'], map['ativo']),
      avatarUrl: fotoFinal,
      isApproved: map['isApproved'] ?? map['ativo'] ?? true,
      baseSalary: (map['salario_base'] ?? map['baseSalary'] ?? 0.0).toDouble(),
      commissionPercentage: (map['percentual_comissao'] ?? map['commissionPercentage'] ?? 0.0).toDouble(),
      permissions: map['permissoes_json'] is Map<String, dynamic>
          ? map['permissoes_json']
          : (map['permissions'] is Map<String, dynamic> ? map['permissions'] : {}),
      permissionCodes: codes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'phone': phone,
      'email': email,
      'status': status.name,
      'avatarUrl': avatarUrl,
      'isApproved': isApproved,
      'baseSalary': baseSalary,
      'commissionPercentage': commissionPercentage,
      'permissions': permissions,
      'permissionCodes': permissionCodes,
    };
  }

  /// Mapeamento para a tabela `gestores` do Supabase
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'salario_base': baseSalary >= 0 ? baseSalary : 0.0,
      'percentual_comissao': commissionPercentage.clamp(0.0, 100.0),
      'ativo': isApproved && status == ManagerStatus.active,
    };
  }

  /// Mapeamento para a tabela `perfis` do Supabase
  Map<String, dynamic> toProfileDatabaseMap() {
    return {
      'id': id,
      'nome': name.trim(),
      'email': email.trim().toLowerCase(),
      'telefone': phone.trim(),
      'foto_url': avatarUrl.isNotEmpty ? avatarUrl : null,
      'cargo': 'gestor',
    };
  }

  Manager copyWith({
    String? id,
    String? name,
    String? cpf,
    String? phone,
    String? email,
    ManagerStatus? status,
    String? avatarUrl,
    bool? isApproved,
    double? baseSalary,
    double? commissionPercentage,
    Map<String, dynamic>? permissions,
    List<String>? permissionCodes,
  }) {
    return Manager(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isApproved: isApproved ?? this.isApproved,
      baseSalary: baseSalary ?? this.baseSalary,
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      permissions: permissions ?? this.permissions,
      permissionCodes: permissionCodes ?? this.permissionCodes,
    );
  }
}
