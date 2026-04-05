import 'package:flutter/material.dart';

class ExpenseSubcategory {
  String name;
  ExpenseSubcategory({required this.name});
}

class ExpenseSubgroup {
  String name;
  List<ExpenseSubcategory> items;
  ExpenseSubgroup({required this.name, required this.items});
}

class ExpenseCategory {
  String name;
  final IconData icon;
  final Color color;
  List<ExpenseSubgroup> subgroups;

  ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.subgroups,
  });
}
