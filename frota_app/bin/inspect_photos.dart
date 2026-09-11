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

  await runQuery('FOTOS_VISTORIA', 'SELECT * FROM public.fotos_vistoria;');
  await runQuery('ITENS_CHECKLIST_VISTORIA', 'SELECT * FROM public.itens_checklist_vistoria;');
}
