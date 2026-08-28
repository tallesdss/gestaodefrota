import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/financial_entry.dart';
import '../../models/expense_category.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para o Módulo Financeiro, Caixa e KPIs no Supabase
class FinancialRepository {
  final SupabaseClient _client;

  FinancialRepository({SupabaseClient? client}) : _client = client ?? supabase;

bool _isValidUuid(String? str) {
  if (str == null || str.isEmpty) return false;
  return RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(str);
}

  /// Listar lançamentos financeiros usando a view relacional `vw_extrato_completo_motorista`
  Future<List<FinancialEntry>> getFinancialEntries({
    String? type, // 'receita', 'despesa'
    String? status, // 'pago', 'pendente', 'atrasado'
    String? driverId,
    String? vehicleId,
  }) async {
    try {
      var query = _client.from(SupabaseConfig.viewExtratoMotorista).select();

      if (type != null && type.isNotEmpty && type != 'all') {
        query = query.eq('tipo', type);
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        query = query.eq('status', status);
      }
      if (driverId != null && driverId.isNotEmpty && _isValidUuid(driverId)) {
        query = query.eq('motorista_id', driverId);
      }
      if (vehicleId != null && vehicleId.isNotEmpty && _isValidUuid(vehicleId)) {
        query = query.eq('veiculo_id', vehicleId);
      }

      final response = await query.order('data_vencimento', ascending: false);
      return (response as List)
          .map((f) => FinancialEntry.fromMap(Map<String, dynamic>.from(f as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Obter lançamento por ID
  Future<FinancialEntry?> getFinancialEntryById(String id) async {
    final response = await _client
        .from(SupabaseConfig.viewExtratoMotorista)
        .select()
        .eq('lancamento_id', id)
        .maybeSingle();

    if (response == null) return null;
    return FinancialEntry.fromMap(Map<String, dynamic>.from(response));
  }

  /// Registrar novo lançamento de receita ou despesa manual (Função de Caixa)
  Future<FinancialEntry> createFinancialEntry(FinancialEntry entry) async {
    final payload = entry.toDatabaseMap();
    payload.remove('id');

    final response = await _client
        .from(SupabaseConfig.tabelaLancamentosFinanceiros)
        .insert(payload)
        .select()
        .single();

    return FinancialEntry.fromMap(response);
  }

  /// Baixa manual de recebimento / pagamento
  Future<void> markAsPaid(
    String entryId, {
    DateTime? paymentDate,
    String? paymentMethod,
    String? receiptUrl,
  }) async {
    final payload = <String, dynamic>{
      'status': 'pago',
      'data_pagamento': (paymentDate ?? DateTime.now()).toIso8601String().split('T')[0],
    };
    if (paymentMethod != null) payload['metodo_pagamento'] = paymentMethod;
    if (receiptUrl != null) payload['comprovante_url'] = receiptUrl;

    await _client
        .from(SupabaseConfig.tabelaLancamentosFinanceiros)
        .update(payload)
        .eq('id', entryId);
  }

  /// Obter KPIs agregados do Dashboard Master em uma única query otimizada
  Future<Map<String, dynamic>> getDashboardKpis() async {
    final response = await _client
        .from(SupabaseConfig.viewKpisDashboard)
        .select()
        .maybeSingle();

    if (response == null) {
      return {
        'total_veiculos': 0,
        'veiculos_alugados': 0,
        'veiculos_disponiveis': 0,
        'veiculos_manutencao': 0,
        'taxa_ocupacao_percentual': 0.0,
        'motoristas_ativos': 0,
        'motoristas_pendentes': 0,
        'receita_mes_atual': 0.0,
        'despesa_mes_atual': 0.0,
        'total_inadimplencia': 0.0,
      };
    }

    return Map<String, dynamic>.from(response);
  }

  /// Obter categorias contábeis ativas do banco
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    final response = await _client
        .from(SupabaseConfig.tabelaCategoriasDespesa)
        .select()
        .eq('ativo', true)
        .order('codigo_contabil');

    return (response as List)
        .map((c) => ExpenseCategory.fromMap(Map<String, dynamic>.from(c as Map)))
        .toList();
  }

  /// Upload de comprovante de pagamento no Storage
  Future<String> uploadPaymentReceipt({
    required String entryId,
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) async {
    final path = '$entryId/comprovante_$fileName';

    await _client.storage
        .from(SupabaseConfig.bucketComprovantesPagamento)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    final signedUrl = await _client.storage
        .from(SupabaseConfig.bucketComprovantesPagamento)
        .createSignedUrl(path, 60 * 60 * 24 * 365);

    await markAsPaid(entryId, receiptUrl: signedUrl);

    return signedUrl;
  }
}
