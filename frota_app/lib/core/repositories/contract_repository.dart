import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/contract.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para o Módulo de Contratos de Locação no Supabase
class ContractRepository {
  final SupabaseClient _client;

  ContractRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Listar contratos com filtros
  Future<List<Contract>> getContracts({
    String? status,
    String? driverId,
    String? vehicleId,
  }) async {
    var query = _client.from(SupabaseConfig.tabelaContratos).select('''
      *,
      motoristas (
        id,
        perfis (nome)
      ),
      veiculos (
        id,
        placa,
        modelo
      )
    ''');

    if (status != null &&
        status.isNotEmpty &&
        status != 'all' &&
        status != 'todos') {
      String statusDb = status.toLowerCase();
      if (statusDb == 'ativo' || statusDb == 'active') statusDb = 'ativo';
      if (statusDb == 'concluido' || statusDb == 'concluded') {
        statusDb = 'concluido';
      }
      if (statusDb == 'cancelado' || statusDb == 'cancelled') {
        statusDb = 'cancelado';
      }
      query = query.eq('status', statusDb);
    }

    if (driverId != null && driverId.isNotEmpty) {
      query = query.eq('motorista_id', driverId);
    }

    if (vehicleId != null && vehicleId.isNotEmpty) {
      query = query.eq('veiculo_id', vehicleId);
    }

    final response = await query.order('data_inicio', ascending: false);
    return (response as List)
        .map((c) => Contract.fromMap(Map<String, dynamic>.from(c as Map)))
        .toList();
  }

  bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(str);
  }

  /// Obter contrato por ID
  Future<Contract?> getContractById(String id) async {
    if (!_isValidUuid(id)) return null;

    final response = await _client
        .from(SupabaseConfig.tabelaContratos)
        .select('''
          *,
          motoristas (
            id,
            perfis (nome)
          ),
          veiculos (
            id,
            placa,
            modelo
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Contract.fromMap(Map<String, dynamic>.from(response));
  }

  /// Obter contrato ativo de um motorista
  Future<Contract?> getActiveContractByDriver(String driverId) async {
    if (!_isValidUuid(driverId)) return null;

    final response = await _client
        .from(SupabaseConfig.tabelaContratos)
        .select('''
          *,
          veiculos (*)
        ''')
        .eq('motorista_id', driverId)
        .eq('status', 'ativo')
        .maybeSingle();

    if (response == null) return null;
    return Contract.fromMap(Map<String, dynamic>.from(response));
  }

  /// Obter contrato ativo de um veículo
  Future<Contract?> getActiveContractByVehicle(String vehicleId) async {
    final response = await _client
        .from(SupabaseConfig.tabelaContratos)
        .select('''
          *,
          motoristas (
            id,
            perfis (nome)
          )
        ''')
        .eq('veiculo_id', vehicleId)
        .eq('status', 'ativo')
        .maybeSingle();

    if (response == null) return null;
    return Contract.fromMap(Map<String, dynamic>.from(response));
  }

  /// Criação atômica e transacional de contrato via RPC (ACID)
  Future<String> createContractAtomic({
    required String motoristaId,
    required String veiculoId,
    required String numeroContrato,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    required double valorCaucao,
    required String frequencia, // 'semanal', 'quinzenal', 'mensal'
    required int diaVencimento,
    double discountPercentage = 0,
    String? discountReason,
    String categoriaReceitaId = '10000000-0000-0000-0000-000000000002',
    String? operadorId,
  }) async {
    final opId = operadorId ?? SupabaseConfig.currentUserId ?? motoristaId;

    final response = await _client.rpc(
      SupabaseConfig.rpcCriarContratoLocacao,
      params: {
        'p_motorista_id': motoristaId,
        'p_veiculo_id': veiculoId,
        'p_numero_contrato': numeroContrato,
        'p_data_inicio': dataInicio.toIso8601String().split('T')[0],
        'p_data_fim': dataFim.toIso8601String().split('T')[0],
        'p_valor_locacao': valorLocacao,
        'p_valor_caucao': valorCaucao,
        'p_frequencia': frequencia,
        'p_dia_vencimento': diaVencimento,
        'p_desconto_percentual': discountPercentage,
        'p_motivo_desconto': discountReason,
        'p_categoria_receita_id': categoriaReceitaId,
        'p_operador_id': opId,
      },
    );

    return response.toString();
  }

  /// Criar contrato padrão
  Future<Contract> createContract(Contract contract) async {
    final payload = contract.toDatabaseMap();
    payload.remove('id');

    final response = await _client
        .from(SupabaseConfig.tabelaContratos)
        .insert(payload)
        .select()
        .single();

    return Contract.fromMap(response);
  }

  /// Concluir/Encerrar contrato
  Future<void> concludeContract(String contractId) async {
    await _client
        .from(SupabaseConfig.tabelaContratos)
        .update({'status': 'concluido'})
        .eq('id', contractId);

    // [GES-02] Calcular comissão para o gestor atual se houver
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;

    try {
      final gestorRes = await _client
          .from(SupabaseConfig.tabelaGestores)
          .select('percentual_comissao')
          .eq('id', userId)
          .maybeSingle();

      if (gestorRes == null) return; // Não é gestor

      final percentual = (gestorRes['percentual_comissao'] as num).toDouble();
      if (percentual <= 0) return;

      // Somar receita do contrato
      final financeiroRes = await _client
          .from(SupabaseConfig.tabelaLancamentosFinanceiros)
          .select('valor')
          .eq('contrato_id', contractId)
          .eq('status', 'pago')
          .eq('tipo', 'receita');

      double totalReceita = 0;
      for (var row in financeiroRes as List) {
        totalReceita += (row['valor'] as num).toDouble();
      }

      if (totalReceita <= 0) return;

      final comissao = totalReceita * (percentual / 100);

      // Registrar em pagamentos_gestores para o mês atual
      final now = DateTime.now();
      final mesReferencia =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final paymentRes = await _client
          .from(SupabaseConfig.tabelaPagamentosGestores)
          .select()
          .eq('gestor_id', userId)
          .eq('mes_referencia', mesReferencia)
          .maybeSingle();

      if (paymentRes != null) {
        final currentComissao = (paymentRes['valor_comissao'] as num)
            .toDouble();
        await _client
            .from(SupabaseConfig.tabelaPagamentosGestores)
            .update({'valor_comissao': currentComissao + comissao})
            .eq('id', paymentRes['id']);
      } else {
        await _client.from(SupabaseConfig.tabelaPagamentosGestores).insert({
          'gestor_id': userId,
          'valor_salario': 0.0,
          'valor_comissao': comissao,
          'mes_referencia': mesReferencia,
        });
      }
    } catch (e) {
      debugPrint('Erro ao calcular comissão: $e');
    }
  }

  /// Cancelar contrato
  Future<void> cancelContract(String contractId) async {
    await _client
        .from(SupabaseConfig.tabelaContratos)
        .update({'status': 'cancelado'})
        .eq('id', contractId);
  }

  /// Atualizar contrato
  Future<void> updateContract(Contract contract) async {
    final current = await getContractById(contract.id);
    if (current == null) {
      throw StateError('Contrato não encontrado.');
    }
    if (current.driverId != contract.driverId ||
        current.vehicleId != contract.vehicleId) {
      throw StateError(
        'A atribuição de motorista e veículo não pode ser alterada editando o contrato.',
      );
    }

    if (contract.status == ContractStatus.concluded) {
      await concludeContract(contract.id);
      return;
    }
    if (contract.status == ContractStatus.cancelled) {
      await cancelContract(contract.id);
      return;
    }
    if (contract.status != ContractStatus.active) {
      throw StateError('Status de contrato inválido para edição.');
    }

    final frequency = contract.billingFrequency ?? 'semanal';
    if (current.billingStartedAt != null) {
      final currentFrequency = current.billingFrequency ?? 'semanal';
      final currentRentalValue = currentFrequency == 'semanal'
          ? current.weeklyValue
          : current.monthlyValue;
      final newRentalValue = frequency == 'semanal'
          ? contract.weeklyValue
          : (frequency == 'quinzenal'
                ? contract.weeklyValue * 2
                : contract.monthlyValue);
      bool isSameDate(DateTime a, DateTime b) =>
          a.year == b.year && a.month == b.month && a.day == b.day;

      if (frequency != currentFrequency ||
          (newRentalValue - currentRentalValue).abs() >= 0.01 ||
          contract.dueDay != current.dueDay ||
          !isSameDate(contract.endDate, current.endDate)) {
        throw StateError(
          'A cobrança já começou. Valor, frequência, vencimento e vigência não podem ser alterados por esta tela.',
        );
      }

      if (contract.discountPercentage != current.discountPercentage ||
          contract.discountReason != current.discountReason) {
        await applyRecurringDiscount(
          contractId: contract.id,
          discountPercentage: contract.discountPercentage,
          discountReason: contract.discountReason,
        );
      }
      return;
    }

    await updateTermsBeforeCheckInApproval(
      contractId: contract.id,
      rentalValue: frequency == 'semanal'
          ? contract.weeklyValue
          : (frequency == 'quinzenal'
                ? contract.weeklyValue * 2
                : contract.monthlyValue),
      frequency: frequency,
      dueDay: contract.dueDay ?? contract.startDate.day,
      endDate: contract.endDate,
      discountPercentage: contract.discountPercentage,
      discountReason: contract.discountReason,
    );
  }

  Future<void> applyRecurringDiscount({
    required String contractId,
    required double discountPercentage,
    String? discountReason,
  }) async {
    await _client.rpc(
      'fn_aplicar_desconto_contrato_recorrente',
      params: {
        'p_contrato_id': contractId,
        'p_desconto_percentual': discountPercentage,
        'p_motivo_desconto': discountReason,
      },
    );
  }

  Future<void> updateTermsBeforeCheckInApproval({
    required String contractId,
    required double rentalValue,
    required String frequency,
    required int dueDay,
    required DateTime endDate,
    double discountPercentage = 0,
    String? discountReason,
  }) async {
    await _client.rpc(
      'fn_atualizar_termos_contrato_antes_vistoria',
      params: {
        'p_contrato_id': contractId,
        'p_valor_locacao': rentalValue,
        'p_frequencia': frequency,
        'p_dia_vencimento': dueDay,
        'p_data_fim': endDate.toIso8601String().split('T')[0],
        'p_desconto_percentual': discountPercentage,
        'p_motivo_desconto': discountReason,
      },
    );
  }

  /// Alias conveniente para criação de contrato com caução
  Future<String> createContractWithDeposit({
    required String driverId,
    required String vehicleId,
    required String contractNumber,
    required DateTime startDate,
    required DateTime endDate,
    required double rentalValue,
    required double depositValue,
    required String frequency,
    required int dueDay,
    double discountPercentage = 0,
    String? discountReason,
    String? operatorId,
  }) async {
    return createContractAtomic(
      motoristaId: driverId,
      veiculoId: vehicleId,
      numeroContrato: contractNumber,
      dataInicio: startDate,
      dataFim: endDate,
      valorLocacao: rentalValue,
      valorCaucao: depositValue,
      frequencia: frequency,
      diaVencimento: dueDay,
      discountPercentage: discountPercentage,
      discountReason: discountReason,
      operadorId: operatorId,
    );
  }
}
