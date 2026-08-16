import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/inspection.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para o Módulo de Vistorias e Check-ins no Supabase
class InspectionRepository {
  final SupabaseClient _client;

  InspectionRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Listar vistorias com fotos e itens de checklist
  Future<List<Inspection>> getInspections({
    String? driverId,
    String? vehicleId,
    String? status,
  }) async {
    var query = _client.from(SupabaseConfig.tabelaVistorias).select('''
      *,
      fotos_vistoria (*),
      itens_checklist_vistoria (*)
    ''');

    if (driverId != null && driverId.isNotEmpty) {
      query = query.eq('motorista_id', driverId);
    }
    if (vehicleId != null && vehicleId.isNotEmpty) {
      query = query.eq('veiculo_id', vehicleId);
    }
    if (status != null && status.isNotEmpty && status != 'all' && status != 'todos') {
      String statusDb = status.toLowerCase();
      if (statusDb == 'aprovado' || statusDb == 'approved') statusDb = 'aprovado';
      if (statusDb == 'rejeitado' || statusDb == 'rejected') statusDb = 'rejeitado';
      if (statusDb == 'pendente' || statusDb == 'pending') statusDb = 'pendente_revisao';
      query = query.eq('status', statusDb);
    }

    final response = await query.order('criado_em', ascending: false);
    return (response as List)
        .map((v) => Inspection.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList();
  }

  /// Obter laudo detalhado por ID
  Future<Inspection?> getInspectionById(String id) async {
    final response = await _client
        .from(SupabaseConfig.tabelaVistorias)
        .select('''
          *,
          fotos_vistoria (*),
          itens_checklist_vistoria (*)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Inspection.fromMap(Map<String, dynamic>.from(response));
  }

  /// Salvar vistoria completa em cascata relacional
  Future<Inspection> createInspection(Inspection inspection) async {
    final vistoriaMap = inspection.toDatabaseMap();
    vistoriaMap.remove('id');

    // 1. Inserir registro mestre na tabela vistorias
    final vistoriaRes = await _client
        .from(SupabaseConfig.tabelaVistorias)
        .insert(vistoriaMap)
        .select()
        .single();

    final vistoriaId = vistoriaRes['id'].toString();

    // 2. Inserir fotos na tabela filha fotos_vistoria
    if (inspection.photos.isNotEmpty) {
      final photosPayload = inspection.photos
          .map((p) => p.toDatabaseMap(vistoriaId))
          .toList();
      await _client.from(SupabaseConfig.tabelaFotosVistoria).insert(photosPayload);
    }

    // 3. Inserir itens de checklist na tabela filha itens_checklist_vistoria
    if (inspection.checklist.isNotEmpty) {
      final checklistPayload = inspection.checklist
          .map((c) => c.toDatabaseMap(vistoriaId))
          .toList();
      await _client.from(SupabaseConfig.tabelaItensChecklistVistoria).insert(checklistPayload);
    }

    return (await getInspectionById(vistoriaId)) ?? inspection;
  }

  /// Atualizar status do laudo (Aprovar / Rejeitar)
  Future<void> updateInspectionStatus(
    String inspectionId,
    InspectionStatus status, {
    String? reviewerId,
    String? reviewReason,
  }) async {
    String statusStr = 'pendente_revisao';
    if (status == InspectionStatus.approved) statusStr = 'aprovado';
    if (status == InspectionStatus.rejected) statusStr = 'rejeitado';

    final payload = <String, dynamic>{
      'status': statusStr,
    };
    if (reviewerId != null) payload['vistoriador_id'] = reviewerId;
    if (reviewReason != null) payload['motivo_revisao'] = reviewReason;

    await _client
        .from(SupabaseConfig.tabelaVistorias)
        .update(payload)
        .eq('id', inspectionId);
  }

  /// Upload de foto de vistoria 360º para o Storage
  Future<String> uploadInspectionPhoto({
    required String inspectionId,
    required String position,
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) async {
    final path = 'vistoria_$inspectionId/${position}_$fileName';

    await _client.storage
        .from(SupabaseConfig.bucketFotosVistorias)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    final publicUrl = _client.storage
        .from(SupabaseConfig.bucketFotosVistorias)
        .getPublicUrl(path);

    return publicUrl;
  }
}
