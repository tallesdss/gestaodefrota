import 'package:flutter_test/flutter_test.dart';
import 'package:frota_app/core/repositories/financial_repository.dart';
import 'package:frota_app/models/financial_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final fakeClient = SupabaseClient('https://mock.supabase.co', 'fake-anon-key');

  group('FinancialEntry Model Tests', () {
    test('isLate is calculated dynamically via fromMap when due date has passed and unpaid', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 3));
      final map = {
        'id': 'entry-1',
        'tipo': 'receita',
        'categoria': 'aluguel',
        'valor': 750.0,
        'data_vencimento': pastDate.toIso8601String(),
        'status': 'pendente',
        'descricao': 'Aluguel Semanal 1/4',
      };

      final entry = FinancialEntry.fromMap(map);

      expect(entry.isLate, isTrue);
      expect(entry.isPaid, isFalse);
      expect(entry.amount, equals(750.0));
    });

    test('isLate is false when due date is in the future', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final map = {
        'id': 'entry-2',
        'tipo': 'receita',
        'categoria': 'aluguel',
        'valor': 750.0,
        'data_vencimento': futureDate.toIso8601String(),
        'status': 'pendente',
        'descricao': 'Aluguel Semanal 2/4',
      };

      final entry = FinancialEntry.fromMap(map);

      expect(entry.isLate, isFalse);
      expect(entry.isPaid, isFalse);
    });

    test('isLate is false when status is pago even if due date passed', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      final map = {
        'id': 'entry-3',
        'tipo': 'receita',
        'categoria': 'aluguel',
        'valor': 750.0,
        'data_vencimento': pastDate.toIso8601String(),
        'status': 'pago',
        'descricao': 'Aluguel Semanal 1/4',
      };

      final entry = FinancialEntry.fromMap(map);

      expect(entry.isLate, isFalse);
      expect(entry.isPaid, isTrue);
    });
  });

  group('FinancialRepository Contract Installments Generation', () {
    test('Generates correct weekly installments for 12 weeks at R\$ 750,00', () async {
      final repo = FinancialRepository(client: fakeClient);
      final installments = await repo.generateContractInstallments(
        driverId: 'test-driver-123',
        vehicleId: 'test-car-999',
        rentalValue: 750.0,
        frequency: 'semanal',
        dueDay: 3, // Quarta-feira
        durationWeeks: 12,
        startDate: DateTime(2026, 9, 1),
        persistToDb: false,
      );

      expect(installments.length, equals(12));
      expect(installments.first.amount, equals(750.0));
      expect(installments.first.description, contains('1/12'));
      expect(installments.last.description, contains('12/12'));
      expect(installments.first.date.weekday, equals(DateTime.wednesday));
      expect(installments[1].date.difference(installments.first.date).inDays, equals(7));
    });

    test('Batch payment marks all selected entries as paid', () async {
      final repo = FinancialRepository(client: fakeClient);
      final installments = await repo.generateContractInstallments(
        driverId: 'test-driver-batch',
        vehicleId: 'test-car-888',
        rentalValue: 750.0,
        frequency: 'semanal',
        dueDay: 3,
        durationWeeks: 4,
        startDate: DateTime.now(),
        persistToDb: false,
      );

      final ids = installments.map((e) => e.id).toList();
      await repo.markBatchAsPaid(ids, paymentMethod: 'pix');

      final driverEntries = await repo.getFinancialEntries(driverId: 'test-driver-batch');
      for (final entry in driverEntries) {
        expect(entry.isPaid, isTrue);
        expect(entry.isLate, isFalse);
        expect(entry.paymentMethod, equals('pix'));
      }
    });
  });
}
