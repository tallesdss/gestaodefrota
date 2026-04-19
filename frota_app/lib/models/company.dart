enum CompanyStatus { active, inactive, blocked }

enum CompanyPlan { basic, pro, enterprise }

class Company {
  final String id;
  final String name;
  final String cnpj;
  final String ownerName;
  final String email;
  final CompanyStatus status;
  final CompanyPlan plan;
  final int vehicleLimit;
  final int currentVehicles;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.ownerName,
    required this.email,
    required this.status,
    required this.plan,
    required this.vehicleLimit,
    required this.currentVehicles,
    required this.createdAt,
  });

  String get planName {
    switch (plan) {
      case CompanyPlan.basic:
        return 'Básico';
      case CompanyPlan.pro:
        return 'Pro';
      case CompanyPlan.enterprise:
        return 'Enterprise';
    }
  }
}
