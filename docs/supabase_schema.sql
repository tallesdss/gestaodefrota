-- ==============================================================================
-- 🏛️ GESTÃO DE FROTA PREMIUM — SCHEMA DDL RELACIONAL SUPABASE (POSTGRESQL 17)
-- ==============================================================================
-- Nomenclatura: Português (snake_case)
-- Arquitetura: 100% Relacional (3FN), Foreign Keys Rígidas, Triggers, Views & RLS
-- ==============================================================================

-- 1. EXTENSÕES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. TIPOS ENUM
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_perfil_enum') THEN
        CREATE TYPE tipo_perfil_enum AS ENUM ('admin', 'gestor', 'motorista');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_motorista_enum') THEN
        CREATE TYPE status_motorista_enum AS ENUM ('pendente_aprovacao', 'ativo', 'bloqueado', 'inativo');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_veiculo_enum') THEN
        CREATE TYPE status_veiculo_enum AS ENUM ('disponivel', 'alugado', 'manutencao', 'inativo', 'vendido');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_ipva_enum') THEN
        CREATE TYPE status_ipva_enum AS ENUM ('pago', 'pendente', 'atrasado', 'isento');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_contrato_enum') THEN
        CREATE TYPE status_contrato_enum AS ENUM ('ativo', 'concluido', 'cancelado', 'inadimplente');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'frequencia_cobranca_enum') THEN
        CREATE TYPE frequencia_cobranca_enum AS ENUM ('semanal', 'quinzenal', 'mensal');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_vistoria_enum') THEN
        CREATE TYPE tipo_vistoria_enum AS ENUM ('check_in', 'check_out', 'rotina');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_vistoria_enum') THEN
        CREATE TYPE status_vistoria_enum AS ENUM ('pendente_revisao', 'aprovado', 'rejeitado');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_foto_vistoria_enum') THEN
        CREATE TYPE tipo_foto_vistoria_enum AS ENUM ('frente', 'traseira', 'lateral_esquerda', 'lateral_direita', 'painel', 'hodometro', 'bancos', 'avaria', 'outro');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_categoria_enum') THEN
        CREATE TYPE tipo_categoria_enum AS ENUM ('receita', 'despesa');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_lancamento_enum') THEN
        CREATE TYPE tipo_lancamento_enum AS ENUM ('receita', 'despesa');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_financeiro_enum') THEN
        CREATE TYPE status_financeiro_enum AS ENUM ('pendente', 'pago', 'atrasado', 'cancelado');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'metodo_pagamento_enum') THEN
        CREATE TYPE metodo_pagamento_enum AS ENUM ('pix', 'boleto', 'transferencia', 'dinheiro', 'cartao_credito');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_oficina_enum') THEN
        CREATE TYPE status_oficina_enum AS ENUM ('ativo', 'suspenso', 'inativo');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_manutencao_enum') THEN
        CREATE TYPE tipo_manutencao_enum AS ENUM ('preventiva', 'corretiva', 'revisao_geral', 'funilaria', 'pneus', 'eletrica', 'outro');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_manutencao_enum') THEN
        CREATE TYPE status_manutencao_enum AS ENUM ('agendado', 'em_andamento', 'concluido', 'cancelado');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_chave_pix_enum') THEN
        CREATE TYPE tipo_chave_pix_enum AS ENUM ('cpf', 'cnpj', 'email', 'telefone', 'aleatoria');
    END IF;
END $$;

-- 3. FUNÇÃO BASE PARA ATUALIZAÇÃO DE TIMESTAMPS
CREATE OR REPLACE FUNCTION public.fn_atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- 4. TABELAS DE IDENTIDADE, PERFIS & RBAC
-- ==============================================================================

-- 4.1. Perfis (1:1 com auth.users)
CREATE TABLE IF NOT EXISTS public.perfis (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    foto_url TEXT,
    cargo tipo_perfil_enum NOT NULL DEFAULT 'motorista',
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_perfis_atualizado_em
BEFORE UPDATE ON public.perfis
FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_timestamp();

-- 4.2. Motoristas (1:1 Especialização de perfis)
CREATE TABLE IF NOT EXISTS public.motoristas (
    id UUID PRIMARY KEY REFERENCES public.perfis(id) ON DELETE CASCADE,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    numero_cnh VARCHAR(20) UNIQUE NOT NULL,
    categoria_cnh VARCHAR(5) NOT NULL,
    validade_cnh DATE NOT NULL,
    cnh_frente_url TEXT,
    cnh_verso_url TEXT,
    comprovante_residencia_url TEXT,
    logradouro VARCHAR(150),
    numero VARCHAR(20),
    complemento VARCHAR(50),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    status status_motorista_enum NOT NULL DEFAULT 'pendente_aprovacao',
    pontuacao_confianca INT NOT NULL DEFAULT 100 CHECK (pontuacao_confianca BETWEEN 0 AND 100),
    valor_total_gerado NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (valor_total_gerado >= 0),
    saldo_devedor NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (saldo_devedor >= 0),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_motoristas_atualizado_em
BEFORE UPDATE ON public.motoristas
FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_timestamp();

-- 4.3. Gestores (1:1 Especialização de perfis)
CREATE TABLE IF NOT EXISTS public.gestores (
    id UUID PRIMARY KEY REFERENCES public.perfis(id) ON DELETE CASCADE,
    salario_base NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (salario_base >= 0),
    percentual_comissao NUMERIC(5,2) NOT NULL DEFAULT 0.00 CHECK (percentual_comissao BETWEEN 0 AND 100),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_gestores_atualizado_em
BEFORE UPDATE ON public.gestores
FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_timestamp();

-- 4.4. Dicionário de Permissões
CREATE TABLE IF NOT EXISTS public.permissoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    modulo VARCHAR(50) NOT NULL,
    descricao TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4.5. Tabela Associativa Gestor-Permissões (N:N)
CREATE TABLE IF NOT EXISTS public.gestor_permissoes (
    gestor_id UUID NOT NULL REFERENCES public.gestores(id) ON DELETE CASCADE,
    permissao_id UUID NOT NULL REFERENCES public.permissoes(id) ON DELETE CASCADE,
    concedido_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (gestor_id, permissao_id)
);

-- ==============================================================================
-- 5. TABELAS DE FROTA & CONTRATOS
-- ==============================================================================

-- 5.1. Veículos
CREATE TABLE IF NOT EXISTS public.veiculos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    placa VARCHAR(10) UNIQUE NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(80) NOT NULL,
    ano_fabricacao INT NOT NULL CHECK (ano_fabricacao >= 1990),
    ano_modelo INT NOT NULL CHECK (ano_modelo >= ano_fabricacao),
    cor VARCHAR(30) NOT NULL,
    renavam VARCHAR(30) UNIQUE,
    chassi VARCHAR(30) UNIQUE,
    km_atual INT NOT NULL DEFAULT 0 CHECK (km_atual >= 0),
    status status_veiculo_enum NOT NULL DEFAULT 'disponivel',
    crlv_url TEXT,
    numero_apolice_seguro VARCHAR(100),
    seguradora VARCHAR(100),
    vencimento_seguro DATE,
    status_ipva status_ipva_enum NOT NULL DEFAULT 'pendente',
    valor_ipva NUMERIC(10,2) CHECK (valor_ipva >= 0),
    vencimento_ipva DATE,
    financiamento_total_parcelas INT NOT NULL DEFAULT 0 CHECK (financiamento_total_parcelas >= 0),
    financiamento_parcelas_pagas INT NOT NULL DEFAULT 0 CHECK (financiamento_parcelas_pagas >= 0),
    financiamento_valor_parcela NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (financiamento_valor_parcela >= 0),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_financiamento_parcelas CHECK (financiamento_parcelas_pagas <= financiamento_total_parcelas)
);

CREATE TRIGGER trg_veiculos_atualizado_em
BEFORE UPDATE ON public.veiculos
FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_timestamp();

-- 5.2. Contratos de Locação
CREATE TABLE IF NOT EXISTS public.contratos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_contrato VARCHAR(50) UNIQUE NOT NULL,
    motorista_id UUID NOT NULL REFERENCES public.motoristas(id) ON DELETE RESTRICT,
    veiculo_id UUID NOT NULL REFERENCES public.veiculos(id) ON DELETE RESTRICT,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    valor_locacao NUMERIC(10,2) NOT NULL CHECK (valor_locacao > 0),
    valor_caucao NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (valor_caucao >= 0),
    frequencia_cobranca frequencia_cobranca_enum NOT NULL DEFAULT 'semanal',
    dia_vencimento INT NOT NULL CHECK (dia_vencimento BETWEEN 1 AND 31),
    status status_contrato_enum NOT NULL DEFAULT 'ativo',
    assinatura_digital_url TEXT,
    assinado_em TIMESTAMPTZ,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_contrato_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

CREATE TRIGGER trg_contratos_atualizado_em
BEFORE UPDATE ON public.contratos
FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_timestamp();

-- ==============================================================================
-- 6. TABELAS DE VISTORIAS & CHECKLIST
-- ==============================================================================

-- 6.1. Vistorias Mestres
CREATE TABLE IF NOT EXISTS public.vistorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contrato_id UUID NOT NULL REFERENCES public.contratos(id) ON DELETE RESTRICT,
    veiculo_id UUID NOT NULL REFERENCES public.veiculos(id) ON DELETE RESTRICT,
    motorista_id UUID NOT NULL REFERENCES public.motoristas(id) ON DELETE RESTRICT,
    vistoriador_id UUID REFERENCES public.perfis(id) ON DELETE SET NULL,
    tipo tipo_vistoria_enum NOT NULL,
    odometro_km INT NOT NULL CHECK (odometro_km >= 0),
    nivel_combustivel NUMERIC(3,2) NOT NULL CHECK (nivel_combustivel BETWEEN 0.00 AND 1.00),
    tem_avaria_nova BOOLEAN NOT NULL DEFAULT FALSE,
    status status_vistoria_enum NOT NULL DEFAULT 'pendente_revisao',
    motivo_revisao TEXT,
    observacoes TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6.2. Fotos de Vistoria (Filha 1:N de vistorias)
CREATE TABLE IF NOT EXISTS public.fotos_vistoria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vistoria_id UUID NOT NULL REFERENCES public.vistorias(id) ON DELETE CASCADE,
    tipo_foto tipo_foto_vistoria_enum NOT NULL,
    url_foto TEXT NOT NULL,
    tem_avaria BOOLEAN NOT NULL DEFAULT FALSE,
    descricao_avaria TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6.3. Itens de Checklist da Vistoria (Filha 1:N de vistorias)
CREATE TABLE IF NOT EXISTS public.itens_checklist_vistoria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vistoria_id UUID NOT NULL REFERENCES public.vistorias(id) ON DELETE CASCADE,
    item_nome VARCHAR(100) NOT NULL,
    conforme BOOLEAN NOT NULL DEFAULT TRUE,
    observacao TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==============================================================================
-- 7. TABELAS DE OFICINAS, MANUTENÇÕES & PEÇAS
-- ==============================================================================

-- 7.1. Oficinas Credenciadas
CREATE TABLE IF NOT EXISTS public.oficinas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    nome_fantasia VARCHAR(150) NOT NULL,
    razao_social VARCHAR(150),
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    endereco TEXT,
    banco_nome VARCHAR(80),
    agencia VARCHAR(20),
    conta_corrente VARCHAR(30),
    tipo_chave_pix tipo_chave_pix_enum,
    chave_pix VARCHAR(100),
    avaliacao NUMERIC(2,1) NOT NULL DEFAULT 5.0 CHECK (avaliacao BETWEEN 1.0 AND 5.0),
    status status_oficina_enum NOT NULL DEFAULT 'ativo',
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_oficinas_atualizado_em
BEFORE UPDATE ON public.oficinas
FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_timestamp();

-- 7.2. Categorias de Despesas / Plano de Contas (Hierárquica)
CREATE TABLE IF NOT EXISTS public.categorias_despesa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    categoria_pai_id UUID REFERENCES public.categorias_despesa(id) ON DELETE SET NULL,
    nome VARCHAR(100) NOT NULL,
    tipo tipo_categoria_enum NOT NULL,
    codigo_contabil VARCHAR(20),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7.3. Manutenções
CREATE TABLE IF NOT EXISTS public.manutencoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    veiculo_id UUID NOT NULL REFERENCES public.veiculos(id) ON DELETE RESTRICT,
    oficina_id UUID NOT NULL REFERENCES public.oficinas(id) ON DELETE RESTRICT,
    categoria_id UUID NOT NULL REFERENCES public.categorias_despesa(id) ON DELETE RESTRICT,
    tipo_manutencao tipo_manutencao_enum NOT NULL DEFAULT 'preventiva',
    descricao TEXT NOT NULL,
    odometro_km INT NOT NULL CHECK (odometro_km >= 0),
    data_servico DATE NOT NULL,
    custo_mao_de_obra NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (custo_mao_de_obra >= 0),
    custo_pecas NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (custo_pecas >= 0),
    custo_total NUMERIC(10,2) NOT NULL CHECK (custo_total >= 0),
    nota_fiscal_nfe_url TEXT,
    comprovante_url TEXT,
    status status_manutencao_enum NOT NULL DEFAULT 'agendado',
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_manutencao_custo CHECK (custo_total = (custo_mao_de_obra + custo_pecas))
);

CREATE TRIGGER trg_manutencoes_atualizado_em
BEFORE UPDATE ON public.manutencoes
FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_timestamp();

-- 7.4. Itens de Peças e Serviços da Manutenção (Filha 1:N de manutencoes)
CREATE TABLE IF NOT EXISTS public.itens_manutencao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    manutencao_id UUID NOT NULL REFERENCES public.manutencoes(id) ON DELETE CASCADE,
    descricao_peca VARCHAR(150) NOT NULL,
    quantidade INT NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    valor_unitario NUMERIC(10,2) NOT NULL CHECK (valor_unitario >= 0),
    valor_total NUMERIC(10,2) GENERATED ALWAYS AS (quantidade * valor_unitario) STORED,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==============================================================================
-- 8. TABELA FINANCEIRA & LIVRO-RAZÃO
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.lancamentos_financeiros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    categoria_id UUID NOT NULL REFERENCES public.categorias_despesa(id) ON DELETE RESTRICT,
    contrato_id UUID REFERENCES public.contratos(id) ON DELETE SET NULL,
    motorista_id UUID REFERENCES public.motoristas(id) ON DELETE SET NULL,
    veiculo_id UUID REFERENCES public.veiculos(id) ON DELETE SET NULL,
    criado_por UUID REFERENCES public.perfis(id) ON DELETE SET NULL,
    tipo tipo_lancamento_enum NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    valor NUMERIC(12,2) NOT NULL CHECK (valor > 0),
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status status_financeiro_enum NOT NULL DEFAULT 'pendente',
    metodo_pagamento metodo_pagamento_enum NOT NULL DEFAULT 'pix',
    pix_copia_cola TEXT,
    pix_qr_code_url TEXT,
    comprovante_url TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_financeiro_pago CHECK (status != 'pago' OR data_pagamento IS NOT NULL)
);

CREATE TRIGGER trg_lancamentos_atualizado_em
BEFORE UPDATE ON public.lancamentos_financeiros
FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_timestamp();

-- ==============================================================================
-- 9. HISTÓRICO & AUDITORIA DE ATIVIDADES
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.historico_atividades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    motorista_id UUID NOT NULL REFERENCES public.motoristas(id) ON DELETE CASCADE,
    veiculo_id UUID REFERENCES public.veiculos(id) ON DELETE SET NULL,
    autor_id UUID REFERENCES public.perfis(id) ON DELETE SET NULL,
    tipo_evento VARCHAR(50) NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==============================================================================
-- 10. ÍNDICES RELACIONAIS (OTIMIZAÇÃO DE JOINS & BUSCAS)
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_contratos_motorista ON public.contratos(motorista_id);
CREATE INDEX IF NOT EXISTS idx_contratos_veiculo ON public.contratos(veiculo_id);
CREATE INDEX IF NOT EXISTS idx_contratos_status ON public.contratos(status);

CREATE INDEX IF NOT EXISTS idx_vistorias_contrato ON public.vistorias(contrato_id);
CREATE INDEX IF NOT EXISTS idx_vistorias_veiculo ON public.vistorias(veiculo_id);
CREATE INDEX IF NOT EXISTS idx_vistorias_motorista ON public.vistorias(motorista_id);
CREATE INDEX IF NOT EXISTS idx_fotos_vistoria_pai ON public.fotos_vistoria(vistoria_id);
CREATE INDEX IF NOT EXISTS idx_checklist_vistoria_pai ON public.itens_checklist_vistoria(vistoria_id);

CREATE INDEX IF NOT EXISTS idx_manutencoes_veiculo ON public.manutencoes(veiculo_id);
CREATE INDEX IF NOT EXISTS idx_manutencoes_oficina ON public.manutencoes(oficina_id);
CREATE INDEX IF NOT EXISTS idx_manutencoes_categoria ON public.manutencoes(categoria_id);
CREATE INDEX IF NOT EXISTS idx_itens_manutencao_pai ON public.itens_manutencao(manutencao_id);

CREATE INDEX IF NOT EXISTS idx_lancamentos_categoria ON public.lancamentos_financeiros(categoria_id);
CREATE INDEX IF NOT EXISTS idx_lancamentos_contrato ON public.lancamentos_financeiros(contrato_id);
CREATE INDEX IF NOT EXISTS idx_lancamentos_motorista ON public.lancamentos_financeiros(motorista_id);
CREATE INDEX IF NOT EXISTS idx_lancamentos_veiculo ON public.lancamentos_financeiros(veiculo_id);
CREATE INDEX IF NOT EXISTS idx_lancamentos_status_vencimento ON public.lancamentos_financeiros(status, data_vencimento);

CREATE INDEX IF NOT EXISTS idx_gestor_permissoes_permissao ON public.gestor_permissoes(permissao_id);

-- ==============================================================================
-- 11. TRIGGERS PL/PGSQL DE INTEGRIDADE E CONSISTÊNCIA DE ESTADO
-- ==============================================================================

-- 11.1. Sincronizar KM do Veículo com Vistorias e Manutenções
CREATE OR REPLACE FUNCTION public.fn_sincronizar_km_veiculo()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.veiculos
    SET km_atual = GREATEST(km_atual, NEW.odometro_km),
        atualizado_em = now()
    WHERE id = NEW.veiculo_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_km_vistoria ON public.vistorias;
CREATE TRIGGER trg_km_vistoria
AFTER INSERT ON public.vistorias
FOR EACH ROW EXECUTE FUNCTION public.fn_sincronizar_km_veiculo();

DROP TRIGGER IF EXISTS trg_km_manutencao ON public.manutencoes;
CREATE TRIGGER trg_km_manutencao
AFTER INSERT ON public.manutencoes
FOR EACH ROW EXECUTE FUNCTION public.fn_sincronizar_km_veiculo();

-- 11.2. Sincronizar Status do Veículo com Ativação/Conclusão de Contrato
CREATE OR REPLACE FUNCTION public.fn_sincronizar_status_contrato()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' AND NEW.status = 'ativo') OR (TG_OP = 'UPDATE' AND NEW.status = 'ativo' AND OLD.status != 'ativo') THEN
        UPDATE public.veiculos SET status = 'alugado', atualizado_em = now() WHERE id = NEW.veiculo_id;
    ELSIF (TG_OP = 'UPDATE' AND NEW.status IN ('concluido', 'cancelado') AND OLD.status = 'ativo') THEN
        UPDATE public.veiculos SET status = 'disponivel', atualizado_em = now() WHERE id = NEW.veiculo_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_status_veiculo_contrato ON public.contratos;
CREATE TRIGGER trg_status_veiculo_contrato
AFTER INSERT OR UPDATE OF status ON public.contratos
FOR EACH ROW EXECUTE FUNCTION public.fn_sincronizar_status_contrato();

-- 11.3. Recalcular LTV e Saldo Devedor do Motorista
CREATE OR REPLACE FUNCTION public.fn_recalcular_totais_motorista()
RETURNS TRIGGER AS $$
DECLARE
    v_motorista_id UUID;
BEGIN
    v_motorista_id := COALESCE(NEW.motorista_id, OLD.motorista_id);
    IF v_motorista_id IS NOT NULL THEN
        UPDATE public.motoristas
        SET 
            valor_total_gerado = COALESCE((
                SELECT SUM(valor) FROM public.lancamentos_financeiros 
                WHERE motorista_id = v_motorista_id AND tipo = 'receita' AND status = 'pago'
            ), 0.00),
            saldo_devedor = COALESCE((
                SELECT SUM(valor) FROM public.lancamentos_financeiros 
                WHERE motorista_id = v_motorista_id AND tipo = 'receita' AND status IN ('pendente', 'atrasado')
            ), 0.00),
            atualizado_em = now()
        WHERE id = v_motorista_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_financeiro_motorista ON public.lancamentos_financeiros;
CREATE TRIGGER trg_financeiro_motorista
AFTER INSERT OR UPDATE OR DELETE ON public.lancamentos_financeiros
FOR EACH ROW EXECUTE FUNCTION public.fn_recalcular_totais_motorista();

-- 11.4. Trigger Automático no Cadastro do Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public, auth
LANGUAGE plpgsql AS $$
DECLARE
    v_cargo public.tipo_perfil_enum;
    v_nome TEXT;
    v_tel TEXT;
BEGIN
    -- Obter nome
    IF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'nome' IS NOT NULL THEN
        v_nome := NEW.raw_user_meta_data->>'nome';
    ELSE
        v_nome := 'Usuário ' || SUBSTRING(NEW.id::text, 1, 8);
    END IF;

    -- Obter telefone
    IF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'telefone' IS NOT NULL THEN
        v_tel := NEW.raw_user_meta_data->>'telefone';
    ELSE
        v_tel := NULL;
    END IF;

    -- Obter cargo
    v_cargo := 'motorista'::public.tipo_perfil_enum;
    IF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'cargo' IS NOT NULL THEN
        BEGIN
            v_cargo := (NEW.raw_user_meta_data->>'cargo')::public.tipo_perfil_enum;
        EXCEPTION WHEN OTHERS THEN
            v_cargo := 'motorista'::public.tipo_perfil_enum;
        END;
    END IF;

    -- Inserir em public.perfis
    INSERT INTO public.perfis (id, nome, email, telefone, cargo)
    VALUES (
        NEW.id,
        v_nome,
        COALESCE(NEW.email, NEW.id::text || '@temporario.com'),
        v_tel,
        v_cargo
    )
    ON CONFLICT (id) DO UPDATE 
    SET nome = EXCLUDED.nome,
        email = EXCLUDED.email,
        telefone = EXCLUDED.telefone,
        cargo = EXCLUDED.cargo,
        atualizado_em = now();

    -- Se for motorista, criar registro correspondente em public.motoristas se não existir
    IF v_cargo = 'motorista'::public.tipo_perfil_enum THEN
        INSERT INTO public.motoristas (
            id, cpf, numero_cnh, categoria_cnh, validade_cnh, status
        ) VALUES (
            NEW.id,
            COALESCE(NEW.raw_user_meta_data->>'cpf', '00000000000'),
            COALESCE(NEW.raw_user_meta_data->>'numero_cnh', '00000000000'),
            COALESCE(NEW.raw_user_meta_data->>'categoria_cnh', 'B'),
            CURRENT_DATE + INTERVAL '5 years',
            'ativo'::public.status_motorista_enum
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- Se for gestor, criar registro correspondente em public.gestores se não existir
    IF v_cargo = 'gestor'::public.tipo_perfil_enum THEN
        INSERT INTO public.gestores (id, salario_base, percentual_comissao, ativo)
        VALUES (NEW.id, 0.00, 0.00, true)
        ON CONFLICT (id) DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- 12. TRANSAÇÃO ATÔMICA RPC (ACID) — CRIAÇÃO DE CONTRATOS
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.fn_criar_contrato_locacao(
    p_motorista_id UUID,
    p_veiculo_id UUID,
    p_numero_contrato VARCHAR,
    p_data_inicio DATE,
    p_valor_locacao NUMERIC,
    p_valor_caucao NUMERIC,
    p_frequencia frequencia_cobranca_enum,
    p_dia_vencimento INT,
    p_categoria_receita_id UUID,
    p_operador_id UUID
) RETURNS UUID AS $$
DECLARE
    v_contrato_id UUID;
    v_veiculo_status status_veiculo_enum;
    v_motorista_status status_motorista_enum;
BEGIN
    -- 1. Validar Status do Veículo
    SELECT status INTO v_veiculo_status FROM public.veiculos WHERE id = p_veiculo_id FOR UPDATE;
    IF v_veiculo_status != 'disponivel' THEN
        RAISE EXCEPTION 'Veículo não está disponível para locação (Status atual: %)', v_veiculo_status;
    END IF;

    -- 2. Validar Status do Motorista
    SELECT status INTO v_motorista_status FROM public.motoristas WHERE id = p_motorista_id;
    IF v_motorista_status != 'ativo' THEN
        RAISE EXCEPTION 'Motorista não está ativo para iniciar contrato (Status atual: %)', v_motorista_status;
    END IF;

    -- 3. Inserir Contrato
    INSERT INTO public.contratos (
        numero_contrato, motorista_id, veiculo_id, data_inicio, 
        valor_locacao, valor_caucao, frequencia_cobranca, dia_vencimento, status
    ) VALUES (
        p_numero_contrato, p_motorista_id, p_veiculo_id, p_data_inicio,
        p_valor_locacao, p_valor_caucao, p_frequencia, p_dia_vencimento, 'ativo'
    ) RETURNING id INTO v_contrato_id;

    -- 4. Gerar Lançamento Financeiro de Caução (se > 0)
    IF p_valor_caucao > 0 THEN
        INSERT INTO public.lancamentos_financeiros (
            categoria_id, contrato_id, motorista_id, veiculo_id, criado_por,
            tipo, titulo, valor, data_vencimento, status
        ) VALUES (
            p_categoria_receita_id, v_contrato_id, p_motorista_id, p_veiculo_id, p_operador_id,
            'receita', 'Caução de Locação - Contrato ' || p_numero_contrato, p_valor_caucao, p_data_inicio, 'pendente'
        );
    END IF;

    -- 5. Gerar 1ª Mensalidade de Locação
    INSERT INTO public.lancamentos_financeiros (
        categoria_id, contrato_id, motorista_id, veiculo_id, criado_por,
        tipo, titulo, valor, data_vencimento, status
    ) VALUES (
        p_categoria_receita_id, v_contrato_id, p_motorista_id, p_veiculo_id, p_operador_id,
        'receita', '1ª Mensalidade - Contrato ' || p_numero_contrato, p_valor_locacao, p_data_inicio, 'pendente'
    );

    RETURN v_contrato_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 13. VIEWS RELACIONAIS ANALÍTICAS
-- ==============================================================================

-- 13.1. KPIs do Dashboard Master
CREATE OR REPLACE VIEW public.vw_kpis_dashboard_master AS
SELECT
    (SELECT COUNT(*) FROM public.veiculos) AS total_veiculos,
    (SELECT COUNT(*) FROM public.veiculos WHERE status = 'alugado') AS veiculos_alugados,
    (SELECT COUNT(*) FROM public.veiculos WHERE status = 'disponivel') AS veiculos_disponiveis,
    (SELECT COUNT(*) FROM public.veiculos WHERE status = 'manutencao') AS veiculos_manutencao,
    ROUND(
        (SELECT COUNT(*) FROM public.veiculos WHERE status = 'alugado')::NUMERIC / 
        NULLIF((SELECT COUNT(*) FROM public.veiculos), 0) * 100, 1
    ) AS taxa_ocupacao_percentual,
    (SELECT COUNT(*) FROM public.motoristas WHERE status = 'ativo') AS motoristas_ativos,
    (SELECT COUNT(*) FROM public.motoristas WHERE status = 'pendente_aprovacao') AS motoristas_pendentes,
    COALESCE((
        SELECT SUM(valor) FROM public.lancamentos_financeiros 
        WHERE tipo = 'receita' AND status = 'pago' 
          AND date_trunc('month', data_pagamento) = date_trunc('month', CURRENT_DATE)
    ), 0.00) AS receita_mes_atual,
    COALESCE((
        SELECT SUM(valor) FROM public.lancamentos_financeiros 
        WHERE tipo = 'despesa' AND status = 'pago' 
          AND date_trunc('month', data_pagamento) = date_trunc('month', CURRENT_DATE)
    ), 0.00) AS despesa_mes_atual,
    COALESCE((
        SELECT SUM(valor) FROM public.lancamentos_financeiros 
        WHERE tipo = 'receita' AND status = 'atrasado'
    ), 0.00) AS total_inadimplencia;

-- 13.2. Extrato Financeiro Consolidado
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
    lf.criado_em
FROM public.lancamentos_financeiros lf
LEFT JOIN public.motoristas m ON m.id = lf.motorista_id
LEFT JOIN public.perfis p ON p.id = m.id
LEFT JOIN public.contratos c ON c.id = lf.contrato_id
LEFT JOIN public.veiculos v ON v.id = lf.veiculo_id
LEFT JOIN public.categorias_despesa cat ON cat.id = lf.categoria_id;

-- ==============================================================================
-- 14. ROW LEVEL SECURITY (RLS) & POLICIES
-- ==============================================================================

ALTER TABLE public.perfis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.motoristas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gestores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gestor_permissoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.veiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vistorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fotos_vistoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_checklist_vistoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.oficinas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.manutencoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_manutencao ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias_despesa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lancamentos_financeiros ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.historico_atividades ENABLE ROW LEVEL SECURITY;

-- Funções Auxiliares de Perfil
CREATE OR REPLACE FUNCTION public.eh_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.perfis 
        WHERE id = auth.uid() AND cargo = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.eh_gestor_ou_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.perfis 
        WHERE id = auth.uid() AND cargo IN ('admin', 'gestor')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Políticas de Leitura e Escrita
DO $$ BEGIN
    -- Perfis
    DROP POLICY IF EXISTS "Perfis visualizaveis por usuarios autenticados" ON public.perfis;
    CREATE POLICY "Perfis visualizaveis por usuarios autenticados" ON public.perfis
    FOR SELECT TO authenticated USING (true);

    DROP POLICY IF EXISTS "Usuarios editam proprio perfil" ON public.perfis;
    CREATE POLICY "Usuarios editam proprio perfil" ON public.perfis
    FOR UPDATE TO authenticated USING (id = auth.uid() OR public.eh_admin());

    -- Veículos
    DROP POLICY IF EXISTS "Leitura de veiculos por autenticados" ON public.veiculos;
    CREATE POLICY "Leitura de veiculos por autenticados" ON public.veiculos
    FOR SELECT TO authenticated USING (true);

    DROP POLICY IF EXISTS "Gestao de veiculos por admin e gestor" ON public.veiculos;
    CREATE POLICY "Gestao de veiculos por admin e gestor" ON public.veiculos
    FOR ALL TO authenticated USING (public.eh_gestor_ou_admin());

    -- Contratos
    DROP POLICY IF EXISTS "Motorista visualiza seus contratos" ON public.contratos;
    CREATE POLICY "Motorista visualiza seus contratos" ON public.contratos
    FOR SELECT TO authenticated USING (motorista_id = auth.uid() OR public.eh_gestor_ou_admin());

    DROP POLICY IF EXISTS "Gestao de contratos por admin e gestor" ON public.contratos;
    CREATE POLICY "Gestao de contratos por admin e gestor" ON public.contratos
    FOR ALL TO authenticated USING (public.eh_gestor_ou_admin());

    -- Vistorias
    DROP POLICY IF EXISTS "Motorista visualiza suas vistorias" ON public.vistorias;
    CREATE POLICY "Motorista visualiza suas vistorias" ON public.vistorias
    FOR SELECT TO authenticated USING (motorista_id = auth.uid() OR public.eh_gestor_ou_admin());

    DROP POLICY IF EXISTS "Motorista insere vistorias proprias" ON public.vistorias;
    CREATE POLICY "Motorista insere vistorias proprias" ON public.vistorias
    FOR INSERT TO authenticated WITH CHECK (motorista_id = auth.uid() OR public.eh_gestor_ou_admin());

    DROP POLICY IF EXISTS "Gestao de vistorias por admin e gestor" ON public.vistorias;
    CREATE POLICY "Gestao de vistorias por admin e gestor" ON public.vistorias
    FOR UPDATE TO authenticated USING (public.eh_gestor_ou_admin());

    -- Fotos Vistoria
    DROP POLICY IF EXISTS "Fotos acessiveis via vistoria" ON public.fotos_vistoria;
    CREATE POLICY "Fotos acessiveis via vistoria" ON public.fotos_vistoria
    FOR SELECT TO authenticated USING (
        EXISTS (
            SELECT 1 FROM public.vistorias v 
            WHERE v.id = fotos_vistoria.vistoria_id 
              AND (v.motorista_id = auth.uid() OR public.eh_gestor_ou_admin())
        )
    );

    DROP POLICY IF EXISTS "Insercao de fotos de vistoria" ON public.fotos_vistoria;
    CREATE POLICY "Insercao de fotos de vistoria" ON public.fotos_vistoria
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.vistorias v 
            WHERE v.id = fotos_vistoria.vistoria_id 
              AND (v.motorista_id = auth.uid() OR public.eh_gestor_ou_admin())
        )
    );

    -- Itens Checklist Vistoria
    DROP POLICY IF EXISTS "Checklist acessivel via vistoria" ON public.itens_checklist_vistoria;
    CREATE POLICY "Checklist acessivel via vistoria" ON public.itens_checklist_vistoria
    FOR SELECT TO authenticated USING (
        EXISTS (
            SELECT 1 FROM public.vistorias v 
            WHERE v.id = itens_checklist_vistoria.vistoria_id 
              AND (v.motorista_id = auth.uid() OR public.eh_gestor_ou_admin())
        )
    );

    DROP POLICY IF EXISTS "Insercao de checklist de vistoria" ON public.itens_checklist_vistoria;
    CREATE POLICY "Insercao de checklist de vistoria" ON public.itens_checklist_vistoria
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.vistorias v 
            WHERE v.id = itens_checklist_vistoria.vistoria_id 
              AND (v.motorista_id = auth.uid() OR public.eh_gestor_ou_admin())
        )
    );

    -- Financeiro
    DROP POLICY IF EXISTS "Motorista visualiza seus lancamentos" ON public.lancamentos_financeiros;
    CREATE POLICY "Motorista visualiza seus lancamentos" ON public.lancamentos_financeiros
    FOR SELECT TO authenticated USING (motorista_id = auth.uid() OR public.eh_gestor_ou_admin());

    DROP POLICY IF EXISTS "Gestao financeira por admin e gestor" ON public.lancamentos_financeiros;
    CREATE POLICY "Gestao financeira por admin e gestor" ON public.lancamentos_financeiros
    FOR ALL TO authenticated USING (public.eh_gestor_ou_admin());

    -- Oficinas e Manutenções
    DROP POLICY IF EXISTS "Leitura de oficinas por autenticados" ON public.oficinas;
    CREATE POLICY "Leitura de oficinas por autenticados" ON public.oficinas
    FOR SELECT TO authenticated USING (true);

    DROP POLICY IF EXISTS "Gestao de oficinas por admin e gestor" ON public.oficinas;
    CREATE POLICY "Gestao de oficinas por admin e gestor" ON public.oficinas
    FOR ALL TO authenticated USING (public.eh_gestor_ou_admin());

    DROP POLICY IF EXISTS "Gestao de manutencoes por admin e gestor" ON public.manutencoes;
    CREATE POLICY "Gestao de manutencoes por admin e gestor" ON public.manutencoes
    FOR ALL TO authenticated USING (public.eh_gestor_ou_admin());

    DROP POLICY IF EXISTS "Gestao de itens de manutencao por admin e gestor" ON public.itens_manutencao;
    CREATE POLICY "Gestao de itens de manutencao por admin e gestor" ON public.itens_manutencao
    FOR ALL TO authenticated USING (public.eh_gestor_ou_admin());

    -- Categorias de Despesa
    DROP POLICY IF EXISTS "Leitura de categorias por autenticados" ON public.categorias_despesa;
    CREATE POLICY "Leitura de categorias por autenticados" ON public.categorias_despesa
    FOR SELECT TO authenticated USING (true);

    DROP POLICY IF EXISTS "Gestao de categorias por admin e gestor" ON public.categorias_despesa;
    CREATE POLICY "Gestao de categorias por admin e gestor" ON public.categorias_despesa
    FOR ALL TO authenticated USING (public.eh_gestor_ou_admin());
END $$;

-- ==============================================================================
-- 15. SEED INICIAL DE PLANO DE CONTAS & PERMISSÕES
-- ==============================================================================

-- 15.1. Categorias Contábeis Básicas
INSERT INTO public.categorias_despesa (id, nome, tipo, codigo_contabil, ativo) VALUES
    ('10000000-0000-0000-0000-000000000001', 'Receitas Operacionais', 'receita', '1.0', true),
    ('10000000-0000-0000-0000-000000000002', 'Locação Semanal', 'receita', '1.1', true),
    ('10000000-0000-0000-0000-000000000003', 'Caução de Locação', 'receita', '1.2', true),
    ('10000000-0000-0000-0000-000000000004', 'Taxas e Multas', 'receita', '1.3', true),
    ('20000000-0000-0000-0000-000000000001', 'Despesas com Veículos', 'despesa', '2.0', true),
    ('20000000-0000-0000-0000-000000000002', 'Manutenção Preventiva', 'despesa', '2.1', true),
    ('20000000-0000-0000-0000-000000000003', 'Manutenção Corretiva', 'despesa', '2.2', true),
    ('20000000-0000-0000-0000-000000000004', 'IPVA e Licenciamento', 'despesa', '2.3', true),
    ('20000000-0000-0000-0000-000000000005', 'Seguro da Frota', 'despesa', '2.4', true),
    ('20000000-0000-0000-0000-000000000006', 'Financiamento de Veículos', 'despesa', '2.5', true)
ON CONFLICT (id) DO NOTHING;

-- 15.2. Permissões Administrativas
INSERT INTO public.permissoes (id, codigo, nome, modulo, descricao) VALUES
    ('30000000-0000-0000-0000-000000000001', 'frota.gerenciar', 'Gerenciar Veículos', 'Frota', 'Cadastrar, editar e inativar veículos'),
    ('30000000-0000-0000-0000-000000000002', 'motoristas.auditar', 'Auditar Motoristas', 'Motoristas', 'Aprovar e bloquear cadastros'),
    ('30000000-0000-0000-0000-000000000003', 'contratos.gerenciar', 'Gerenciar Contratos', 'Contratos', 'Criar e rescindir contratos de locação'),
    ('30000000-0000-0000-0000-000000000004', 'vistorias.revisar', 'Revisar Vistorias', 'Vistorias', 'Aprovar ou reprovar laudos de vistoria'),
    ('30000000-0000-0000-0000-000000000005', 'financeiro.baixar', 'Baixa Manual de Recebimento', 'Financeiro', 'Confirmar recebimento de pagamentos'),
    ('30000000-0000-0000-0000-000000000006', 'oficinas.gerenciar', 'Gerenciar Oficinas', 'Manutenção', 'Cadastrar e gerenciar oficinas credenciadas')
ON CONFLICT (id) DO NOTHING;
