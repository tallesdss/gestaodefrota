import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const token = 'YOUR_SUPABASE_TOKEN';
  const projectRef = 'rwksrejrmjqnuspqnokp';

  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<void> runSql(String title, String query) async {
    print('\n=== $title ===');
    final res = await http.post(
      Uri.parse('https://api.supabase.com/v1/projects/$projectRef/database/query'),
      headers: headers,
      body: jsonEncode({'query': query}),
    );
    print('Result (${res.statusCode}): ${res.body}');
  }

  // 1. Assign contract CTR-1787373825673 to talls (ce2f3b4a-90aa-4aaa-827f-d732a8b876b9)
  // and set rental value to 750.00 as requested
  await runSql(
    'UPDATE CONTRATOS',
    '''
    UPDATE contratos
    SET motorista_id = 'ce2f3b4a-90aa-4aaa-827f-d732a8b876b9',
        valor_locacao = 750.00,
        status = 'ativo'
    WHERE id = '295b3a35-9644-4253-8725-10dd90ddcee0';
    ''',
  );

  // 2. Also ensure 3f8c2217-c975-4749-a341-898d0f3037b2 (Talles Motorista) is linked if needed
  // by updating perfis name if talls wants "Talles"
  await runSql(
    'UPDATE PERFIL TALLS',
    '''
    UPDATE perfis
    SET nome = 'Talles Motorista'
    WHERE id = 'ce2f3b4a-90aa-4aaa-827f-d732a8b876b9';
    ''',
  );

  // 3. Update lancamentos_financeiros to point to talls (ce2f3b4a-90aa-4aaa-827f-d732a8b876b9)
  // and ensure valor is 750.00
  await runSql(
    'UPDATE LANCAMENTOS FINANCEIROS',
    '''
    UPDATE lancamentos_financeiros
    SET motorista_id = 'ce2f3b4a-90aa-4aaa-827f-d732a8b876b9',
        valor = 750.00
    WHERE contrato_id = '295b3a35-9644-4253-8725-10dd90ddcee0';
    ''',
  );

  // 4. Update motoristas saldo_devedor
  await runSql(
    'UPDATE MOTORISTAS SALDO',
    '''
    UPDATE motoristas
    SET saldo_devedor = 3000.00
    WHERE id = 'ce2f3b4a-90aa-4aaa-827f-d732a8b876b9';
    ''',
  );

  // 5. Update vistorias
  await runSql(
    'UPDATE VISTORIAS',
    '''
    UPDATE vistorias
    SET motorista_id = 'ce2f3b4a-90aa-4aaa-827f-d732a8b876b9'
    WHERE veiculo_id = '885b06b4-40dd-46a6-bd2f-77f251566a10';
    ''',
  );

  // 6. Verify result
  await runSql(
    'VERIFY ASSIGNMENT',
    '''
    SELECT c.numero_contrato, c.valor_locacao, c.status as contrato_status,
           m.id as motorista_id, p.nome as motorista_nome, p.email as motorista_email,
           v.placa, v.marca, v.modelo, v.km_atual
    FROM contratos c
    JOIN motoristas m ON c.motorista_id = m.id
    JOIN perfis p ON m.id = p.id
    JOIN veiculos v ON c.veiculo_id = v.id;
    ''',
  );
}
