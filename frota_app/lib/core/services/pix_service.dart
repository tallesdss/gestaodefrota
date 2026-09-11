import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/admin_pix_config.dart';
import '../config/supabase_config.dart';

/// Serviço gerenciador de Configuração PIX da Empresa / Administrador
/// e Gerador de Payload EMV BACEN (BRCode / Pix Copia e Cola)
class PixService {
  static final PixService _instance = PixService._internal();
  factory PixService() => _instance;
  PixService._internal();

  AdminPixConfig _currentConfig = AdminPixConfig.defaultConfig();

  final ValueNotifier<AdminPixConfig> configNotifier =
      ValueNotifier<AdminPixConfig>(AdminPixConfig.defaultConfig());

  AdminPixConfig get currentConfig => _currentConfig;

  bool _initialized = false;

  /// Inicializa e sincroniza configuração persistida
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final response = await SupabaseConfig.client
          .from('configuracoes_sistema')
          .select('valor')
          .eq('chave', 'admin_pix_config')
          .maybeSingle();

      if (response != null && response['valor'] != null) {
        final map = response['valor'] is Map
            ? Map<String, dynamic>.from(response['valor'] as Map)
            : jsonDecode(response['valor'].toString());
        _currentConfig = AdminPixConfig.fromMap(map);
        configNotifier.value = _currentConfig;
      }
    } catch (_) {
      // Fallback em memória
    }
  }

  /// Salva nova configuração da chave PIX do Administrador
  Future<void> updateConfig(AdminPixConfig newConfig) async {
    _currentConfig = newConfig;
    configNotifier.value = newConfig;

    try {
      await SupabaseConfig.client
          .from('configuracoes_sistema')
          .upsert({
            'chave': 'admin_pix_config',
            'valor': newConfig.toMap(),
            'atualizado_em': DateTime.now().toIso8601String(),
          }, onConflict: 'chave');
    } catch (_) {
      // Se a tabela configuracoes_sistema não existir, mantém salvo no singleton em memória
    }
  }

  /// Normaliza texto para o padrão BACEN (sem acentuações, uppercase)
  static String _sanitizeText(String text, int maxLength) {
    var result = text
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[ÁÀÃÂÄ]'), 'A')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[ÍÌÎÏ]'), 'I')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[ÓÒÕÔÖ]'), 'O')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ÚÙÛÜ]'), 'U')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[Ç]'), 'C')
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .trim()
        .toUpperCase();

    if (result.length > maxLength) {
      result = result.substring(0, maxLength);
    }
    return result.isEmpty ? 'ARCHITECT' : result;
  }

  /// Formata campo TLV (Tag-Length-Value)
  static String _formatTlv(String id, String value) {
    final len = value.length.toString().padLeft(2, '0');
    return '$id$len$value';
  }

  /// Cálculo CRC16-CCITT (Polinômio 0x1021, Inicial 0xFFFF) conforme norma BACEN Pix
  static int _calculateCrc16(String payload) {
    int crc = 0xFFFF;
    const int polynomial = 0x1021;
    final bytes = utf8.encode(payload);

    for (final byte in bytes) {
      for (int i = 0; i < 8; i++) {
        final bit = ((byte >> (7 - i)) & 1) == 1;
        final c15 = ((crc >> 15) & 1) == 1;
        crc <<= 1;
        if (c15 ^ bit) {
          crc ^= polynomial;
        }
        crc &= 0xFFFF;
      }
    }
    return crc & 0xFFFF;
  }

  /// Gera a string oficial do Pix Copia e Cola (EMV BACEN BRCode)
  String generatePixPayload({
    required double amount,
    String? txId,
    String? customDescription,
    AdminPixConfig? customConfig,
  }) {
    final cfg = customConfig ?? _currentConfig;
    final key = cfg.sanitizedPixKey;
    final name = _sanitizeText(cfg.merchantName, 25);
    final city = _sanitizeText(cfg.merchantCity, 15);
    final description = (customDescription ?? cfg.description ?? 'ALUGUEL')
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .trim();

    final buffer = StringBuffer();

    // 00 - Payload Format Indicator
    buffer.write(_formatTlv('00', '01'));

    // 26 - Merchant Account Information (PIX)
    final merchantInfo = StringBuffer();
    merchantInfo.write(_formatTlv('00', 'BR.GOV.BCB.PIX'));
    merchantInfo.write(_formatTlv('01', key));
    if (description.isNotEmpty) {
      final descSanitized = description.length > 25 ? description.substring(0, 25) : description;
      merchantInfo.write(_formatTlv('02', descSanitized));
    }
    buffer.write(_formatTlv('26', merchantInfo.toString()));

    // 52 - Merchant Category Code
    buffer.write(_formatTlv('52', '0000'));

    // 53 - Transaction Currency (986 = BRL)
    buffer.write(_formatTlv('53', '986'));

    // 54 - Transaction Amount (se > 0)
    if (amount > 0) {
      final formattedAmount = amount.toStringAsFixed(2);
      buffer.write(_formatTlv('54', formattedAmount));
    }

    // 58 - Country Code (BR)
    buffer.write(_formatTlv('58', 'BR'));

    // 59 - Merchant Name
    buffer.write(_formatTlv('59', name));

    // 60 - Merchant City
    buffer.write(_formatTlv('60', city));

    // 62 - Additional Data Field Template (TxID)
    final refLabel = (txId != null && txId.isNotEmpty)
        ? txId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        : '***';
    final txSanitized = refLabel.length > 25 ? refLabel.substring(0, 25) : refLabel;
    final additionalData = _formatTlv('05', txSanitized.isEmpty ? '***' : txSanitized);
    buffer.write(_formatTlv('62', additionalData));

    // 63 - CRC16
    final payloadBeforeCrc = '${buffer.toString()}6304';
    final crcValue = _calculateCrc16(payloadBeforeCrc);
    final crcHex = crcValue.toRadixString(16).toUpperCase().padLeft(4, '0');

    return '$payloadBeforeCrc$crcHex';
  }
}
