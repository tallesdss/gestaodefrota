import 'package:flutter/material.dart';

class ExpenseSubcategory {
  String name;
  ExpenseSubcategory({required this.name});

  factory ExpenseSubcategory.fromMap(Map<String, dynamic> map) {
    return ExpenseSubcategory(name: map['nome'] ?? map['name'] ?? '');
  }

  Map<String, dynamic> toMap() => {'name': name};
}

class ExpenseSubgroup {
  String name;
  List<ExpenseSubcategory> items;
  ExpenseSubgroup({required this.name, required this.items});

  factory ExpenseSubgroup.fromMap(Map<String, dynamic> map) {
    return ExpenseSubgroup(
      name: map['nome'] ?? map['name'] ?? '',
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
  String name;
  final IconData icon;
  final Color color;
  List<ExpenseSubgroup> subgroups;

  ExpenseCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.subgroups,
  });

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id']?.toString(),
      name: map['nome'] ?? map['name'] ?? '',
      icon: Icons.category_outlined,
      color: const Color(0xFF00236F),
      subgroups: (map['subgroups'] as List? ?? [])
          .map((s) => ExpenseSubgroup.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subgroups': subgroups.map((s) => s.toMap()).toList(),
      };
}
