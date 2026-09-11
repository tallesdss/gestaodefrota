import 'dart:convert';

enum PixKeyType {
  cnpj,
  cpf,
  email,
  telefone,
  aleatoria;

  String get label {
    switch (this) {
      case PixKeyType.cnpj:
        return 'CNPJ';
      case PixKeyType.cpf:
        return 'CPF';
      case PixKeyType.email:
        return 'E-mail';
      case PixKeyType.telefone:
        return 'Telefone';
      case PixKeyType.aleatoria:
        return 'Chave Aleatória (EVP)';
    }
  }

  static PixKeyType fromString(String? type) {
    if (type == null) return PixKeyType.cnpj;
    final lower = type.toLowerCase().trim();
    if (lower.contains('cnpj')) return PixKeyType.cnpj;
    if (lower.contains('cpf')) return PixKeyType.cpf;
    if (lower.contains('email') || lower.contains('e-mail')) return PixKeyType.email;
    if (lower.contains('tel') || lower.contains('phone') || lower.contains('celular')) {
      return PixKeyType.telefone;
    }
    return PixKeyType.aleatoria;
  }
}

class AdminPixConfig {
  final PixKeyType keyType;
  final String pixKey;
  final String merchantName;
  final String merchantCity;
  final String? bankName;
  final String? description;
  final DateTime updatedAt;

  const AdminPixConfig({
    required this.keyType,
    required this.pixKey,
    required this.merchantName,
    required this.merchantCity,
    this.bankName,
    this.description,
    required this.updatedAt,
  });

  /// Configuração padrão inicial
  factory AdminPixConfig.defaultConfig() {
    return AdminPixConfig(
      keyType: PixKeyType.cnpj,
      pixKey: '54.123.456/0001-89',
      merchantName: 'ARCHITECT FLEET',
      merchantCity: 'SAO PAULO',
      bankName: 'Banco Inter',
      description: 'Aluguel de Veículo',
      updatedAt: DateTime.now(),
    );
  }

  /// Limpa a chave para uso no payload PIX de acordo com o tipo
  String get sanitizedPixKey {
    final raw = pixKey.trim();
    switch (keyType) {
      case PixKeyType.cnpj:
      case PixKeyType.cpf:
        return raw.replaceAll(RegExp(r'[^0-9]'), '');
      case PixKeyType.telefone:
        var digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
        if (!digits.startsWith('+')) {
          if (digits.length == 10 || digits.length == 11) {
            digits = '+55$digits';
          }
        }
        return digits;
      case PixKeyType.email:
        return raw.toLowerCase();
      case PixKeyType.aleatoria:
        return raw;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo_chave': keyType.name,
      'chave_pix': pixKey,
      'nome_titular': merchantName,
      'cidade': merchantCity,
      'banco': bankName,
      'descricao': description,
      'atualizado_em': updatedAt.toIso8601String(),
    };
  }

  factory AdminPixConfig.fromMap(Map<String, dynamic> map) {
    return AdminPixConfig(
      keyType: PixKeyType.fromString(map['tipo_chave']?.toString()),
      pixKey: (map['chave_pix'] ?? map['pixKey'] ?? '').toString(),
      merchantName: (map['nome_titular'] ?? map['merchantName'] ?? 'ARCHITECT FLEET').toString(),
      merchantCity: (map['cidade'] ?? map['merchantCity'] ?? 'SAO PAULO').toString(),
      bankName: map['banco']?.toString() ?? map['bankName']?.toString(),
      description: map['descricao']?.toString() ?? map['description']?.toString(),
      updatedAt: DateTime.tryParse(map['atualizado_em']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory AdminPixConfig.fromJson(String source) => AdminPixConfig.fromMap(jsonDecode(source));

  AdminPixConfig copyWith({
    PixKeyType? keyType,
    String? pixKey,
    String? merchantName,
    String? merchantCity,
    String? bankName,
    String? description,
    DateTime? updatedAt,
  }) {
    return AdminPixConfig(
      keyType: keyType ?? this.keyType,
      pixKey: pixKey ?? this.pixKey,
      merchantName: merchantName ?? this.merchantName,
      merchantCity: merchantCity ?? this.merchantCity,
      bankName: bankName ?? this.bankName,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
