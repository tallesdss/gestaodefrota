import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/financial_entry.dart';
import '../../models/expense_category.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para o Módulo Financeiro, Caixa e KPIs no Supabase
class FinancialRepository {
  final SupabaseClient _client;

  FinancialRepository({SupabaseClient? client}) : _client = client ?? supabase;

  static final ValueNotifier<int> entriesChangedNotifier = ValueNotifier<int>(0);

  bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    return RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(str);
  }

  static final Map<String, List<FinancialEntry>> _memoryEntries = {};

  /// Listar lançamentos financeiros usando a view relacional `vw_extrato_completo_motorista`
  Future<List<FinancialEntry>> getFinancialEntries({
    String? type, // 'receita', 'despesa'
    String? status, // 'pago', 'pendente', 'atrasado'
    String? driverId,
    String? vehicleId,
  }) async {
    List<FinancialEntry> results = [];
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

      final response = await query.order('data_vencimento', ascending: true);
      results = (response as List)
          .map((f) => FinancialEntry.fromMap(Map<String, dynamic>.from(f as Map)))
          .toList();
    } catch (_) {
      results = [];
    }

    // Se a view não retornou registros, busca diretamente da tabela de lançamentos no Supabase
    if (results.isEmpty) {
      try {
        var query = _client.from(SupabaseConfig.tabelaLancamentosFinanceiros).select();
        if (driverId != null && driverId.isNotEmpty && _isValidUuid(driverId)) {
          query = query.eq('motorista_id', driverId);
        }
        if (vehicleId != null && vehicleId.isNotEmpty && _isValidUuid(vehicleId)) {
          query = query.eq('veiculo_id', vehicleId);
        }
        if (status != null && status.isNotEmpty && status != 'all') {
          query = query.eq('status', status);
        }
        final response = await query.order('data_vencimento', ascending: true);
        results = (response as List)
            .map((f) => FinancialEntry.fromMap(Map<String, dynamic>.from(f as Map)))
            .toList();
      } catch (_) {}
    }

    if (results.isEmpty && driverId != null && _memoryEntries.containsKey(driverId)) {
      results = List<FinancialEntry>.from(_memoryEntries[driverId]!);
    }

    return results;
  }

  /// Retorna o lucro líquido de um veículo através da view vw_lucro_veiculo
  Future<double> getVehicleProfit(String vehicleId) async {
    try {
      if (!_isValidUuid(vehicleId)) return 0.0;
      final response = await _client
          .from('vw_lucro_veiculo')
          .select('lucro_liquido')
          .eq('veiculo_id', vehicleId)
          .maybeSingle();

      if (response != null && response['lucro_liquido'] != null) {
        return (response['lucro_liquido'] as num).toDouble();
      }
    } catch (_) {}
    return 0.0;
  }

  /// Obter lançamento por ID
  Future<FinancialEntry?> getFinancialEntryById(String id) async {
    for (final list in _memoryEntries.values) {
      final found = list.where((e) => e.id == id).toList();
      if (found.isNotEmpty) return found.first;
    }

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

  /// Atualizar lançamento financeiro existente
  Future<FinancialEntry> updateFinancialEntry(FinancialEntry entry) async {
    final payload = entry.toDatabaseMap();
    final entryId = payload.remove('id'); 

    final response = await _client
        .from(SupabaseConfig.tabelaLancamentosFinanceiros)
        .update(payload)
        .eq('id', entryId)
        .select()
        .single();

    final updatedEntry = FinancialEntry.fromMap(response);

    // Atualiza memória se existir
    for (final key in _memoryEntries.keys) {
      final list = _memoryEntries[key]!;
      final idx = list.indexWhere((e) => e.id == entry.id);
      if (idx != -1) {
        list[idx] = updatedEntry;
      }
    }
    
    entriesChangedNotifier.value++;
    return updatedEntry;
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

    try {
      if (_isValidUuid(entryId)) {
        await _client
            .from(SupabaseConfig.tabelaLancamentosFinanceiros)
            .update(payload)
            .eq('id', entryId);
      }
    } catch (_) {}

    // Atualiza memória
    for (final key in _memoryEntries.keys) {
      _memoryEntries[key] = _memoryEntries[key]!.map((e) {
        if (e.id == entryId) {
          return e.copyWith(
            isPaid: true,
            isLate: false,
            paymentDate: paymentDate ?? DateTime.now(),
            paymentMethod: paymentMethod ?? 'pix',
            receiptUrl: receiptUrl ?? e.receiptUrl,
          );
        }
        return e;
      }).toList();
    }

    entriesChangedNotifier.value++;
  }

  /// Baixa em lote de múltiplos lançamentos (Pagar Tudo de uma Vez)
  Future<void> markBatchAsPaid(
    List<String> entryIds, {
    DateTime? paymentDate,
    String? paymentMethod,
    String? receiptUrl,
  }) async {
    for (final id in entryIds) {
      await markAsPaid(
        id,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
        receiptUrl: receiptUrl,
      );
    }
    entriesChangedNotifier.value++;
  }

  /// Gerar histórico de parcelas de aluguel para o motorista de acordo com o prazo e ciclo
  Future<List<FinancialEntry>> generateContractInstallments({
    required String driverId,
    required String vehicleId,
    String? contractId,
    required double rentalValue,
    required String frequency, // 'semanal' ou 'mensal'
    required int dueDay, // 1-7 para semanal, 1-31 para mensal
    required DateTime startDate,
    int? durationWeeks, // ex: 4, 8, 12, 24, 48
    int? durationMonths, // ex: 1, 3, 6, 12, 24
    DateTime? endDate,
    bool persistToDb = true,
  }) async {
    final List<FinancialEntry> installments = [];
    final isWeekly = frequency.toLowerCase() == 'semanal';
    final isBiweekly = frequency.toLowerCase() == 'quinzenal';

    final totalCount = isWeekly
        ? (durationWeeks ?? (endDate != null ? (endDate.difference(startDate).inDays / 7).ceil().clamp(1, 104) : 12))
        : isBiweekly
            ? (durationWeeks != null ? (durationWeeks / 2).ceil() : (endDate != null ? (endDate.difference(startDate).inDays / 14).ceil().clamp(1, 52) : 6))
            : (durationMonths ?? (endDate != null ? ((endDate.year - startDate.year) * 12 + endDate.month - startDate.month).clamp(1, 36) : 6));

    DateTime currentDue = startDate;

    if (isWeekly || isBiweekly) {
      // Ajusta para o próximo dia da semana correspondente ao dueDay (1=Segunda, 7=Domingo)
      int targetWeekday = dueDay.clamp(1, 7);
      while (currentDue.weekday != targetWeekday) {
        currentDue = currentDue.add(const Duration(days: 1));
      }
    } else {
      // Mensal: ajusta dia do mês
      int targetDay = dueDay.clamp(1, 28);
      currentDue = DateTime(currentDue.year, currentDue.month, targetDay);
      if (currentDue.isBefore(startDate)) {
        currentDue = DateTime(currentDue.year, currentDue.month + 1, targetDay);
      }
    }

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (int i = 1; i <= totalCount; i++) {
      final dueDateOnly = DateTime(currentDue.year, currentDue.month, currentDue.day);
      final isLate = dueDateOnly.isBefore(today);
      final entryId = 'fin-inst-${driverId.substring(0, driverId.length > 8 ? 8 : driverId.length)}-$i';

      final title = isWeekly
          ? 'Aluguel Semanal - Parcela $i/$totalCount'
          : isBiweekly
              ? 'Aluguel Quinzenal - Parcela $i/$totalCount'
              : 'Aluguel Mensal - Parcela $i/$totalCount';

      final entry = FinancialEntry(
        id: entryId,
        type: FinancialType.income,
        category: 'Aluguel / Locação',
        categoryId: '10000000-0000-0000-0000-000000000002',
        contractId: contractId,
        vehicleId: vehicleId,
        driverId: driverId,
        amount: rentalValue,
        date: dueDateOnly,
        description: title,
        isPaid: false,
        isLate: isLate,
        paymentMethod: 'pix',
      );

      installments.add(entry);

      if (isWeekly) {
        currentDue = currentDue.add(const Duration(days: 7));
      } else if (isBiweekly) {
        currentDue = currentDue.add(const Duration(days: 14));
      } else {
        currentDue = DateTime(currentDue.year, currentDue.month + 1, currentDue.day);
      }
    }

    _memoryEntries[driverId] = installments;

    if (persistToDb && _isValidUuid(driverId)) {
      try {
        for (final item in installments) {
          final dbMap = item.toDatabaseMap();
          dbMap.remove('id');
          await _client.from(SupabaseConfig.tabelaLancamentosFinanceiros).insert(dbMap);
        }
      } catch (_) {}
    }

    entriesChangedNotifier.value++;

    return installments;
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
    final path = '$entryId/comprovante_${DateTime.now().millisecondsSinceEpoch}_$fileName';

    try {
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
    } catch (_) {
      // Fallback local se o storage do browser/mock estiver ativo
      final fakeUrl = 'https://supabase.local/storage/$path';
      await markAsPaid(entryId, receiptUrl: fakeUrl);
      return fakeUrl;
    }
  }

  /// Upload de comprovante em lote para quitação total de parcelas
  Future<String> uploadBatchPaymentReceipt({
    required List<String> entryIds,
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) async {
    final firstId = entryIds.isNotEmpty ? entryIds.first : 'batch';
    final path = 'batch_$firstId/comprovante_${DateTime.now().millisecondsSinceEpoch}_$fileName';

    try {
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

      await markBatchAsPaid(entryIds, receiptUrl: signedUrl);
      return signedUrl;
    } catch (_) {
      final fakeUrl = 'https://supabase.local/storage/$path';
      await markBatchAsPaid(entryIds, receiptUrl: fakeUrl);
      return fakeUrl;
    }
  }
}
