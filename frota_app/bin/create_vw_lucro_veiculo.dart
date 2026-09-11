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
    print(res.body);
  }

  const sql = '''
CREATE OR REPLACE VIEW public.vw_lucro_veiculo AS
SELECT 
    v.id AS veiculo_id,
    v.marca,
    v.modelo,
    v.placa,
    COALESCE(rec.total_receitas, 0) AS total_receitas_pagas,
    COALESCE(des.total_despesas, 0) AS total_despesas_pagas,
    (COALESCE(rec.total_receitas, 0) - COALESCE(des.total_despesas, 0)) AS lucro_liquido
FROM public.veiculos v
LEFT JOIN (
    SELECT veiculo_id, SUM(valor) AS total_receitas
    FROM public.lancamentos_financeiros
    WHERE tipo = 'receita' AND status = 'pago'
    GROUP BY veiculo_id
) rec ON v.id = rec.veiculo_id
LEFT JOIN (
    SELECT veiculo_id, SUM(valor) AS total_despesas
    FROM public.lancamentos_financeiros
    WHERE tipo = 'despesa' AND status = 'pago'
    GROUP BY veiculo_id
) des ON v.id = des.veiculo_id;

-- Garantir permissões básicas
GRANT SELECT ON public.vw_lucro_veiculo TO anon, authenticated, service_role;
  ''';

  await runQuery('Create VW Lucro Veiculo', sql);
  await runQuery('Test View', 'SELECT * FROM public.vw_lucro_veiculo LIMIT 5;');
}
