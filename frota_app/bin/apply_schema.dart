import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const token = 'YOUR_SUPABASE_TOKEN';
  const projectRef = 'rwksrejrmjqnuspqnokp';

  Future<void> runSql(String title, String filePath) async {
    print('--- Executing $title ($filePath) ---');
    final file = File(filePath);
    if (!await file.exists()) {
      print('File not found: $filePath');
      return;
    }
    final sql = await file.readAsString();
    final res = await http.post(
      Uri.parse('https://api.supabase.com/v1/projects/$projectRef/database/query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': sql}),
    );
    print('Status: ${res.statusCode}');
    if (res.statusCode == 200 || res.statusCode == 201) {
      print('Success!');
    } else {
      print('Response: ${res.body}');
    }
  }

  await runSql('SCHEMA DDL', '../docs/supabase_schema.sql');
  await runSql('STORAGE BUCKETS', '../docs/supabase_storage.sql');
  await runSql('AUTH TRIGGER FIX', '../docs/fix_auth_registration_trigger.sql');
}
