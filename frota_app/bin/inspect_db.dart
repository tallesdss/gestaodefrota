import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const token = 'YOUR_SUPABASE_TOKEN';
  const projectRef = 'rwksrejrmjqnuspqnokp';

  Future<void> runQuery(String name, String query) async {
    final res = await http.post(
      Uri.parse('https://api.supabase.com/v1/projects/$projectRef/database/query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );
    print('=== $name ===');
    print(res.body);
  }

  await runQuery('AUTH USERS', 'SELECT id, email, created_at FROM auth.users;');
  await runQuery('PERFIS', 'SELECT * FROM public.perfis;');
  await runQuery('MOTORISTAS', 'SELECT * FROM public.motoristas;');
  await runQuery('VEICULOS', 'SELECT * FROM public.veiculos;');
  await runQuery('CONTRATOS', 'SELECT * FROM public.contratos;');
  await runQuery('VISTORIAS', 'SELECT * FROM public.vistorias;');
  await runQuery('STORAGE BUCKETS', 'SELECT * FROM storage.buckets;');
}
