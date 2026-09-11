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
    print('Result:\n${res.body}');
  }

  await runSql('CONTRATOS ALL COLUMNS', 'SELECT * FROM contratos;');
  await runSql('MOTORISTAS ALL COLUMNS', 'SELECT * FROM motoristas;');
  await runSql('VEICULOS ALL COLUMNS', 'SELECT * FROM veiculos;');
  await runSql('AUDIT LOGS IF ANY', 'SELECT * FROM historico_atividades ORDER BY criado_em DESC LIMIT 20;');
}
