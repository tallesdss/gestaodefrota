import '../models/financial_entry.dart';

List<FinancialEntry> mockFinancialEntries = [
  FinancialEntry(
    id: 'f1',
    type: FinancialType.income,
    category: 'aluguel',
    driverId: 'd1',
    vehicleId: 'v2',
    amount: 2500.0,
    date: DateTime(2024, 03, 01),
    description: 'Mensalidade Março/2024 - Maria',
    isPaid: true,
  ),
  FinancialEntry(
    id: 'f2',
    type: FinancialType.expense,
    category: 'manutenção',
    vehicleId: 'v3',
    amount: 850.0,
    date: DateTime(2024, 03, 10),
    description: 'Troca de pastilhas e óleo Corolla GHI-9012',
    isPaid: true,
  ),
  FinancialEntry(
    id: 'f3',
    type: FinancialType.expense,
    category: 'ipva',
    vehicleId: 'v4',
    amount: 1400.0,
    date: DateTime(2024, 03, 15),
    description: 'IPVA 2024 Polo JKL-3456',
    isPaid: false,
  ),
];
