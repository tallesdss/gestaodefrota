import 'package:flutter/material.dart';

class SaaSPlan {
  final String id;
  final String name;
  final double price;
  final int maxVehicles;
  final int maxUsers;
  final bool isPopular;
  final Color color;
  final List<String> features;

  SaaSPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.maxVehicles,
    required this.maxUsers,
    this.isPopular = false,
    required this.color,
    this.features = const [],
  });

  SaaSPlan copyWith({
    String? name,
    double? price,
    int? maxVehicles,
    int? maxUsers,
    bool? isPopular,
    Color? color,
    List<String>? features,
  }) {
    return SaaSPlan(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      maxVehicles: maxVehicles ?? this.maxVehicles,
      maxUsers: maxUsers ?? this.maxUsers,
      isPopular: isPopular ?? this.isPopular,
      color: color ?? this.color,
      features: features ?? this.features,
    );
  }
}
