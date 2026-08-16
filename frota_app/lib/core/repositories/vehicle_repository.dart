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
