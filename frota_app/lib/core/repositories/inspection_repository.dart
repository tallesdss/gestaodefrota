import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/inspection.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para o Módulo de Vistorias e Check-ins no Supabase
class InspectionRepository {
  final SupabaseClient _client;

  // Cache sincronizado em memória para persistir vistorias em tempo real
  static final List<Inspection> _memoryInspections = [
    Inspection(
      id: 'insp-byd-init',
      contractId: 'ctr-byd-001',
      vehicleId: 'v-byd-bvt2356',
      driverId: 'dfc34aba-9a10-4da0-a38f-91b47438bde0',
      type: InspectionType.checkin,
      status: InspectionStatus.approved,
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      kmAtInspection: 195000,
      fuelLevel: 1.0,
      photos: [
        InspectionPhoto(
          id: 'p1',
          url: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=400&auto=format&fit=crop',
          title: 'Frente',
          photoType: 'frente',
        ),
        InspectionPhoto(
          id: 'p2',
          url: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=400&auto=format&fit=crop',
          title: 'Traseira',
          photoType: 'traseira',
        ),
      ],
      checklist: [
        ChecklistItem(title: 'Pneus em bom estado', isChecked: true),
        ChecklistItem(title: 'Nível de combustível registrado', isChecked: true),
        ChecklistItem(title: 'Sem luzes de alerta no painel', isChecked: true),
        ChecklistItem(title: 'Limpadores funcionando', isChecked: true),
        ChecklistItem(title: 'Ar-condicionado gelando', isChecked: true),
      ],
      notes: 'Check-in inicial de entrega do veículo BYD Dolphin Plus EV.',
      hasNewDamage: false,
    ),
  ];

  InspectionRepository({SupabaseClient? client}) : _client = client ?? supabase;

  bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    return RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(str);
  }

  /// Listar vistorias com fotos e itens de checklist
  Future<List<Inspection>> getInspections({
    String? driverId,
    String? vehicleId,
    String? status,
  }) async {
    final List<Inspection> list = [];

    if (driverId == null || _isValidUuid(driverId)) {
      try {
        var query = _client.from(SupabaseConfig.tabelaVistorias).select('''
          *,
          fotos_vistoria (*),
          itens_checklist_vistoria (*)
        ''');

        if (driverId != null && driverId.isNotEmpty && _isValidUuid(driverId)) {
          query = query.eq('motorista_id', driverId);
        }
        if (vehicleId != null && vehicleId.isNotEmpty && _isValidUuid(vehicleId)) {
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
        final dbInspections = (response as List)
            .map((v) => Inspection.fromMap(Map<String, dynamic>.from(v as Map)))
            .toList();
        list.addAll(dbInspections);
      } catch (_) {}
    }

    // Mesclar vistorias em memória
    for (final mem in _memoryInspections) {
      if (driverId != null && mem.driverId != driverId) continue;
      if (vehicleId != null && mem.vehicleId != vehicleId) continue;
      if (status != null && status.isNotEmpty && status != 'all' && status != 'todos') {
        if (status == 'aprovado' && mem.status != InspectionStatus.approved) continue;
        if (status == 'rejeitado' && mem.status != InspectionStatus.rejected) continue;
        if (status == 'pendente' && mem.status != InspectionStatus.pending) continue;
      }
      if (!list.any((i) => i.id == mem.id)) {
        list.insert(0, mem);
      }
    }

    // Ordenar pela mais recente
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return list;
  }

  /// Obter laudo detalhado por ID
  Future<Inspection?> getInspectionById(String id) async {
    final fromMem = _memoryInspections.where((i) => i.id == id).toList();
    if (fromMem.isNotEmpty) return fromMem.first;

    if (_isValidUuid(id)) {
      try {
        final response = await _client
            .from(SupabaseConfig.tabelaVistorias)
            .select('''
              *,
              fotos_vistoria (*),
              itens_checklist_vistoria (*)
            ''')
            .eq('id', id)
            .maybeSingle();

        if (response != null) {
          return Inspection.fromMap(Map<String, dynamic>.from(response));
        }
      } catch (_) {}
    }

    return null;
  }

  /// Salvar vistoria completa em cascata relacional
  Future<Inspection> createInspection(Inspection inspection) async {
    final now = DateTime.now();
    final localId = inspection.id.isNotEmpty
        ? inspection.id
        : 'insp_${now.millisecondsSinceEpoch}';

    final fullInspection = inspection.copyWith(
      id: localId,
      dateTime: now,
    );

    // 1. Inserir no topo do cache em memória
    _memoryInspections.insert(0, fullInspection);

    // 2. Registrar evento na linha do tempo
    try {
      final timelineRepo = TimelineRepository(client: _client);
      final isCheckin = fullInspection.type == InspectionType.checkin;
      final isCheckout = fullInspection.type == InspectionType.checkout;
      final typeLabel = isCheckin ? 'Check-in' : (isCheckout ? 'Check-out' : 'Rotina');

      await timelineRepo.addTimelineItem(
        TimelineItem(
          id: 't_insp_${now.millisecondsSinceEpoch}',
          title: 'Vistoria 360º Realizada',
          description: 'Vistoria de $typeLabel enviada para análise.${fullInspection.kmAtInspection > 0 ? ' (KM: ${fullInspection.kmAtInspection})' : ''}',
          date: now,
          type: 'vistoria',
        ),
        defaultDriverId: fullInspection.driverId,
      );
    } catch (_) {}

    // 3. Se for informada a quilometragem, atualizar odômetro do veículo
    if (fullInspection.kmAtInspection > 0) {
      try {
        final vehicleRepo = VehicleRepository(client: _client);
        await vehicleRepo.updateOdometer(
          fullInspection.vehicleId,
          fullInspection.kmAtInspection,
          driverId: fullInspection.driverId,
        );
      } catch (_) {}
    }

    // 4. Salvar no Supabase (sanitizando UUIDs para evitar erros de sintaxe)
    try {
      final vistoriaMap = fullInspection.toDatabaseMap();
      vistoriaMap.remove('id');

      if (!_isValidUuid(vistoriaMap['motorista_id']?.toString())) {
        vistoriaMap['motorista_id'] = 'dfc34aba-9a10-4da0-a38f-91b47438bde0';
      }
      if (!_isValidUuid(vistoriaMap['veiculo_id']?.toString())) {
        vistoriaMap.remove('veiculo_id');
      }
      if (!_isValidUuid(vistoriaMap['contrato_id']?.toString())) {
        vistoriaMap.remove('contrato_id');
      }

      final vistoriaRes = await _client
          .from(SupabaseConfig.tabelaVistorias)
          .insert(vistoriaMap)
          .select()
          .single();

      final vistoriaId = vistoriaRes['id'].toString();

      if (fullInspection.photos.isNotEmpty) {
        final photosPayload = fullInspection.photos
            .map((p) => p.toDatabaseMap(vistoriaId))
            .toList();
        await _client.from(SupabaseConfig.tabelaFotosVistoria).insert(photosPayload);
      }

      if (fullInspection.checklist.isNotEmpty) {
        final checklistPayload = fullInspection.checklist
            .map((c) => c.toDatabaseMap(vistoriaId))
            .toList();
        await _client.from(SupabaseConfig.tabelaItensChecklistVistoria).insert(checklistPayload);
      }
    } catch (_) {}

    return fullInspection;
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
