import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const token = 'YOUR_SUPABASE_TOKEN';
  const projectRef = 'rwksrejrmjqnuspqnokp';

  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<void> runSql(String query) async {
    print('\n=== EXECUTING SQL ===\n$query');
    final res = await http.post(
      Uri.parse('https://api.supabase.com/v1/projects/$projectRef/database/query'),
      headers: headers,
      body: jsonEncode({'query': query}),
    );
    print('Status: ${res.statusCode}');
    print('Result: ${res.body}');
  }

  // Check veiculos, motoristas, contratos
  await runSql('''
    SELECT c.id as contrato_id, c.numero_contrato, c.status as contrato_status, c.valor_locacao,
           m.id as motorista_id, p.nome as motorista_nome, p.email,
           v.id as veiculo_id, v.placa, v.marca, v.modelo, v.status as veiculo_status
    FROM contratos c
    LEFT JOIN motoristas m ON c.motorista_id = m.id
    LEFT JOIN perfis p ON m.id = p.id
    LEFT JOIN veiculos v ON c.veiculo_id = v.id;
  ''');

  await runSql('''
    SELECT id, placa, marca, modelo, km_atual, status FROM veiculos;
  ''');

  await runSql('''
    SELECT m.id, p.nome, p.email, p.cargo, m.status FROM motoristas m JOIN perfis p ON m.id = p.id;
  ''');
}
