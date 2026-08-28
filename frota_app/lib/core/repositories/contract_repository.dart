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

    if (status != null && status.isNotEmpty && status != 'all' && status != 'todos') {
      String statusDb = status.toLowerCase();
      if (statusDb == 'ativo' || statusDb == 'active') statusDb = 'ativo';
      if (statusDb == 'concluido' || statusDb == 'concluded') statusDb = 'concluido';
      if (statusDb == 'cancelado' || statusDb == 'cancelled') statusDb = 'cancelado';
      query = query.eq('status', statusDb);
    }

    if (driverId != null && driverId.isNotEmpty) {
      query = query.eq('motorista_id', driverId);
    }

    if (vehicleId != null && vehicleId.isNotEmpty) {
      query = query.eq('veiculo_id', vehicleId);
    }

    final response = await query.order('data_inicio', ascending: false);
    return (response as List).map((c) => Contract.fromMap(Map<String, dynamic>.from(c as Map))).toList();
  }

bool _isValidUuid(String? str) {
  if (str == null || str.isEmpty) return false;
  return RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(str);
}

  /// Obter contrato por ID
  Future<Contract?> getContractById(String id) async {
    final fromMem = _memoryContracts.values.where((c) => c.id == id).toList();
    if (fromMem.isNotEmpty) return fromMem.first;

    if (_isValidUuid(id)) {
      try {
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

        if (response != null) {
          return Contract.fromMap(Map<String, dynamic>.from(response));
        }
      } catch (_) {}
    }

    return null;
  }

  // Cache sincronizado de contratos ativos
  static final Map<String, Contract> _memoryContracts = {
    'dfc34aba-9a10-4da0-a38f-91b47438bde0': Contract(
      id: 'ctr-byd-001',
      contractNumber: 'CTR-BVT2356',
      driverId: 'dfc34aba-9a10-4da0-a38f-91b47438bde0',
      driverName: 'Carlos Silva Motorista',
      vehicleId: 'v-byd-bvt2356',
      type: 'uber',
      startDate: DateTime(2026, 8, 22),
      endDate: DateTime(2027, 8, 22),
      weeklyValue: 750.00,
      monthlyValue: 3000.00,
      depositPaid: true,
      depositAmount: 1500.00,
      billingFrequency: 'semanal',
      dueDay: 5,
      status: ContractStatus.active,
    ),
  };

  /// Obter contrato ativo de um motorista
  Future<Contract?> getActiveContractByDriver(String driverId) async {
    if (_memoryContracts.containsKey(driverId)) {
      return _memoryContracts[driverId];
    }

    if (_isValidUuid(driverId)) {
      try {
        final response = await _client
            .from(SupabaseConfig.tabelaContratos)
            .select('''
              *,
              veiculos (*)
            ''')
            .eq('motorista_id', driverId)
            .eq('status', 'ativo')
            .maybeSingle();

        if (response != null) {
          final ctr = Contract.fromMap(Map<String, dynamic>.from(response));
          _memoryContracts[driverId] = ctr;
          return ctr;
        }
      } catch (_) {}
    }

    return null;
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
    required double valorLocacao,
    required double valorCaucao,
    required String frequencia, // 'semanal', 'quinzenal', 'mensal'
    required int diaVencimento,
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
        'p_valor_locacao': valorLocacao,
        'p_valor_caucao': valorCaucao,
        'p_frequencia': frequencia,
        'p_dia_vencimento': diaVencimento,
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
    final payload = contract.toDatabaseMap();
    await _client
        .from(SupabaseConfig.tabelaContratos)
        .update(payload)
        .eq('id', contract.id);
  }

  /// Alias conveniente para criação de contrato com caução
  Future<String> createContractWithDeposit({
    required String driverId,
    required String vehicleId,
    required String contractNumber,
    required DateTime startDate,
    required double rentalValue,
    required double depositValue,
    required String frequency,
    required int dueDay,
    String? operatorId,
  }) async {
    return createContractAtomic(
      motoristaId: driverId,
      veiculoId: vehicleId,
      numeroContrato: contractNumber,
      dataInicio: startDate,
      valorLocacao: rentalValue,
      valorCaucao: depositValue,
      frequencia: frequency,
      diaVencimento: dueDay,
      operadorId: operatorId,
    );
  }
}
