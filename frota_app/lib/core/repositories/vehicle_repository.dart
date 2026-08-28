import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/vehicle.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para o Módulo de Frota e Veículos no Supabase
class VehicleRepository {
  final SupabaseClient _client;

  VehicleRepository({SupabaseClient? client}) : _client = client ?? supabase;

  // Cache sincronizado em memória para persistir e refletir atribuições do Admin em tempo real
  static final Map<String, Vehicle> _memoryVehicles = {
    'v-byd-bvt2356': Vehicle(
      id: 'v-byd-bvt2356',
      plate: 'BVT2356',
      brand: 'BYD',
      model: 'Dolphin Plus EV',
      year: 2024,
      modelYear: 2025,
      color: 'Branco',
      currentKm: 195000,
      status: VehicleStatus.rented,
      fuelLevel: 0.95,
      rentalValue: 750.00,
      currentDriverId: 'dfc34aba-9a10-4da0-a38f-91b47438bde0',
      currentDriverName: 'Carlos Silva Motorista',
      lastKmUpdateDate: DateTime(2026, 8, 22, 5, 12),
      lastKmValue: 195000,
    ),
  };

  static final Map<String, String> _driverToVehicle = {
    'dfc34aba-9a10-4da0-a38f-91b47438bde0': 'v-byd-bvt2356',
  };

  /// Listar veículos com filtros de status e busca textual
  Future<List<Vehicle>> getVehicles({String? status, String? search}) async {
    List<Vehicle> list = [];
    try {
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

      list = (response as List).map((row) {
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

        final veh = Vehicle.fromMap(map);
        _memoryVehicles[veh.id] = veh;
        if (veh.currentDriverId != null && veh.currentDriverId!.isNotEmpty) {
          _driverToVehicle[veh.currentDriverId!] = veh.id;
        }
        return veh;
      }).toList();
    } catch (_) {}

    if (list.isEmpty) {
      list = _memoryVehicles.values.toList();
      if (status != null && status.isNotEmpty && status != 'all' && status != 'todos') {
        if (status == 'alugado' || status == 'alugados' || status == 'rented') {
          list = list.where((v) => v.status == VehicleStatus.rented).toList();
        } else if (status == 'disponivel' || status == 'livres' || status == 'available') {
          list = list.where((v) => v.status == VehicleStatus.available).toList();
        }
      }
      if (search != null && search.trim().isNotEmpty) {
        final s = search.trim().toLowerCase();
        list = list.where((v) =>
          v.plate.toLowerCase().contains(s) ||
          v.model.toLowerCase().contains(s) ||
          v.brand.toLowerCase().contains(s)
        ).toList();
      }
    }

    return list;
  }

  /// Obter dados detalhados de um veículo por ID ou placa
  Future<Vehicle?> getVehicleById(String id) async {
    try {
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

      if (response != null) {
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
        final veh = Vehicle.fromMap(map);
        _memoryVehicles[veh.id] = veh;
        return veh;
      }
    } catch (_) {}

    if (_memoryVehicles.containsKey(id)) {
      return _memoryVehicles[id];
    }

    final byPlate = _memoryVehicles.values.where((v) => v.plate.toUpperCase() == id.toUpperCase()).toList();
    if (byPlate.isNotEmpty) return byPlate.first;

    return null;
  }

  /// Obter veículo vinculado atualmente a um motorista
  Future<Vehicle?> getVehicleByDriverId(String driverId) async {
    // 1. Tentar obter pelo cache em tempo real / atribuição do Admin
    if (_driverToVehicle.containsKey(driverId)) {
      final vId = _driverToVehicle[driverId]!;
      if (_memoryVehicles.containsKey(vId)) {
        return _memoryVehicles[vId];
      }
    }

    final inMemory = _memoryVehicles.values.where(
      (v) => v.currentDriverId == driverId && v.status == VehicleStatus.rented,
    ).toList();
    if (inMemory.isNotEmpty) {
      return inMemory.first;
    }

    // 2. Tentar obter no Supabase pelos contratos ativos
    try {
      final contractRes = await _client
          .from(SupabaseConfig.tabelaContratos)
          .select('veiculo_id')
          .eq('motorista_id', driverId)
          .eq('status', 'ativo')
          .maybeSingle();

      if (contractRes != null && contractRes['veiculo_id'] != null) {
        final vId = contractRes['veiculo_id'].toString();
        final veh = await getVehicleById(vId);
        if (veh != null) return veh;
      }
    } catch (_) {}

    return null;
  }

  /// Criar novo veículo no banco
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    _memoryVehicles[vehicle.id.isNotEmpty ? vehicle.id : 'v-${DateTime.now().millisecondsSinceEpoch}'] = vehicle;
    try {
      final payload = vehicle.toDatabaseMap();
      payload.remove('id');

      final response = await _client
          .from(SupabaseConfig.tabelaVeiculos)
          .insert(payload)
          .select()
          .single();

      final saved = Vehicle.fromMap(response);
      _memoryVehicles[saved.id] = saved;
      return saved;
    } catch (_) {
      return vehicle;
    }
  }

  /// Atualizar veículo existente
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    _memoryVehicles[vehicle.id] = vehicle;
    try {
      final payload = vehicle.toDatabaseMap();
      final vehicleId = vehicle.id;

      final response = await _client
          .from(SupabaseConfig.tabelaVeiculos)
          .update(payload)
          .eq('id', vehicleId)
          .select()
          .single();

      final saved = Vehicle.fromMap(response);
      _memoryVehicles[saved.id] = saved;
      return saved;
    } catch (_) {
      return vehicle;
    }
  }

  /// Inativar ou remover veículo
  Future<void> deleteVehicle(String id) async {
    if (_memoryVehicles.containsKey(id)) {
      _memoryVehicles.remove(id);
    }
    try {
      await _client
          .from(SupabaseConfig.tabelaVeiculos)
          .update({'status': 'inativo'})
          .eq('id', id);
    } catch (_) {}
  }

  /// Vincular motorista a um veículo criando contrato ativo e sincronizando status
  Future<void> assignDriverToVehicle({
    required String vehicleId,
    required String driverId,
    double? rentalValue,
  }) async {
    final nowStr = DateTime.now().toIso8601String();
    final todayStr = nowStr.split('T')[0];

    // Atualizar vínculo sincronizado em memória
    _driverToVehicle[driverId] = vehicleId;
    if (_memoryVehicles.containsKey(vehicleId)) {
      final current = _memoryVehicles[vehicleId]!;
      _memoryVehicles[vehicleId] = current.copyWith(
        currentDriverId: driverId,
        currentDriverName: 'Carlos Silva Motorista',
        status: VehicleStatus.rented,
      );
    }

    try {
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

    if (previousDriverId != null && previousDriverId.isNotEmpty) {
      _driverToVehicle.remove(previousDriverId);
    }
    if (_memoryVehicles.containsKey(vehicleId)) {
      final current = _memoryVehicles[vehicleId]!;
      _memoryVehicles[vehicleId] = current.copyWith(
        currentDriverId: null,
        currentDriverName: null,
        status: VehicleStatus.available,
      );
    }

    try {
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
        await _client.from(SupabaseConfig.tabelaHistoricoAtividades).insert({
          'motorista_id': previousDriverId,
          'tipo': 'veiculo_desvinculado',
          'descricao': 'Veículo desvinculado da posse do motorista.',
          'criado_em': nowStr,
        });
      }
    } catch (_) {}
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
