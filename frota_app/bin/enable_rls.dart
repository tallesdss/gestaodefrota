import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const token = 'YOUR_SUPABASE_TOKEN';
  const projectRef = 'rwksrejrmjqnuspqnokp';

  final sql = '''
    -- Grant usage and permissions to anon and authenticated roles
    GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
    GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
    GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
    GRANT ALL ON ALL ROUTINES IN SCHEMA public TO anon, authenticated, service_role;

    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON ROUTINES TO anon, authenticated, service_role;

    -- Permissive RLS policies for anon and authenticated on all tables
    DO \$\$
    DECLARE
        tbl text;
    BEGIN
        FOR tbl IN 
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
        LOOP
            EXECUTE format('DROP POLICY IF EXISTS "anon_auth_all_policy" ON %I;', tbl);
            EXECUTE format('CREATE POLICY "anon_auth_all_policy" ON %I FOR ALL TO public USING (true) WITH CHECK (true);', tbl);
        END LOOP;
    END
    \$\$;
  ''';

  final res = await http.post(
    Uri.parse('https://api.supabase.com/v1/projects/$projectRef/database/query'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'query': sql}),
  );

  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');
}
