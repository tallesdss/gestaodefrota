import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/vehicle.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para o Módulo de Frota e Veículos no Supabase
class VehicleRepository {
  final SupabaseClient _client;

  VehicleRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Listar veículos com filtros de status e busca textual
  Future<List<Vehicle>> getVehicles({String? status, String? search}) async {
    var query = _client.from(SupabaseConfig.tabelaVeiculos).select('''
      *,
      contratos (
        id,
        numero_contrato,
        status,
        motorista_id,
        motoristas (
          id,
          perfis (nome)
        )
      )
    ''');

    if (status != null && status.isNotEmpty && status != 'all' && status != 'todos') {
      String statusDb = status.toLowerCase();
      if (statusDb == 'livres' || statusDb == 'available') statusDb = 'disponivel';
      if (statusDb == 'alugados' || statusDb == 'rented') statusDb = 'alugado';
      if (statusDb == 'manutencao' || statusDb == 'maintenance') statusDb = 'manutencao';
      query = query.eq('status', statusDb);
    }

    if (search != null && search.trim().isNotEmpty) {
      final s = search.trim();
      query = query.or('placa.ilike.%$s%,modelo.ilike.%$s%,marca.ilike.%$s%');
    }

    final response = await query.order('criado_em', ascending: false);

    return (response as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);

      // Extrair motorista atual do contrato ativo
      if (map['contratos'] is List && (map['contratos'] as List).isNotEmpty) {
        final activeContracts = (map['contratos'] as List)
            .where((c) => c['status'] == 'ativo')
            .toList();
        if (activeContracts.isNotEmpty) {
          final c = activeContracts.first;
          map['motorista_atual_id'] = c['motorista_id'];
          if (c['motoristas'] != null && c['motoristas']['perfis'] != null) {
            map['motorista_atual_nome'] = c['motoristas']['perfis']['nome'];
          }
        }
      }

      return Vehicle.fromMap(map);
    }).toList();
  }

  /// Obter dados detalhados de um veículo por ID
  Future<Vehicle?> getVehicleById(String id) async {
    final response = await _client
        .from(SupabaseConfig.tabelaVeiculos)
        .select('''
          *,
          contratos (
            id,
            numero_contrato,
            status,
            motorista_id,
            motoristas (
              id,
              perfis (nome)
            )
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    final map = Map<String, dynamic>.from(response);
    if (map['contratos'] is List && (map['contratos'] as List).isNotEmpty) {
      final activeContracts = (map['contratos'] as List)
          .where((c) => c['status'] == 'ativo')
          .toList();
      if (activeContracts.isNotEmpty) {
        final c = activeContracts.first;
        map['motorista_atual_id'] = c['motorista_id'];
        if (c['motoristas'] != null && c['motoristas']['perfis'] != null) {
          map['motorista_atual_nome'] = c['motoristas']['perfis']['nome'];
        }
      }
    }

    return Vehicle.fromMap(map);
  }

  /// Criar novo veículo no banco
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final payload = vehicle.toDatabaseMap();
    payload.remove('id'); // Deixar o PostgreSQL gerar UUID v4

    final response = await _client
        .from(SupabaseConfig.tabelaVeiculos)
        .insert(payload)
        .select()
        .single();

    return Vehicle.fromMap(response);
  }

  /// Atualizar veículo existente
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    final payload = vehicle.toDatabaseMap();
    final vehicleId = vehicle.id;

    final response = await _client
        .from(SupabaseConfig.tabelaVeiculos)
        .update(payload)
        .eq('id', vehicleId)
        .select()
        .single();

    return Vehicle.fromMap(response);
  }

  /// Inativar ou remover veículo
  Future<void> deleteVehicle(String id) async {
    await _client
        .from(SupabaseConfig.tabelaVeiculos)
        .update({'status': 'inativo'})
        .eq('id', id);
  }

  /// Vincular motorista a um veículo criando contrato ativo e sincronizando status
  Future<void> assignDriverToVehicle({
    required String vehicleId,
    required String driverId,
    double? rentalValue,
  }) async {
    final nowStr = DateTime.now().toIso8601String();
    final todayStr = nowStr.split('T')[0];

    // 1. Concluir quaisquer contratos ativos anteriores desse veículo
    await _client
        .from(SupabaseConfig.tabelaContratos)
        .update({
          'status': 'concluido',
          'data_fim': todayStr,
          'atualizado_em': nowStr,
        })
        .eq('veiculo_id', vehicleId)
        .eq('status', 'ativo');

    // 2. Concluir quaisquer contratos ativos anteriores desse motorista
    await _client
        .from(SupabaseConfig.tabelaContratos)
        .update({
          'status': 'concluido',
          'data_fim': todayStr,
          'atualizado_em': nowStr,
        })
        .eq('motorista_id', driverId)
        .eq('status', 'ativo');

    // 3. Inserir novo contrato ativo no Supabase
    final contractNumber = 'CTR-${DateTime.now().millisecondsSinceEpoch}';
    final valor = (rentalValue != null && rentalValue > 0) ? rentalValue : 500.00;

    await _client.from(SupabaseConfig.tabelaContratos).insert({
      'numero_contrato': contractNumber,
      'motorista_id': driverId,
      'veiculo_id': vehicleId,
      'data_inicio': todayStr,
      'valor_locacao': valor,
      'valor_caucao': 0.00,
      'frequencia_cobranca': 'semanal',
      'dia_vencimento': 5,
      'status': 'ativo',
    });

    // 4. Atualizar status do veículo para 'alugado'
    await _client
        .from(SupabaseConfig.tabelaVeiculos)
        .update({
          'status': 'alugado',
          'atualizado_em': nowStr,
        })
        .eq('id', vehicleId);

    // 5. Registrar no histórico de atividades
    try {
      await _client.from(SupabaseConfig.tabelaHistoricoAtividades).insert({
        'motorista_id': driverId,
        'tipo': 'veiculo_vinculado',
        'descricao': 'Veículo vinculado ao motorista (Contrato $contractNumber)',
        'criado_em': nowStr,
      });
    } catch (_) {}
  }

  /// Desvincular motorista tornando o veículo disponível / livre
  Future<void> unlinkDriverFromVehicle(
    String vehicleId, {
    String? previousDriverId,
  }) async {
    final nowStr = DateTime.now().toIso8601String();
    final todayStr = nowStr.split('T')[0];

    // 1. Concluir contrato ativo do veículo
    await _client
        .from(SupabaseConfig.tabelaContratos)
        .update({
          'status': 'concluido',
          'data_fim': todayStr,
          'atualizado_em': nowStr,
        })
        .eq('veiculo_id', vehicleId)
        .eq('status', 'ativo');

    // 2. Atualizar veículo para 'disponivel'
    await _client
        .from(SupabaseConfig.tabelaVeiculos)
        .update({
          'status': 'disponivel',
          'atualizado_em': nowStr,
        })
        .eq('id', vehicleId);

    // 3. Registrar no histórico de atividades se havia motorista anterior
    if (previousDriverId != null && previousDriverId.isNotEmpty) {
      try {
        await _client.from(SupabaseConfig.tabelaHistoricoAtividades).insert({
          'motorista_id': previousDriverId,
          'tipo': 'veiculo_desvinculado',
          'descricao': 'Veículo desvinculado da posse do motorista.',
          'criado_em': nowStr,
        });
      } catch (_) {}
    }
  }

  /// Colocar veículo em manutenção e encerrar vínculos ativos
  Future<void> setVehicleMaintenance(
    String vehicleId, {
    String? previousDriverId,
  }) async {
    final nowStr = DateTime.now().toIso8601String();
    final todayStr = nowStr.split('T')[0];

    // 1. Concluir contratos ativos
    await _client
        .from(SupabaseConfig.tabelaContratos)
        .update({
          'status': 'concluido',
          'data_fim': todayStr,
          'atualizado_em': nowStr,
        })
        .eq('veiculo_id', vehicleId)
        .eq('status', 'ativo');

    // 2. Atualizar veículo para 'manutencao'
    await _client
        .from(SupabaseConfig.tabelaVeiculos)
        .update({
          'status': 'manutencao',
          'atualizado_em': nowStr,
        })
        .eq('id', vehicleId);

    // 3. Registrar no histórico
    if (previousDriverId != null && previousDriverId.isNotEmpty) {
      try {
        await _client.from(SupabaseConfig.tabelaHistoricoAtividades).insert({
          'motorista_id': previousDriverId,
          'tipo': 'veiculo_desvinculado',
          'descricao': 'Veículo encaminhado para manutenção.',
          'criado_em': nowStr,
        });
      } catch (_) {}
    }
  }

  /// Upload de documento do veículo para o Supabase Storage
  Future<String> uploadVehicleDocument({
    required String vehicleId,
    required String fileName,
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
  }) async {
    final path = 'veiculo_$vehicleId/$fileName';

    await _client.storage
        .from(SupabaseConfig.bucketDocumentosVeiculos)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    final publicUrl = _client.storage
        .from(SupabaseConfig.bucketDocumentosVeiculos)
        .getPublicUrl(path);

    return publicUrl;
  }
}
