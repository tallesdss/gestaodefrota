import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const url = 'https://rwksrejrmjqnuspqnokp.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3a3NyZWpybWpxbnVzcHFub2twIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4NDQ3NTUsImV4cCI6MjEwMjQyMDc1NX0.Yrd5UKfAM925jo7tpFQ08soDrcjkyCfGBQJ0qSmLPRc';

  final headers = {
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
    'Content-Type': 'application/json',
  };

  print('--- CHECKING TABLES IN SUPABASE ---');

  for (final table in ['perfis', 'motoristas', 'veiculos', 'contratos', 'vistorias', 'fotos_vistoria', 'itens_checklist_vistoria', 'historico_atividades']) {
    try {
      final res = await http.get(Uri.parse('$url/rest/v1/$table?select=*&limit=5'), headers: headers);
      print('Table [$table]: Status ${res.statusCode}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print('  Count: ${(data as List).length}');
        if (data.isNotEmpty) {
          print('  Sample: ${data.first}');
        }
      } else {
        print('  Error: ${res.body}');
      }
    } catch (e) {
      print('Table [$table] Exception: $e');
    }
  }
}
