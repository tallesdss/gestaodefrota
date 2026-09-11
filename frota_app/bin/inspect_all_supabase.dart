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
    print('Result: ${res.body}');
  }

  await runSql('VISTORIAS', 'SELECT * FROM vistorias;');
  await runSql('LANCAMENTOS FINANCEIROS', 'SELECT id, motorista_id, veiculo_id, valor, status, data_vencimento, descricao FROM lancamentos_financeiros;');
  await runSql('ALL PROFILES', 'SELECT id, nome, email, cargo FROM perfis;');
}
