import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/driver.dart';
import '../../models/timeline_item.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para o Módulo de Motoristas no Supabase
class DriverRepository {
  final SupabaseClient _client;

  DriverRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Listar motoristas com filtros e dados do perfil (perfis)
  Future<List<Driver>> getDrivers({
    String? status,
    String? search,
    String? city,
  }) async {
    var query = _client.from(SupabaseConfig.tabelaMotoristas).select('''
      *,
      perfis!inner (
        id,
        nome,
        email,
        telefone,
        foto_url,
        cargo
      ),
      contratos (
        id,
        status,
        veiculo_id,
        veiculos (
          id,
          placa,
          modelo
        )
      )
    ''');

    if (status != null && status.isNotEmpty && status != 'all' && status != 'todos') {
      String statusDb = status.toLowerCase();
      if (statusDb == 'ativo' || statusDb == 'active') statusDb = 'ativo';
      if (statusDb == 'pendente' || statusDb == 'pending') statusDb = 'pendente_aprovacao';
      if (statusDb == 'bloqueado' || statusDb == 'blocked') statusDb = 'bloqueado';
      query = query.eq('status', statusDb);
    }

    if (city != null && city.isNotEmpty && city != 'Todas' && city != 'todas') {
      query = query.ilike('cidade', '%$city%');
    }

    final response = await query.order('criado_em', ascending: false);

    return (response as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);

      // Localizar veículo atualmente sob contrato ativo
      if (map['contratos'] is List && (map['contratos'] as List).isNotEmpty) {
        final activeContracts = (map['contratos'] as List)
            .where((c) => c['status'] == 'ativo')
            .toList();
        if (activeContracts.isNotEmpty) {
          map['veiculo_atual_id'] = activeContracts.first['veiculo_id'];
        }
      }

      return Driver.fromMap(map);
    }).toList();
  }

  /// Obter motorista por ID com histórico 360
  Future<Driver?> getDriverById(String id) async {
    final response = await _client
        .from(SupabaseConfig.tabelaMotoristas)
        .select('''
          *,
          perfis!inner (
            id,
            nome,
            email,
            telefone,
            foto_url,
            cargo
          ),
          contratos (
            id,
            status,
            veiculo_id,
            veiculos (
              id,
              placa,
              modelo
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
        map['veiculo_atual_id'] = activeContracts.first['veiculo_id'];
      }
    }

    return Driver.fromMap(map);
  }

  /// Criar ou sincronizar motorista
  Future<Driver> createDriver(Driver driver) async {
    // 1. Atualizar ou criar o perfil base
    await _client.from(SupabaseConfig.tabelaPerfis).upsert(driver.toProfileDatabaseMap());

    // 2. Inserir ou atualizar os dados de motorista
    final response = await _client
        .from(SupabaseConfig.tabelaMotoristas)
        .upsert(driver.toDatabaseMap())
        .select('''
          *,
          perfis (nome, email, telefone, foto_url)
        ''')
        .single();

    return Driver.fromMap(response);
  }

  /// Atualizar dados do motorista e perfil
  Future<Driver> updateDriver(Driver driver) async {
    await _client
        .from(SupabaseConfig.tabelaPerfis)
        .update(driver.toProfileDatabaseMap())
        .eq('id', driver.id);

    final response = await _client
        .from(SupabaseConfig.tabelaMotoristas)
        .update(driver.toDatabaseMap())
        .eq('id', driver.id)
        .select('''
          *,
          perfis (nome, email, telefone, foto_url)
        ''')
        .single();

    return Driver.fromMap(response);
  }

  /// Atualizar status cadastral do motorista (Aprovar / Bloquear / Inativar)
  Future<void> updateDriverStatus(String driverId, DriverStatus status) async {
    String statusStr = 'pendente_aprovacao';
    if (status == DriverStatus.active) statusStr = 'ativo';
    if (status == DriverStatus.blocked) statusStr = 'bloqueado';
    if (status == DriverStatus.inactive) statusStr = 'inativo';

    await _client
        .from(SupabaseConfig.tabelaMotoristas)
        .update({'status': statusStr})
        .eq('id', driverId);
  }

  /// Upload de documento confidencial (CNH, Comprovante) no Storage com fallback para Base64
  Future<String> uploadDriverDocument({
    required String driverId,
    required String docType, // 'cnh_frente', 'cnh_verso', 'comprovante_residencia'
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) async {
    final path = '$driverId/${docType}_$fileName';
    String documentUrl = '';

    // 1. Tentar upload no Supabase Storage
    try {
      await _client.storage
          .from(SupabaseConfig.bucketDocumentosMotoristas)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      // Gerar link assinado de leitura segura (1 ano de validade)
      documentUrl = await _client.storage
          .from(SupabaseConfig.bucketDocumentosMotoristas)
          .createSignedUrl(path, 60 * 60 * 24 * 365);
    } catch (_) {
      // 2. Se o bucket não existir ou storage falhar, salvar Data URI Base64 diretamente no banco
      final base64String = base64Encode(bytes);
      documentUrl = 'data:$mimeType;base64,$base64String';
    }

    // 3. Atualizar coluna correspondente na tabela motoristas
    String? columnName;
    if (docType == 'cnh_frente') columnName = 'cnh_frente_url';
    if (docType == 'cnh_verso') columnName = 'cnh_verso_url';
    if (docType == 'comprovante_residencia') columnName = 'comprovante_residencia_url';

    if (columnName != null && documentUrl.isNotEmpty) {
      await _client
          .from(SupabaseConfig.tabelaMotoristas)
          .upsert({
            'id': driverId,
            columnName: documentUrl,
            'atualizado_em': DateTime.now().toIso8601String(),
          });
    }

    return documentUrl;
  }

  /// Obter URL assinada para visualização de documento se for caminho de storage
  Future<String> getDocumentSignedUrl(String pathOrUrl) async {
    if (pathOrUrl.startsWith('http://') ||
        pathOrUrl.startsWith('https://') ||
        pathOrUrl.startsWith('data:image')) {
      return pathOrUrl;
    }
    try {
      final signedUrl = await _client.storage
          .from(SupabaseConfig.bucketDocumentosMotoristas)
          .createSignedUrl(pathOrUrl, 60 * 60 * 24);
      return signedUrl;
    } catch (_) {
      return _client.storage
          .from(SupabaseConfig.bucketDocumentosMotoristas)
          .getPublicUrl(pathOrUrl);
    }
  }

  /// Obter linha do tempo / histórico de atividades do motorista
  Future<List<TimelineItem>> getDriverTimeline({
    required String driverId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    final response = await _client
        .from(SupabaseConfig.tabelaHistoricoAtividades)
        .select()
        .eq('motorista_id', driverId)
        .order('criado_em', ascending: false)
        .range(from, to);

    return (response as List).map((row) {
      return TimelineItem.fromMap(Map<String, dynamic>.from(row as Map));
    }).toList();
  }
}
