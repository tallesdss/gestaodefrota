class Workshop {
  final String id;
  final String name;
  final String? corporateName;
  final String cnpj;
  final String phone;
  final String email;
  final String address;
  final bool isAccredited;
  final double rating;
  final double totalSpent;
  final double pendingPayment;
  final List<String> specializedServices;
  final String? bankName;
  final String? agency;
  final String? account;
  final String? pixKeyType;
  final String? pixKey;
  final String? bankInfo;

  Workshop({
    required this.id,
    required this.name,
    this.corporateName,
    required this.cnpj,
    required this.phone,
    required this.email,
    required this.address,
    required this.isAccredited,
    this.rating = 5.0,
    this.totalSpent = 0.0,
    this.pendingPayment = 0.0,
    this.specializedServices = const [],
    this.bankName,
    this.agency,
    this.account,
    this.pixKeyType,
    this.pixKey,
    this.bankInfo,
  });

  // Helper for balance
  double get balance => totalSpent - pendingPayment;

  factory Workshop.fromMap(Map<String, dynamic> map) {
    return Workshop(
      id: (map['id'] ?? '').toString(),
      name: (map['nome_fantasia'] ?? map['name'] ?? '').toString(),
      corporateName: (map['razao_social'] ?? map['corporateName'])?.toString(),
      cnpj: (map['cnpj'] ?? '').toString(),
      phone: (map['telefone'] ?? map['phone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      address: (map['endereco'] ?? map['address'] ?? '').toString(),
      isAccredited: map['isAccredited'] ?? (map['status'] == 'ativo' || map['status'] == 'active'),
      rating: (map['avaliacao'] ?? map['rating'] ?? 5.0).toDouble(),
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
      pendingPayment: (map['pendingPayment'] ?? 0.0).toDouble(),
      specializedServices: List<String>.from(map['specializedServices'] ?? []),
      bankName: (map['banco_nome'] ?? map['bankName'])?.toString(),
      agency: (map['agencia'] ?? map['agency'])?.toString(),
      account: (map['conta_corrente'] ?? map['account'])?.toString(),
      pixKeyType: (map['tipo_chave_pix'] ?? map['pixKeyType'])?.toString(),
      pixKey: (map['chave_pix'] ?? map['pixKey'])?.toString(),
      bankInfo: (map['dados_bancarios_json'] ?? map['bankInfo'])?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'corporateName': corporateName,
      'cnpj': cnpj,
      'phone': phone,
      'email': email,
      'address': address,
      'isAccredited': isAccredited,
      'rating': rating,
      'totalSpent': totalSpent,
      'pendingPayment': pendingPayment,
      'specializedServices': specializedServices,
      'bankName': bankName,
      'agency': agency,
      'account': account,
      'pixKeyType': pixKeyType,
      'pixKey': pixKey,
      'bankInfo': bankInfo,
    };
  }

  /// Mapeamento para inserção na tabela `oficinas` do Supabase
  Map<String, dynamic> toDatabaseMap() {
    final data = <String, dynamic>{
      'cnpj': cnpj.replaceAll(RegExp(r'[^0-9]'), ''),
      'nome_fantasia': name.trim(),
      'razao_social': corporateName?.trim() ?? name.trim(),
      'telefone': phone.trim(),
      'email': email.trim(),
      'endereco': address.trim(),
      'avaliacao': rating.clamp(1.0, 5.0),
      'status': isAccredited ? 'ativo' : 'inativo',
    };

    if (id.isNotEmpty && id.contains('-')) {
      data['id'] = id;
    }
    if (bankName != null && bankName!.isNotEmpty) data['banco_nome'] = bankName;
    if (agency != null && agency!.isNotEmpty) data['agencia'] = agency;
    if (account != null && account!.isNotEmpty) data['conta_corrente'] = account;
    if (pixKey != null && pixKey!.isNotEmpty) data['chave_pix'] = pixKey;
    if (pixKeyType != null && pixKeyType!.isNotEmpty) data['tipo_chave_pix'] = pixKeyType;

    return data;
  }
}

class WorkshopParts {
  final String id;
  final String workshopId;
  final String name;
  final double price;
  final DateTime date;
  final String vehiclePlate;

  WorkshopParts({
    required this.id,
    required this.workshopId,
    required this.name,
    required this.price,
    required this.date,
    required this.vehiclePlate,
  });

  factory WorkshopParts.fromMap(Map<String, dynamic> map) {
    return WorkshopParts(
      id: (map['id'] ?? '').toString(),
      workshopId: (map['oficina_id'] ?? map['workshopId'] ?? '').toString(),
      name: (map['descricao_peca'] ?? map['nome'] ?? map['name'] ?? '').toString(),
      price: (map['valor_unitario'] ?? map['valor'] ?? map['price'] ?? 0.0).toDouble(),
      date: DateTime.tryParse((map['data_servico'] ?? map['data'] ?? map['date'] ?? '').toString()) ?? DateTime.now(),
      vehiclePlate: (map['placa_veiculo'] ?? map['vehiclePlate'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workshopId': workshopId,
      'name': name,
      'price': price,
      'date': date.toIso8601String(),
      'vehiclePlate': vehiclePlate,
    };
  }
}

class WorkshopDocument {
  final String id;
  final String workshopId;
  final String title;
  final String type; // 'NFe' or 'Recibo'
  final DateTime date;
  final double value;
  final String status; // 'Paid', 'Pending'
  final String? imageUrl;

  WorkshopDocument({
    required this.id,
    required this.workshopId,
    required this.title,
    required this.type,
    required this.date,
    required this.value,
    this.status = 'Paid',
    this.imageUrl,
  });

  factory WorkshopDocument.fromMap(Map<String, dynamic> map) {
    return WorkshopDocument(
      id: (map['id'] ?? '').toString(),
      workshopId: (map['oficina_id'] ?? map['workshopId'] ?? '').toString(),
      title: (map['descricao'] ?? map['title'] ?? 'Documento').toString(),
      type: (map['type'] ?? 'NFe').toString(),
      date: DateTime.tryParse((map['data_servico'] ?? map['date'] ?? '').toString()) ?? DateTime.now(),
      value: (map['custo_total'] ?? map['value'] ?? 0.0).toDouble(),
      status: (map['status'] ?? 'Paid').toString(),
      imageUrl: (map['nota_fiscal_nfe_url'] ?? map['imageUrl'])?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workshopId': workshopId,
      'title': title,
      'type': type,
      'date': date.toIso8601String(),
      'value': value,
      'status': status,
      'imageUrl': imageUrl,
    };
  }
}
