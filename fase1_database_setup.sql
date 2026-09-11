-- DB-01: Criar tabela configuracoes_sistema
CREATE TABLE IF NOT EXISTS public.configuracoes_sistema (
  chave VARCHAR(100) PRIMARY KEY,
  valor JSONB NOT NULL,
  atualizado_em TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.configuracoes_sistema ENABLE ROW LEVEL SECURITY;

-- Nota: assumindo que a funcao eh_admin() ja exista.
-- CREATE POLICY "Admin gerencia configuracoes"
--  ON public.configuracoes_sistema FOR ALL
--  USING (public.eh_admin());

-- DB-02: Garantir que a categoria de despesa "Aluguel" (10000000-0000-0000-0000-000000000002) exista
INSERT INTO public.categorias_despesa (id, nome, tipo, descricao)
VALUES ('10000000-0000-0000-0000-000000000002', 'Aluguel/Locação', 'receita', 'Receitas de aluguéis e locações')
ON CONFLICT (id) DO NOTHING;

-- DB-03: Criar Função fn_gerar_parcelas_contrato
CREATE OR REPLACE FUNCTION public.fn_gerar_parcelas_contrato(
  p_contrato_id UUID,
  p_valor_locacao DECIMAL,
  p_frequencia VARCHAR,
  p_dia_vencimento INT,
  p_data_inicio DATE,
  p_num_parcelas INT
) RETURNS void AS $$
DECLARE
  v_vencimento DATE;
  v_motorista_id UUID;
  v_veiculo_id UUID;
  v_i INT;
BEGIN
  -- Obter dados do contrato
  SELECT motorista_id, veiculo_id INTO v_motorista_id, v_veiculo_id
  FROM public.contratos WHERE id = p_contrato_id;

  v_vencimento := p_data_inicio;

  FOR v_i IN 1..p_num_parcelas LOOP
    -- Inserir parcela
    INSERT INTO public.lancamentos_financeiros (
      motorista_id, veiculo_id, categoria_id, tipo, valor, data_vencimento, status,
      descricao, contrato_id
    ) VALUES (
      v_motorista_id,
      v_veiculo_id,
      '10000000-0000-0000-0000-000000000002',
      'receita',
      p_valor_locacao,
      v_vencimento,
      'pendente',
      'Aluguel ' || INITCAP(p_frequencia) || ' — Parcela ' || v_i || ' de ' || p_num_parcelas,
      p_contrato_id
    );

    -- Incrementar data conforme frequencia
    IF p_frequencia = 'semanal' THEN
      v_vencimento := v_vencimento + INTERVAL '7 days';
    ELSIF p_frequencia = 'quinzenal' THEN
      v_vencimento := v_vencimento + INTERVAL '14 days';
    ELSIF p_frequencia = 'mensal' THEN
      v_vencimento := v_vencimento + INTERVAL '1 month';
    ELSE
      -- Fallback para mensal
      v_vencimento := v_vencimento + INTERVAL '1 month';
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- DB-04: Criar Função fn_marcar_lancamentos_atrasados
CREATE OR REPLACE FUNCTION public.fn_marcar_lancamentos_atrasados()
RETURNS void AS $$
BEGIN
  UPDATE public.lancamentos_financeiros
  SET status = 'atrasado', atualizado_em = now()
  WHERE status = 'pendente'
    AND data_vencimento < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DB-05: Atualização necessária na view vw_kpis_dashboard_master
-- Para não recriar toda a view que pode ter outros campos, certifique-se
-- de atualizar a cláusula do denominador da taxa de ocupação
-- na interface SQL do Supabase.
