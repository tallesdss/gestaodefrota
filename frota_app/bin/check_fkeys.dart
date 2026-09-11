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

  // Test foreign keys on contratos
  await runSql('''
    SELECT
      tc.table_schema,
      tc.constraint_name,
      tc.table_name,
      kcu.column_name,
      ccu.table_name AS foreign_table_name,
      ccu.column_name AS foreign_column_name
    FROM information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name IN ('contratos', 'motoristas', 'veiculos');
  ''');
}
