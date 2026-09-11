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
    final res = await http.post(
      Uri.parse('https://api.supabase.com/v1/projects/$projectRef/database/query'),
      headers: headers,
      body: jsonEncode({'query': query}),
    );
    print('Result:\n${res.body}');
  }

  print('--- AUTH USERS ---');
  await runSql('SELECT id, email, created_at FROM auth.users;');

  print('--- ALL CONTRACTS ---');
  await runSql('SELECT * FROM contratos;');

  print('--- ALL VEHICLES ---');
  await runSql('SELECT * FROM veiculos;');
}
