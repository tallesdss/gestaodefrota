-- Criação da tabela pagamentos_gestores
CREATE TABLE IF NOT EXISTS public.pagamentos_gestores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gestor_id UUID NOT NULL REFERENCES public.gestores(id) ON DELETE CASCADE,
    valor_salario NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    valor_comissao NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    mes_referencia VARCHAR(7) NOT NULL, -- formato YYYY-MM
    status VARCHAR(20) NOT NULL DEFAULT 'pendente', -- 'pendente', 'pago'
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices para otimizar busca
CREATE INDEX IF NOT EXISTS idx_pagamentos_gestores_gestor ON public.pagamentos_gestores(gestor_id);
CREATE INDEX IF NOT EXISTS idx_pagamentos_gestores_mes ON public.pagamentos_gestores(mes_referencia);

-- Trigger para atualizar `atualizado_em` (assumindo que a função fn_atualizado_em existe)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_pagamentos_gestores_atualizado_em') THEN
        CREATE TRIGGER trg_pagamentos_gestores_atualizado_em
        BEFORE UPDATE ON public.pagamentos_gestores
        FOR EACH ROW
        EXECUTE FUNCTION public.fn_atualizado_em();
    END IF;
END
$$;

-- RLS (Row Level Security)
ALTER TABLE public.pagamentos_gestores ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    DROP POLICY IF EXISTS "Acesso total aos pagamentos_gestores para admin" ON public.pagamentos_gestores;
    CREATE POLICY "Acesso total aos pagamentos_gestores para admin" ON public.pagamentos_gestores
        FOR ALL
        USING (
            EXISTS (
                SELECT 1 FROM public.perfis
                WHERE perfis.id = auth.uid() AND perfis.cargo = 'admin'
            )
        );

    DROP POLICY IF EXISTS "Leitura dos proprios pagamentos para gestor" ON public.pagamentos_gestores;
    CREATE POLICY "Leitura dos proprios pagamentos para gestor" ON public.pagamentos_gestores
        FOR SELECT
        USING (gestor_id = auth.uid());
END
$$;
