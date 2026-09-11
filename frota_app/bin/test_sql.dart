import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const token = 'YOUR_SUPABASE_TOKEN';
  const projectRef = 'rwksrejrmjqnuspqnokp';

  Future<void> runQuery(String name, String sql) async {
    final res = await http.post(
      Uri.parse('https://api.supabase.com/v1/projects/$projectRef/database/query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': sql}),
    );
    print('=== $name ===');
    final data = jsonDecode(res.body);
    print(const JsonEncoder.withIndent('  ').convert(data));
  }

  await runQuery('VEICULOS', 'SELECT * FROM veiculos;');
  await runQuery('MOTORISTAS', 'SELECT * FROM motoristas;');
  await runQuery('CONTRATOS', 'SELECT * FROM contratos;');
}
