CREATE OR REPLACE FUNCTION public.fn_gerar_parcelas_contrato(
    p_contrato_id UUID,
    p_valor_locacao NUMERIC,
    p_frequencia VARCHAR,
    p_dia_vencimento INT,
    p_data_inicio DATE,
    p_num_parcelas INT
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_vencimento DATE := p_data_inicio;
    v_motorista_id UUID;
    v_veiculo_id UUID;
    v_numero_contrato VARCHAR(50);
    v_frequencia_label TEXT;
    v_titulo TEXT;
    v_i INT;
BEGIN
    IF auth.uid() IS NOT NULL AND NOT public.eh_gestor_ou_admin() THEN
        RAISE EXCEPTION 'Apenas a gestão pode gerar parcelas de contrato.';
    END IF;

    IF p_valor_locacao <= 0 OR p_num_parcelas < 1 THEN
        RAISE EXCEPTION 'Valor da locação e quantidade de parcelas devem ser positivos.';
    END IF;

    SELECT motorista_id, veiculo_id, numero_contrato
    INTO v_motorista_id, v_veiculo_id, v_numero_contrato
    FROM public.contratos
    WHERE id = p_contrato_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contrato % não encontrado.', p_contrato_id;
    END IF;

    v_frequencia_label := CASE p_frequencia
        WHEN 'semanal' THEN 'Semanal'
        WHEN 'quinzenal' THEN 'Quinzenal'
        WHEN 'mensal' THEN 'Mensal'
        ELSE NULL
    END;

    IF v_frequencia_label IS NULL THEN
        RAISE EXCEPTION 'Frequência de cobrança inválida: %.', p_frequencia;
    END IF;

    FOR v_i IN 1..p_num_parcelas LOOP
        v_titulo := format(
            'Aluguel %s - Parcela %s de %s - Contrato %s',
            v_frequencia_label,
            v_i,
            p_num_parcelas,
            v_numero_contrato
        );

        IF NOT EXISTS (
            SELECT 1
            FROM public.lancamentos_financeiros lf
            WHERE lf.contrato_id = p_contrato_id
              AND lf.tipo = 'receita'
              AND lf.data_vencimento = v_vencimento
              AND (
                  lf.titulo = v_titulo
                  OR (
                      v_i = 1
                      AND lf.titulo = '1ª Mensalidade - Contrato ' || v_numero_contrato
                  )
              )
        ) THEN
            INSERT INTO public.lancamentos_financeiros (
                motorista_id,
                veiculo_id,
                categoria_id,
                tipo,
                titulo,
                descricao,
                valor,
                data_vencimento,
                status,
                contrato_id
            ) VALUES (
                v_motorista_id,
                v_veiculo_id,
                '10000000-0000-0000-0000-000000000002',
                'receita',
                v_titulo,
                v_titulo,
                p_valor_locacao,
                v_vencimento,
                'pendente',
                p_contrato_id
            );
        END IF;

        IF p_frequencia = 'semanal' THEN
            v_vencimento := v_vencimento + 7;
        ELSIF p_frequencia = 'quinzenal' THEN
            v_vencimento := v_vencimento + 14;
        ELSE
            v_vencimento := (v_vencimento + INTERVAL '1 month')::DATE;
        END IF;
    END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.fn_gerar_parcelas_contrato(UUID, NUMERIC, VARCHAR, INT, DATE, INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_gerar_parcelas_contrato(UUID, NUMERIC, VARCHAR, INT, DATE, INT) TO authenticated, service_role;
