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
    this.bankInfo,
  });

  // Helper for balance
  double get balance => totalSpent - pendingPayment;

  factory Workshop.fromMap(Map<String, dynamic> map) {
    return Workshop(
      id: (map['id'] ?? '').toString(),
      name: map['nome_fantasia'] ?? map['name'] ?? '',
      corporateName: map['razao_social'] ?? map['corporateName'],
      cnpj: map['cnpj'] ?? '',
      phone: map['telefone'] ?? map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['endereco'] ?? map['address'] ?? '',
      isAccredited: map['isAccredited'] ?? (map['status'] == 'ativo' || map['status'] == 'active'),
      rating: (map['avaliacao'] ?? map['rating'] ?? 5.0).toDouble(),
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
      pendingPayment: (map['pendingPayment'] ?? 0.0).toDouble(),
      specializedServices: List<String>.from(map['specializedServices'] ?? []),
      bankInfo: map['dados_bancarios_json'] != null
          ? map['dados_bancarios_json'].toString()
          : map['bankInfo'],
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
      'bankInfo': bankInfo,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'nome_fantasia': name,
      'razao_social': corporateName,
      'cnpj': cnpj,
      'telefone': phone,
      'email': email,
      'endereco': address,
      'avaliacao': rating,
      'status': isAccredited ? 'ativo' : 'inativo',
    };
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
      workshopId: map['oficina_id'] ?? map['workshopId'] ?? '',
      name: map['nome'] ?? map['name'] ?? '',
      price: (map['valor'] ?? map['price'] ?? 0.0).toDouble(),
      date: DateTime.tryParse(map['data'] ?? map['date'] ?? '') ?? DateTime.now(),
      vehiclePlate: map['placa_veiculo'] ?? map['vehiclePlate'] ?? '',
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
      workshopId: map['oficina_id'] ?? map['workshopId'] ?? '',
      title: map['titulo'] ?? map['title'] ?? 'NFe',
      type: map['tipo'] ?? map['type'] ?? 'NFe',
      date: DateTime.tryParse(map['data'] ?? map['date'] ?? '') ?? DateTime.now(),
      value: (map['valor'] ?? map['value'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Paid',
      imageUrl: map['nota_fiscal_nfe_url'] ?? map['imageUrl'],
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
