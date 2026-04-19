import '../models/company.dart';

class MockCompanies {
  static List<Company> getCompanies() {
    return [
      Company(
        id: '1',
        name: 'Transportes TransLog Ltda',
        cnpj: '12.345.678/0001-99',
        ownerName: 'Ricardo Almeida',
        email: 'contato@translog.com.br',
        status: CompanyStatus.active,
        plan: CompanyPlan.enterprise,
        vehicleLimit: 500,
        currentVehicles: 152,
        createdAt: DateTime(2023, 10, 15),
      ),
      Company(
        id: '2',
        name: 'Frota Rápida Delivery',
        cnpj: '98.765.432/0001-11',
        ownerName: 'Mariana Costa',
        email: 'financeiro@frotarapida.com',
        status: CompanyStatus.active,
        plan: CompanyPlan.pro,
        vehicleLimit: 100,
        currentVehicles: 48,
        createdAt: DateTime(2024, 1, 20),
      ),
      Company(
        id: '3',
        name: 'Express Encomendas',
        cnpj: '45.678.912/0001-88',
        ownerName: 'Carlos Eduardo',
        email: 'cadu@express.com',
        status: CompanyStatus.inactive,
        plan: CompanyPlan.basic,
        vehicleLimit: 20,
        currentVehicles: 12,
        createdAt: DateTime(2024, 3, 5),
      ),
      Company(
        id: '4',
        name: 'Logística Total',
        cnpj: '11.222.333/0001-44',
        ownerName: 'Ana Paula',
        email: 'adm@logtotal.com.br',
        status: CompanyStatus.blocked,
        plan: CompanyPlan.pro,
        vehicleLimit: 100,
        currentVehicles: 85,
        createdAt: DateTime(2023, 11, 10),
      ),
    ];
  }
}
