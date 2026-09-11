import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frota_app/core/config/supabase_config.dart';
import 'package:frota_app/models/vehicle.dart';

void main() {
  group('Vehicle Model Supabase Serialization Tests', () {
    test('Vehicle parses accurately from Supabase JSON', () {
      final map = {
        'id': '885b06b4-40dd-46a6-bd2f-77f251566a10',
        'placa': 'BVT2356',
        'marca': 'BYD',
        'modelo': 'MINI',
        'ano_fabricacao': 2026,
        'ano_modelo': 2026,
        'cor': 'azul',
        'km_atual': 195000,
        'status': 'alugado',
        'motorista_atual_nome': 'Carlos Silva Motorista',
      };

      final vehicle = Vehicle.fromMap(map);

      expect(vehicle.id, equals('885b06b4-40dd-46a6-bd2f-77f251566a10'));
      expect(vehicle.plate, equals('BVT2356'));
      expect(vehicle.brand, equals('BYD'));
      expect(vehicle.model, equals('MINI'));
      expect(vehicle.currentKm, equals(195000));
      expect(vehicle.status, equals(VehicleStatus.rented));
      expect(vehicle.currentDriverName, equals('Carlos Silva Motorista'));
    });
  });
}
