import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/inspection.dart';
import '../../models/timeline_item.dart';
import '../config/supabase_config.dart';
import 'timeline_repository.dart';

/// Repositório concreto para o Módulo de Vistorias e Check-ins no Supabase
class InspectionRepository {
  final SupabaseClient _client;

  InspectionRepository({SupabaseClient? client}) : _client = client ?? supabase;

  bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(str);
  }

  /// Listar vistorias com fotos e itens de checklist
  Future<List<Inspection>> getInspections({
    String? driverId,
    String? vehicleId,
    String? status,
  }) async {
    if (driverId != null && driverId.isNotEmpty && !_isValidUuid(driverId)) {
      throw ArgumentError.value(
        driverId,
        'driverId',
        'ID de motorista inválido.',
      );
    }

    var query = _client.from(SupabaseConfig.tabelaVistorias).select('''
      *,
      fotos_vistoria (*),
      itens_checklist_vistoria (*)
    ''');

    if (driverId != null && driverId.isNotEmpty) {
      query = query.eq('motorista_id', driverId);
    }
    if (vehicleId != null && vehicleId.isNotEmpty && _isValidUuid(vehicleId)) {
      query = query.eq('veiculo_id', vehicleId);
    }
    if (status != null &&
        status.isNotEmpty &&
        status != 'all' &&
        status != 'todos') {
      String statusDb = status.toLowerCase();
      if (statusDb == 'aprovado' || statusDb == 'approved')
        statusDb = 'aprovado';
      if (statusDb == 'rejeitado' || statusDb == 'rejected')
        statusDb = 'rejeitado';
      if (statusDb == 'pendente' || statusDb == 'pending')
        statusDb = 'pendente_revisao';
      query = query.eq('status', statusDb);
    }

    final response = await query.order('criado_em', ascending: false);
    return (response as List)
        .map((v) => Inspection.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList();
  }

  /// Obter laudo detalhado por ID
  Future<Inspection?> getInspectionById(String id) async {
    if (!_isValidUuid(id)) return null;

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
    final now = DateTime.now();
    final localId = inspection.id.isNotEmpty
        ? inspection.id
        : 'insp_${now.millisecondsSinceEpoch}';

    final fullInspection = inspection.copyWith(id: localId, dateTime: now);

    if (!_isValidUuid(fullInspection.driverId) ||
        !_isValidUuid(fullInspection.vehicleId) ||
        !_isValidUuid(fullInspection.contractId)) {
      throw ArgumentError(
        'Motorista, veículo e contrato válidos são obrigatórios.',
      );
    }

    final vistoriaMap = fullInspection.toDatabaseMap()..remove('id');
    final photosPayload = fullInspection.photos.map((photo) {
      final payload = photo.toDatabaseMap('')..remove('vistoria_id');
      return payload;
    }).toList();
    final checklistPayload = fullInspection.checklist.map((item) {
      final payload = item.toDatabaseMap('')..remove('vistoria_id');
      return payload;
    }).toList();
    final vistoriaId = (await _client.rpc(
      'fn_criar_vistoria_completa',
      params: {
        'p_vistoria': vistoriaMap,
        'p_fotos': photosPayload,
        'p_checklist': checklistPayload,
      },
    )).toString();
    if (!_isValidUuid(vistoriaId)) {
      throw StateError('O Supabase não retornou o ID da vistoria criada.');
    }

    final isCheckin = fullInspection.type == InspectionType.checkin;
    final isCheckout = fullInspection.type == InspectionType.checkout;
    final typeLabel = isCheckin
        ? 'Check-in'
        : (isCheckout ? 'Check-out' : 'Rotina');
    try {
      await TimelineRepository(client: _client).addTimelineItem(
        TimelineItem(
          id: '',
          title: 'Vistoria $typeLabel realizada',
          description:
              'Vistoria enviada para análise. KM: ${fullInspection.kmAtInspection}.',
          date: now,
          type: 'vistoria',
        ),
        defaultDriverId: fullInspection.driverId,
      );
    } catch (_) {}

    final savedInspection = await getInspectionById(vistoriaId);
    if (savedInspection == null) {
      throw StateError(
        'A vistoria foi gravada, mas não pôde ser recuperada do Supabase.',
      );
    }
    return savedInspection;
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

    final payload = <String, dynamic>{'status': statusStr};
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
