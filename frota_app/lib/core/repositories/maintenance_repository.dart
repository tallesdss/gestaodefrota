import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/maintenance_entry.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para Ordens de Serviço e Manutenções no Supabase
class MaintenanceRepository {
  final SupabaseClient _client;

  MaintenanceRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Listar manutenções com peças e oficina vinculada
  Future<List<MaintenanceEntry>> getMaintenances({
    String? vehicleId,
    String? workshopId,
    String? status,
  }) async {
    var query = _client.from(SupabaseConfig.tabelaManutencoes).select('''
      *,
      oficinas (
        id,
        nome_fantasia
      ),
      veiculos (
        id,
        placa,
        modelo
      ),
      itens_manutencao (*)
    ''');

    if (vehicleId != null && vehicleId.isNotEmpty) {
      query = query.eq('veiculo_id', vehicleId);
    }

    if (workshopId != null && workshopId.isNotEmpty) {
      query = query.eq('oficina_id', workshopId);
    }

    if (status != null && status.isNotEmpty && status != 'all' && status != 'todos') {
      String statusDb = status.toLowerCase();
      if (statusDb == 'pago' || statusDb == 'concluido' || statusDb == 'paid') statusDb = 'concluido';
      if (statusDb == 'pendente' || statusDb == 'pending') statusDb = 'agendado';
      if (statusDb == 'cancelado' || statusDb == 'cancelled') statusDb = 'cancelado';
      query = query.eq('status', statusDb);
    }

    final response = await query.order('data_servico', ascending: false);
    return (response as List)
        .map((m) => MaintenanceEntry.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  /// Obter ordem de serviço por ID
  Future<MaintenanceEntry?> getMaintenanceById(String id) async {
    final response = await _client
        .from(SupabaseConfig.tabelaManutencoes)
        .select('''
          *,
          oficinas (
            id,
            nome_fantasia
          ),
          veiculos (
            id,
            placa,
            modelo
          ),
          itens_manutencao (*)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return MaintenanceEntry.fromMap(Map<String, dynamic>.from(response));
  }

  /// Criar manutenção e peças em cascata relacional
  Future<MaintenanceEntry> createMaintenance(MaintenanceEntry entry) async {
    final payload = entry.toDatabaseMap();
    payload.remove('id');

    // 1. Inserir a ordem de serviço
    final res = await _client
        .from(SupabaseConfig.tabelaManutencoes)
        .insert(payload)
        .select()
        .single();

    final maintenanceId = res['id'].toString();

    // 2. Inserir peças na tabela filha itens_manutencao
    if (entry.parts.isNotEmpty) {
      final partsPayload = entry.parts
          .map((p) => p.toDatabaseMap(maintenanceId))
          .toList();
      await _client.from(SupabaseConfig.tabelaItensManutencao).insert(partsPayload);
    }

    return (await getMaintenanceById(maintenanceId)) ?? entry;
  }

  /// Atualizar manutenção
  Future<MaintenanceEntry> updateMaintenance(MaintenanceEntry entry) async {
    final payload = entry.toDatabaseMap();

    await _client
        .from(SupabaseConfig.tabelaManutencoes)
        .update(payload)
        .eq('id', entry.id);

    // Atualizar peças se existirem
    if (entry.parts.isNotEmpty) {
      await _client
          .from(SupabaseConfig.tabelaItensManutencao)
          .delete()
          .eq('manutencao_id', entry.id);

      final partsPayload = entry.parts
          .map((p) => p.toDatabaseMap(entry.id))
          .toList();
      await _client.from(SupabaseConfig.tabelaItensManutencao).insert(partsPayload);
    }

    return (await getMaintenanceById(entry.id)) ?? entry;
  }

  /// Deletar ou cancelar manutenção
  Future<void> deleteMaintenance(String id) async {
    await _client
        .from(SupabaseConfig.tabelaManutencoes)
        .delete()
        .eq('id', id);
  }

  /// Upload de Nota Fiscal Eletrônica (NFe) para o Storage
  Future<String> uploadInvoice({
    required String maintenanceId,
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) async {
    final path = 'os_$maintenanceId/nfe_$fileName';

    await _client.storage
        .from(SupabaseConfig.bucketNotasFiscaisOficinas)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    final publicUrl = _client.storage
        .from(SupabaseConfig.bucketNotasFiscaisOficinas)
        .getPublicUrl(path);

    await _client
        .from(SupabaseConfig.tabelaManutencoes)
        .update({'nota_fiscal_nfe_url': publicUrl})
        .eq('id', maintenanceId);

    return publicUrl;
  }
}
