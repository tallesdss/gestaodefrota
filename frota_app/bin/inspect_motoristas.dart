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

  print('--- MOTORISTAS COM PERFIS ---');
  final res = await http.get(Uri.parse('$url/rest/v1/motoristas?select=*,perfis(*)'), headers: headers);
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');

  print('\n--- CONTRATOS COM VEICULOS ---');
  final resCtr = await http.get(Uri.parse('$url/rest/v1/contratos?select=*,veiculos(*)'), headers: headers);
  print('Status: ${resCtr.statusCode}');
  print('Body: ${resCtr.body}');
}
