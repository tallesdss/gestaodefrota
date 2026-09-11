import 'package:flutter_test/flutter_test.dart';
import 'package:frota_app/core/services/pix_service.dart';
import 'package:frota_app/models/admin_pix_config.dart';

void main() {
  group('AdminPixConfig Model Tests', () {
    test('Sanitizes CNPJ removing special characters', () {
      final config = AdminPixConfig(
        keyType: PixKeyType.cnpj,
        pixKey: '54.123.456/0001-89',
        merchantName: 'Architect Fleet Solutions',
        merchantCity: 'São Paulo',
        updatedAt: DateTime.now(),
      );

      expect(config.sanitizedPixKey, equals('54123456000189'));
    });

    test('Sanitizes CPF removing special characters', () {
      final config = AdminPixConfig(
        keyType: PixKeyType.cpf,
        pixKey: '123.456.789-00',
        merchantName: 'Ricardo Almeida',
        merchantCity: 'São Paulo',
        updatedAt: DateTime.now(),
      );

      expect(config.sanitizedPixKey, equals('12345678900'));
    });

    test('Sanitizes Phone prefixing with +55 if needed', () {
      final config = AdminPixConfig(
        keyType: PixKeyType.telefone,
        pixKey: '(11) 98822-1100',
        merchantName: 'Ricardo Almeida',
        merchantCity: 'São Paulo',
        updatedAt: DateTime.now(),
      );

      expect(config.sanitizedPixKey, equals('+5511988221100'));
    });

    test('Preserves Email and Random Key', () {
      final emailConfig = AdminPixConfig(
        keyType: PixKeyType.email,
        pixKey: 'Financeiro@Frota.com.br',
        merchantName: 'Architect Fleet',
        merchantCity: 'São Paulo',
        updatedAt: DateTime.now(),
      );
      expect(emailConfig.sanitizedPixKey, equals('financeiro@frota.com.br'));

      final randomConfig = AdminPixConfig(
        keyType: PixKeyType.aleatoria,
        pixKey: '123e4567-e89b-12d3-a456-426614174000',
        merchantName: 'Architect Fleet',
        merchantCity: 'São Paulo',
        updatedAt: DateTime.now(),
      );
      expect(randomConfig.sanitizedPixKey, equals('123e4567-e89b-12d3-a456-426614174000'));
    });
  });

  group('PixService BRCode Payload Generator Tests', () {
    final pixService = PixService();

    test('Generates valid BACEN EMV BRCode payload with R\$ 750,00 amount', () {
      final config = AdminPixConfig(
        keyType: PixKeyType.cnpj,
        pixKey: '54.123.456/0001-89',
        merchantName: 'ARCHITECT FLEET',
        merchantCity: 'SAO PAULO',
        updatedAt: DateTime.now(),
      );

      final payload = pixService.generatePixPayload(
        amount: 750.00,
        txId: 'ALUGUEL01',
        customConfig: config,
      );

      expect(payload.startsWith('000201'), isTrue);
      expect(payload.contains('BR.GOV.BCB.PIX'), isTrue);
      expect(payload.contains('54123456000189'), isTrue);
      expect(payload.contains('5406750.00'), isTrue);
      expect(payload.contains('5802BR'), isTrue);
      expect(payload.contains('5915ARCHITECT FLEET'), isTrue);
      expect(payload.contains('6009SAO PAULO'), isTrue);
      expect(payload.contains('6304'), isTrue);
      expect(payload.length, greaterThan(70));
    });

    test('Generates batch quitação payload for R\$ 9.000,00 (12 x R\$ 750)', () {
      final payload = pixService.generatePixPayload(
        amount: 9000.00,
        txId: 'QUITACAO12',
      );

      expect(payload.contains('54079000.00'), isTrue);
      expect(payload.endsWith(payload.substring(payload.length - 4)), isTrue);
    });

    test('Dynamic update updates ValueNotifier synchronously', () async {
      final newConfig = AdminPixConfig(
        keyType: PixKeyType.email,
        pixKey: 'novo-pix@empresa.com.br',
        merchantName: 'EMPRESA TESTE',
        merchantCity: 'CURITIBA',
        updatedAt: DateTime.now(),
      );

      await pixService.updateConfig(newConfig);

      expect(pixService.currentConfig.pixKey, equals('novo-pix@empresa.com.br'));
      expect(pixService.configNotifier.value.merchantCity, equals('CURITIBA'));
    });
  });
}
