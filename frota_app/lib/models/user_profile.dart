/// Modelo Unificado de Usuário e Papéis no Sistema (RBAC com Flags Booleanas)
class UserProfile {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? fotoUrl;
  final String cargo;
  final bool isAdmin;
  final bool isGestor;
  final bool isMotorista;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const UserProfile({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.fotoUrl,
    this.cargo = 'motorista',
    this.isAdmin = false,
    this.isGestor = false,
    this.isMotorista = true,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  /// Factory para converter dados retornados do Supabase (`public.perfis`)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final cargoStr = (map['cargo'] ?? 'motorista').toString().toLowerCase();

    final bool adminFlag = map['is_admin'] == true || cargoStr == 'admin';
    final bool gestorFlag = map['is_gestor'] == true || cargoStr == 'gestor' || adminFlag;
    final bool motoristaFlag = map['is_motorista'] == true || cargoStr == 'motorista';

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return UserProfile(
      id: (map['id'] ?? '').toString(),
      nome: (map['nome'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      telefone: map['telefone']?.toString(),
      fotoUrl: map['foto_url']?.toString(),
      cargo: cargoStr,
      isAdmin: adminFlag,
      isGestor: gestorFlag,
      isMotorista: motoristaFlag,
      criadoEm: parseDate(map['criado_em']),
      atualizadoEm: parseDate(map['atualizado_em']),
    );
  }

  /// Mapeamento para persistência na tabela `public.perfis`
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome.trim(),
      'email': email.trim().toLowerCase(),
      'telefone': telefone?.trim(),
      'foto_url': fotoUrl,
      'cargo': cargo,
      'is_admin': isAdmin,
      'is_gestor': isGestor,
      'is_motorista': isMotorista,
    };
  }

  /// Clonar com alterações
  UserProfile copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    String? fotoUrl,
    String? cargo,
    bool? isAdmin,
    bool? isGestor,
    bool? isMotorista,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      cargo: cargo ?? this.cargo,
      isAdmin: isAdmin ?? this.isAdmin,
      isGestor: isGestor ?? this.isGestor,
      isMotorista: isMotorista ?? this.isMotorista,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
