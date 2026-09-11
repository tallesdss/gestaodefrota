import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const token = 'YOUR_SUPABASE_TOKEN';
  const projectRef = 'rwksrejrmjqnuspqnokp';

  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  final res = await http.post(
    Uri.parse('https://api.supabase.com/v1/projects/$projectRef/database/query'),
    headers: headers,
    body: jsonEncode({
      'query': 'SELECT id, email, last_sign_in_at, created_at FROM auth.users ORDER BY last_sign_in_at DESC NULLS LAST;'
    }),
  );
  print('Auth users by last sign in:\n${res.body}');
}
