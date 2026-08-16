import 'package:flutter/material.dart';

class ExpenseSubcategory {
  String name;
  ExpenseSubcategory({required this.name});

  factory ExpenseSubcategory.fromMap(Map<String, dynamic> map) {
    return ExpenseSubcategory(name: (map['nome'] ?? map['name'] ?? '').toString());
  }

  Map<String, dynamic> toMap() => {'name': name};
}

class ExpenseSubgroup {
  String name;
  List<ExpenseSubcategory> items;
  ExpenseSubgroup({required this.name, required this.items});

  factory ExpenseSubgroup.fromMap(Map<String, dynamic> map) {
    return ExpenseSubgroup(
      name: (map['nome'] ?? map['name'] ?? '').toString(),
      items: (map['items'] as List? ?? [])
          .map((i) => ExpenseSubcategory.fromMap(i is Map<String, dynamic> ? i : {'name': i.toString()}))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'items': items.map((i) => i.toMap()).toList(),
      };
}

class ExpenseCategory {
  final String? id;
  final String? parentId;
  String name;
  final String type; // 'despesa' or 'receita'
  final String? accountingCode;
  final bool isActive;
  final IconData icon;
  final Color color;
  List<ExpenseSubgroup> subgroups;

  ExpenseCategory({
    this.id,
    this.parentId,
    required this.name,
    this.type = 'despesa',
    this.accountingCode,
    this.isActive = true,
    required this.icon,
    required this.color,
    required this.subgroups,
  });

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id']?.toString(),
      parentId: (map['categoria_pai_id'] ?? map['parentId'])?.toString(),
      name: (map['nome'] ?? map['name'] ?? '').toString(),
      type: (map['tipo'] ?? map['type'] ?? 'despesa').toString(),
      accountingCode: (map['codigo_contabil'] ?? map['accountingCode'])?.toString(),
      isActive: (map['ativo'] ?? map['isActive'] ?? true) as bool,
      icon: Icons.category_outlined,
      color: const Color(0xFF00236F),
      subgroups: (map['subgroups'] as List? ?? [])
          .map((s) => ExpenseSubgroup.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'parentId': parentId,
        'name': name,
        'type': type,
        'accountingCode': accountingCode,
        'isActive': isActive,
        'subgroups': subgroups.map((s) => s.toMap()).toList(),
      };

  /// Mapeamento para a tabela `categorias_despesa` do Supabase
  Map<String, dynamic> toDatabaseMap() {
    final data = <String, dynamic>{
      'nome': name.trim(),
      'tipo': type == 'receita' ? 'receita' : 'despesa',
      'ativo': isActive,
    };

    if (id != null && id!.isNotEmpty && id!.contains('-')) {
      data['id'] = id;
    }
    if (parentId != null && parentId!.isNotEmpty) {
      data['categoria_pai_id'] = parentId;
    }
    if (accountingCode != null && accountingCode!.isNotEmpty) {
      data['codigo_contabil'] = accountingCode;
    }

    return data;
  }
}
