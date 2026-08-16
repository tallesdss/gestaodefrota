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
  });

  factory Manager.fromMap(Map<String, dynamic> map) {
    ManagerStatus parseStatus(dynamic val) {
      if (val == null) return ManagerStatus.active;
      final s = val.toString().toLowerCase();
      if (s == 'inativo' || s == 'inactive') return ManagerStatus.inactive;
      return ManagerStatus.active;
    }

    return Manager(
      id: (map['id'] ?? '').toString(),
      name: map['nome'] ?? map['name'] ?? '',
      cpf: map['cpf'],
      phone: map['telefone'] ?? map['phone'] ?? '',
      email: map['email'] ?? '',
      status: parseStatus(map['status']),
      avatarUrl: map['foto_url'] ?? map['avatarUrl'] ?? '',
      isApproved: map['isApproved'] ?? map['ativo'] ?? true,
      baseSalary: (map['salario_base'] ?? map['baseSalary'] ?? 0.0).toDouble(),
      commissionPercentage: (map['percentual_comissao'] ?? map['commissionPercentage'] ?? 0.0).toDouble(),
      permissions: map['permissoes_json'] is Map<String, dynamic>
          ? map['permissoes_json']
          : (map['permissions'] is Map<String, dynamic> ? map['permissions'] : {}),
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
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'salario_base': baseSalary,
      'percentual_comissao': commissionPercentage,
      'permissoes_json': permissions,
      'ativo': isApproved,
    };
  }
}
