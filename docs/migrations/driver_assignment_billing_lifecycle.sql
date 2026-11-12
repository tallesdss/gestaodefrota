-- Lifecycle for vehicle assignments, check-in approval, recurring rent and receipts.
-- Apply this migration before publishing the Flutter changes.

ALTER TABLE public.contratos
    ADD COLUMN IF NOT EXISTS cobranca_iniciada_em TIMESTAMPTZ;
ALTER TABLE public.contratos
    ADD COLUMN IF NOT EXISTS desconto_percentual NUMERIC(5,2) NOT NULL DEFAULT 0
        CHECK (desconto_percentual >= 0 AND desconto_percentual < 100),
    ADD COLUMN IF NOT EXISTS motivo_desconto TEXT;
ALTER TABLE public.lancamentos_financeiros
    ADD COLUMN IF NOT EXISTS valor_original NUMERIC(12,2),
    ADD COLUMN IF NOT EXISTS desconto_percentual NUMERIC(5,2) NOT NULL DEFAULT 0
        CHECK (desconto_percentual >= 0 AND desconto_percentual < 100),
    ADD COLUMN IF NOT EXISTS motivo_desconto TEXT;

DROP FUNCTION IF EXISTS public.fn_criar_contrato_locacao(
    UUID, UUID, VARCHAR, DATE, NUMERIC, NUMERIC,
    public.frequencia_cobranca_enum, INT, UUID, UUID
);
DROP FUNCTION IF EXISTS public.fn_criar_contrato_locacao_v2(
    UUID, UUID, VARCHAR, DATE, DATE, NUMERIC, NUMERIC,
    public.frequencia_cobranca_enum, INT, UUID, UUID
);
CREATE OR REPLACE FUNCTION public.fn_criar_contrato_locacao_v2(
    p_motorista_id UUID,
    p_veiculo_id UUID,
    p_numero_contrato VARCHAR,
    p_data_inicio DATE,
    p_data_fim DATE,
    p_valor_locacao NUMERIC,
    p_valor_caucao NUMERIC,
    p_frequencia public.frequencia_cobranca_enum,
    p_dia_vencimento INT,
    p_categoria_receita_id UUID,
    p_operador_id UUID,
    p_desconto_percentual NUMERIC DEFAULT 0,
    p_motivo_desconto TEXT DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_contrato_id UUID;
    v_veiculo_status public.status_veiculo_enum;
    v_motorista_status public.status_motorista_enum;
BEGIN
    IF auth.uid() IS NOT NULL AND NOT public.eh_gestor_ou_admin() THEN
        RAISE EXCEPTION 'Apenas a gestão pode atribuir veículos.';
    END IF;

    IF p_data_fim IS NULL OR p_data_fim < p_data_inicio THEN
        RAISE EXCEPTION 'A data final não pode ser anterior à data inicial.';
    END IF;
    IF p_frequencia IN ('semanal', 'quinzenal')
       AND p_dia_vencimento NOT BETWEEN 1 AND 7 THEN
        RAISE EXCEPTION 'Para cobrança semanal ou quinzenal, informe um dia da semana entre 1 e 7.';
    END IF;
    IF p_desconto_percentual IS NULL
       OR p_desconto_percentual < 0
       OR p_desconto_percentual >= 100
       OR (p_desconto_percentual > 0 AND NULLIF(BTRIM(p_motivo_desconto), '') IS NULL) THEN
        RAISE EXCEPTION 'Desconto deve estar entre 0 e 100%% e precisa de um motivo.';
    END IF;

    SELECT status
    INTO v_veiculo_status
    FROM public.veiculos
    WHERE id = p_veiculo_id
    FOR UPDATE;

    IF v_veiculo_status IS DISTINCT FROM 'disponivel' THEN
        RAISE EXCEPTION 'Veículo não está disponível para locação.';
    END IF;

    SELECT status
    INTO v_motorista_status
    FROM public.motoristas
    WHERE id = p_motorista_id
    FOR UPDATE;

    IF v_motorista_status IS DISTINCT FROM 'ativo' THEN
        RAISE EXCEPTION 'Motorista não está ativo para iniciar contrato.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.contratos
        WHERE motorista_id = p_motorista_id
          AND status = 'ativo'
    ) THEN
        RAISE EXCEPTION 'Motorista já possui uma atribuição ativa.';
    END IF;

    INSERT INTO public.contratos (
        numero_contrato,
        motorista_id,
        veiculo_id,
        data_inicio,
        data_fim,
        valor_locacao,
        valor_caucao,
        frequencia_cobranca,
        dia_vencimento,
        desconto_percentual,
        motivo_desconto,
        status
    ) VALUES (
        p_numero_contrato,
        p_motorista_id,
        p_veiculo_id,
        p_data_inicio,
        p_data_fim,
        p_valor_locacao,
        p_valor_caucao,
        p_frequencia,
        p_dia_vencimento,
        p_desconto_percentual,
        CASE WHEN p_desconto_percentual > 0 THEN BTRIM(p_motivo_desconto) END,
        'ativo'
    ) RETURNING id INTO v_contrato_id;

    IF p_valor_caucao > 0 THEN
        INSERT INTO public.lancamentos_financeiros (
            categoria_id,
            contrato_id,
            motorista_id,
            veiculo_id,
            criado_por,
            tipo,
            titulo,
            valor,
            data_vencimento,
            status
        ) VALUES (
            p_categoria_receita_id,
            v_contrato_id,
            p_motorista_id,
            p_veiculo_id,
            p_operador_id,
            'receita',
            'Caução de Locação - Contrato ' || p_numero_contrato,
            p_valor_caucao,
            p_data_inicio,
            'pendente'
        );
    END IF;

    RETURN v_contrato_id;
END;
$$;

REVOKE ALL ON FUNCTION public.fn_criar_contrato_locacao_v2(
    UUID, UUID, VARCHAR, DATE, DATE, NUMERIC, NUMERIC,
    public.frequencia_cobranca_enum, INT, UUID, UUID, NUMERIC, TEXT
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_criar_contrato_locacao_v2(
    UUID, UUID, VARCHAR, DATE, DATE, NUMERIC, NUMERIC,
    public.frequencia_cobranca_enum, INT, UUID, UUID, NUMERIC, TEXT
) TO authenticated, service_role;

DROP FUNCTION IF EXISTS public.fn_atualizar_termos_contrato_antes_vistoria(
    UUID, NUMERIC, public.frequencia_cobranca_enum, INT, DATE
);
CREATE OR REPLACE FUNCTION public.fn_atualizar_termos_contrato_antes_vistoria(
    p_contrato_id UUID,
    p_valor_locacao NUMERIC,
    p_frequencia public.frequencia_cobranca_enum,
    p_dia_vencimento INT,
    p_data_fim DATE,
    p_desconto_percentual NUMERIC DEFAULT 0,
    p_motivo_desconto TEXT DEFAULT NULL
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_contrato public.contratos%ROWTYPE;
BEGIN
    IF auth.uid() IS NOT NULL AND NOT public.eh_gestor_ou_admin() THEN
        RAISE EXCEPTION 'Apenas a gestão pode alterar os termos do contrato.';
    END IF;

    SELECT *
    INTO v_contrato
    FROM public.contratos
    WHERE id = p_contrato_id
    FOR UPDATE;

    IF NOT FOUND
       OR v_contrato.status <> 'ativo'
       OR v_contrato.cobranca_iniciada_em IS NOT NULL THEN
        RAISE EXCEPTION 'Os termos só podem ser alterados antes da aprovação da vistoria de entrada.';
    END IF;

    IF p_valor_locacao <= 0
       OR p_dia_vencimento NOT BETWEEN 1 AND 31
       OR (p_frequencia IN ('semanal', 'quinzenal')
           AND p_dia_vencimento NOT BETWEEN 1 AND 7)
       OR p_desconto_percentual IS NULL
       OR p_desconto_percentual < 0
       OR p_desconto_percentual >= 100
       OR (p_desconto_percentual > 0 AND NULLIF(BTRIM(p_motivo_desconto), '') IS NULL)
       OR p_data_fim < CURRENT_DATE THEN
        RAISE EXCEPTION 'Informe valor, vencimento e fim de contrato válidos.';
    END IF;

    UPDATE public.contratos
    SET valor_locacao = p_valor_locacao,
        frequencia_cobranca = p_frequencia,
        dia_vencimento = p_dia_vencimento,
        desconto_percentual = p_desconto_percentual,
        motivo_desconto = CASE
            WHEN p_desconto_percentual > 0 THEN BTRIM(p_motivo_desconto)
            ELSE NULL
        END,
        data_fim = p_data_fim
    WHERE id = p_contrato_id;
END;
$$;

REVOKE ALL ON FUNCTION public.fn_atualizar_termos_contrato_antes_vistoria(
    UUID, NUMERIC, public.frequencia_cobranca_enum, INT, DATE, NUMERIC, TEXT
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_atualizar_termos_contrato_antes_vistoria(
    UUID, NUMERIC, public.frequencia_cobranca_enum, INT, DATE, NUMERIC, TEXT
) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.fn_aplicar_desconto_contrato_recorrente(
    p_contrato_id UUID,
    p_desconto_percentual NUMERIC,
    p_motivo_desconto TEXT
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_contrato public.contratos%ROWTYPE;
BEGIN
    IF auth.uid() IS NOT NULL AND NOT public.eh_gestor_ou_admin() THEN
        RAISE EXCEPTION 'Apenas a gestão pode aplicar descontos.';
    END IF;
    IF p_desconto_percentual IS NULL
       OR p_desconto_percentual < 0
       OR p_desconto_percentual >= 100
       OR (p_desconto_percentual > 0
           AND NULLIF(BTRIM(p_motivo_desconto), '') IS NULL) THEN
        RAISE EXCEPTION 'Desconto deve estar entre 0 e 100%% e precisa de um motivo.';
    END IF;

    SELECT *
    INTO v_contrato
    FROM public.contratos
    WHERE id = p_contrato_id
    FOR UPDATE;

    IF NOT FOUND OR v_contrato.status <> 'ativo'
       OR v_contrato.cobranca_iniciada_em IS NULL THEN
        RAISE EXCEPTION 'O contrato precisa estar ativo e com cobrança iniciada.';
    END IF;

    UPDATE public.contratos
    SET desconto_percentual = p_desconto_percentual,
        motivo_desconto = CASE
            WHEN p_desconto_percentual > 0 THEN BTRIM(p_motivo_desconto)
            ELSE NULL
        END
    WHERE id = p_contrato_id;

    UPDATE public.lancamentos_financeiros
    SET valor_original = COALESCE(valor_original, valor),
        desconto_percentual = p_desconto_percentual,
        motivo_desconto = CASE
            WHEN p_desconto_percentual > 0 THEN BTRIM(p_motivo_desconto)
            ELSE NULL
        END,
        valor = ROUND(
            COALESCE(valor_original, valor)
                * (1 - p_desconto_percentual / 100),
            2
        ),
        titulo = CASE
            WHEN p_desconto_percentual > 0
                THEN regexp_replace(titulo, ' - Desconto [0-9]+([.][0-9]+)?%', '')
                     || format(' - Desconto %s%%', p_desconto_percentual)
            ELSE regexp_replace(titulo, ' - Desconto [0-9]+([.][0-9]+)?%', '')
        END
    WHERE contrato_id = p_contrato_id
      AND tipo = 'receita'
      AND titulo ILIKE 'Aluguel %'
      AND status IN ('pendente', 'atrasado')
      AND comprovante_url IS NULL;
END;
$$;

REVOKE ALL ON FUNCTION public.fn_aplicar_desconto_contrato_recorrente(
    UUID, NUMERIC, TEXT
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_aplicar_desconto_contrato_recorrente(
    UUID, NUMERIC, TEXT
) TO authenticated, service_role;

-- Keep clients that still call the original RPC from creating rent before approval.
CREATE OR REPLACE FUNCTION public.fn_criar_contrato_locacao(
    p_motorista_id UUID,
    p_veiculo_id UUID,
    p_numero_contrato VARCHAR,
    p_data_inicio DATE,
    p_valor_locacao NUMERIC,
    p_valor_caucao NUMERIC,
    p_frequencia public.frequencia_cobranca_enum,
    p_dia_vencimento INT,
    p_categoria_receita_id UUID,
    p_operador_id UUID
) RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, auth
AS $$
    SELECT public.fn_criar_contrato_locacao_v2(
        p_motorista_id,
        p_veiculo_id,
        p_numero_contrato,
        p_data_inicio,
        (p_data_inicio + INTERVAL '1 year')::DATE,
        p_valor_locacao,
        p_valor_caucao,
        p_frequencia,
        CASE
            WHEN p_frequencia IN ('semanal', 'quinzenal')
                 AND p_dia_vencimento NOT BETWEEN 1 AND 7
                THEN EXTRACT(ISODOW FROM p_data_inicio)::INT
            ELSE p_dia_vencimento
        END,
        p_categoria_receita_id,
        p_operador_id
    );
$$;

REVOKE ALL ON FUNCTION public.fn_criar_contrato_locacao(
    UUID, UUID, VARCHAR, DATE, NUMERIC, NUMERIC,
    public.frequencia_cobranca_enum, INT, UUID, UUID
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_criar_contrato_locacao(
    UUID, UUID, VARCHAR, DATE, NUMERIC, NUMERIC,
    public.frequencia_cobranca_enum, INT, UUID, UUID
) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.fn_finalizar_atribuicao_contrato()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF OLD.status = 'ativo' AND NEW.status IN ('concluido', 'cancelado') THEN
        NEW.data_fim := CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_finalizar_atribuicao_contrato ON public.contratos;
CREATE TRIGGER trg_finalizar_atribuicao_contrato
BEFORE UPDATE OF status ON public.contratos
FOR EACH ROW
EXECUTE FUNCTION public.fn_finalizar_atribuicao_contrato();

CREATE OR REPLACE FUNCTION public.fn_cancelar_cobrancas_futuras_contrato()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF OLD.status = 'ativo' AND NEW.status IN ('concluido', 'cancelado') THEN
        UPDATE public.lancamentos_financeiros
        SET status = 'cancelado'
        WHERE contrato_id = NEW.id
          AND tipo = 'receita'
          AND status IN ('pendente', 'atrasado')
          AND data_vencimento > NEW.data_fim;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_cancelar_cobrancas_futuras_contrato ON public.contratos;
CREATE TRIGGER trg_cancelar_cobrancas_futuras_contrato
AFTER UPDATE OF status ON public.contratos
FOR EACH ROW
EXECUTE FUNCTION public.fn_cancelar_cobrancas_futuras_contrato();

CREATE OR REPLACE FUNCTION public.fn_iniciar_cobranca_apos_vistoria_aprovada()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_contrato public.contratos%ROWTYPE;
    v_data_inicio DATE := CURRENT_DATE;
    v_data_fim DATE;
    v_vencimento DATE;
    v_proximo_mes DATE;
    v_ultimo_dia DATE;
    v_frequencia_label TEXT;
    v_parcela INT := 1;
BEGIN
    IF NEW.tipo <> 'check_in'
       OR NEW.status <> 'aprovado'
       OR (TG_OP = 'UPDATE' AND OLD.status = 'aprovado') THEN
        RETURN NEW;
    END IF;

    SELECT *
    INTO v_contrato
    FROM public.contratos
    WHERE id = NEW.contrato_id
    FOR UPDATE;

    IF NOT FOUND
       OR v_contrato.status <> 'ativo'
       OR v_contrato.motorista_id <> NEW.motorista_id
       OR v_contrato.veiculo_id <> NEW.veiculo_id
       OR v_contrato.cobranca_iniciada_em IS NOT NULL THEN
        RETURN NEW;
    END IF;

    v_data_fim := COALESCE(v_contrato.data_fim, v_data_inicio + INTERVAL '1 year');
    IF v_data_fim < v_data_inicio THEN
        UPDATE public.contratos
        SET cobranca_iniciada_em = now()
        WHERE id = v_contrato.id;
        RETURN NEW;
    END IF;

    UPDATE public.contratos
    SET cobranca_iniciada_em = now()
    WHERE id = v_contrato.id;

    v_frequencia_label := CASE v_contrato.frequencia_cobranca
        WHEN 'semanal' THEN 'Semanal'
        WHEN 'quinzenal' THEN 'Quinzenal'
        WHEN 'mensal' THEN 'Mensal'
    END;
    v_vencimento := v_data_inicio;
    IF v_contrato.frequencia_cobranca IN ('semanal', 'quinzenal') THEN
        WHILE EXTRACT(ISODOW FROM v_vencimento)::INT <> v_contrato.dia_vencimento LOOP
            v_vencimento := v_vencimento + 1;
        END LOOP;
    ELSE
        v_proximo_mes := date_trunc('month', v_data_inicio)::DATE;
        v_ultimo_dia := (v_proximo_mes + INTERVAL '1 month - 1 day')::DATE;
        v_vencimento := make_date(
            EXTRACT(YEAR FROM v_proximo_mes)::INT,
            EXTRACT(MONTH FROM v_proximo_mes)::INT,
            LEAST(v_contrato.dia_vencimento, EXTRACT(DAY FROM v_ultimo_dia)::INT)
        );
        IF v_vencimento < v_data_inicio THEN
            v_proximo_mes := (v_proximo_mes + INTERVAL '1 month')::DATE;
            v_ultimo_dia := (v_proximo_mes + INTERVAL '1 month - 1 day')::DATE;
            v_vencimento := make_date(
                EXTRACT(YEAR FROM v_proximo_mes)::INT,
                EXTRACT(MONTH FROM v_proximo_mes)::INT,
                LEAST(v_contrato.dia_vencimento, EXTRACT(DAY FROM v_ultimo_dia)::INT)
            );
        END IF;
    END IF;

    WHILE v_vencimento <= v_data_fim LOOP
        INSERT INTO public.lancamentos_financeiros (
            categoria_id,
            contrato_id,
            motorista_id,
            veiculo_id,
            criado_por,
            tipo,
            titulo,
            valor,
            valor_original,
            desconto_percentual,
            motivo_desconto,
            data_vencimento,
            status
        )
        SELECT
            '10000000-0000-0000-0000-000000000002',
            v_contrato.id,
            v_contrato.motorista_id,
            v_contrato.veiculo_id,
            NEW.vistoriador_id,
            'receita',
            format(
                'Aluguel %s - Contrato %s - Parcela %s%s',
                v_frequencia_label,
                v_contrato.numero_contrato,
                v_parcela,
                CASE WHEN v_contrato.desconto_percentual > 0
                    THEN format(' - Desconto %s%%', v_contrato.desconto_percentual)
                    ELSE ''
                END
            ),
            ROUND(
                v_contrato.valor_locacao
                    * (1 - v_contrato.desconto_percentual / 100),
                2
            ),
            v_contrato.valor_locacao,
            v_contrato.desconto_percentual,
            v_contrato.motivo_desconto,
            v_vencimento,
            'pendente'
        WHERE NOT EXISTS (
            SELECT 1
            FROM public.lancamentos_financeiros lf
            WHERE lf.contrato_id = v_contrato.id
              AND lf.tipo = 'receita'
              AND lf.data_vencimento = v_vencimento
              AND lf.titulo LIKE 'Aluguel %'
        );

        v_parcela := v_parcela + 1;

        IF v_contrato.frequencia_cobranca = 'semanal' THEN
            v_vencimento := v_vencimento + 7;
        ELSIF v_contrato.frequencia_cobranca = 'quinzenal' THEN
            v_vencimento := v_vencimento + 14;
        ELSE
            v_proximo_mes := (date_trunc('month', v_vencimento) + INTERVAL '1 month')::DATE;
            v_ultimo_dia := (v_proximo_mes + INTERVAL '1 month - 1 day')::DATE;
            v_vencimento := make_date(
                EXTRACT(YEAR FROM v_proximo_mes)::INT,
                EXTRACT(MONTH FROM v_proximo_mes)::INT,
                LEAST(v_contrato.dia_vencimento, EXTRACT(DAY FROM v_ultimo_dia)::INT)
            );
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_iniciar_cobranca_apos_vistoria_aprovada ON public.vistorias;
CREATE TRIGGER trg_iniciar_cobranca_apos_vistoria_aprovada
AFTER INSERT OR UPDATE OF status ON public.vistorias
FOR EACH ROW
EXECUTE FUNCTION public.fn_iniciar_cobranca_apos_vistoria_aprovada();

CREATE OR REPLACE FUNCTION public.fn_validar_lancamento_vinculado_contrato()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_contrato public.contratos%ROWTYPE;
BEGIN
    IF NEW.contrato_id IS NULL
       OR NEW.tipo <> 'receita'
       OR NEW.titulo NOT ILIKE 'Aluguel %' THEN
        RETURN NEW;
    END IF;

    SELECT *
    INTO v_contrato
    FROM public.contratos
    WHERE id = NEW.contrato_id;

    IF NOT FOUND OR v_contrato.status <> 'ativo' THEN
        RAISE EXCEPTION 'Não é possível criar cobranças para um contrato encerrado.';
    END IF;

    IF v_contrato.data_fim IS NOT NULL
       AND NEW.data_vencimento > v_contrato.data_fim THEN
        RAISE EXCEPTION 'O vencimento não pode ultrapassar o fim do contrato.';
    END IF;

    IF v_contrato.cobranca_iniciada_em IS NULL THEN
        RAISE EXCEPTION 'A cobrança de aluguel começa somente após a aprovação da vistoria de entrada.';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validar_lancamento_vinculado_contrato
    ON public.lancamentos_financeiros;
CREATE TRIGGER trg_validar_lancamento_vinculado_contrato
BEFORE INSERT ON public.lancamentos_financeiros
FOR EACH ROW
EXECUTE FUNCTION public.fn_validar_lancamento_vinculado_contrato();

CREATE OR REPLACE VIEW public.vw_extrato_completo_motorista AS
SELECT
    lf.id AS lancamento_id,
    lf.motorista_id,
    p.nome AS motorista_nome,
    lf.contrato_id,
    c.numero_contrato,
    v.placa AS veiculo_placa,
    v.modelo AS veiculo_modelo,
    cat.nome AS categoria_nome,
    lf.tipo,
    lf.titulo,
    lf.valor,
    lf.data_vencimento,
    lf.data_pagamento,
    lf.status,
    lf.metodo_pagamento,
    lf.pix_copia_cola,
    lf.comprovante_url,
    lf.criado_em,
    lf.valor_original,
    lf.desconto_percentual,
    lf.motivo_desconto
FROM public.lancamentos_financeiros lf
LEFT JOIN public.motoristas m ON m.id = lf.motorista_id
LEFT JOIN public.perfis p ON p.id = m.id
LEFT JOIN public.contratos c ON c.id = lf.contrato_id
LEFT JOIN public.veiculos v ON v.id = lf.veiculo_id
LEFT JOIN public.categorias_despesa cat ON cat.id = lf.categoria_id;

UPDATE public.contratos c
SET cobranca_iniciada_em = (
    SELECT MIN(v.criado_em)
    FROM public.vistorias v
    WHERE v.contrato_id = c.id
      AND v.tipo = 'check_in'
      AND v.status = 'aprovado'
)
WHERE c.status = 'ativo'
  AND c.cobranca_iniciada_em IS NULL
  AND EXISTS (
      SELECT 1
      FROM public.vistorias v
      WHERE v.contrato_id = c.id
        AND v.tipo = 'check_in'
        AND v.status = 'aprovado'
  );

UPDATE public.lancamentos_financeiros lf
SET status = 'cancelado'
FROM public.contratos c
WHERE lf.contrato_id = c.id
  AND lf.tipo = 'receita'
  AND lf.titulo ILIKE 'Aluguel %'
  AND lf.status IN ('pendente', 'atrasado')
  AND lf.data_vencimento > CASE
      WHEN c.status = 'ativo' AND c.cobranca_iniciada_em IS NOT NULL
          THEN COALESCE(c.data_fim, CURRENT_DATE)
      ELSE CURRENT_DATE
  END;

-- Recurring charges are created only by the approved check-in trigger.
REVOKE EXECUTE ON FUNCTION public.fn_gerar_parcelas_contrato(
    UUID, NUMERIC, VARCHAR, INT, DATE, INT
) FROM PUBLIC, authenticated, service_role;
