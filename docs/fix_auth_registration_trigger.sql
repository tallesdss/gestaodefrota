-- ==============================================================================
-- 🚀 ARQUITETURA UNIFICADA DE USUÁRIOS E PAPÉIS (RBAC COM FLAGS BOOLEANAS)
-- Todo usuário é um usuário base em `public.perfis`.
-- Papéis são definidos por flags booleanas: `is_admin`, `is_gestor`, `is_motorista`.
-- ==============================================================================

-- 1. Adicionar colunas de flags booleanas em public.perfis (se não existirem)
ALTER TABLE public.perfis 
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS is_gestor BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS is_motorista BOOLEAN NOT NULL DEFAULT TRUE;

-- 2. Sincronizar flags com os cargos existentes
UPDATE public.perfis 
SET is_admin = TRUE, is_gestor = TRUE, is_motorista = FALSE 
WHERE cargo = 'admin';

UPDATE public.perfis 
SET is_admin = FALSE, is_gestor = TRUE, is_motorista = FALSE 
WHERE cargo = 'gestor';

UPDATE public.perfis 
SET is_admin = FALSE, is_gestor = FALSE, is_motorista = TRUE 
WHERE cargo = 'motorista';

-- 3. Permitir valores NULL para CPF e CNH em public.motoristas (preenchidos no Onboarding)
ALTER TABLE public.motoristas ALTER COLUMN cpf DROP NOT NULL;
ALTER TABLE public.motoristas ALTER COLUMN numero_cnh DROP NOT NULL;
ALTER TABLE public.motoristas ALTER COLUMN validade_cnh DROP NOT NULL;
ALTER TABLE public.motoristas ALTER COLUMN categoria_cnh SET DEFAULT 'B';

-- 4. Limpar registros com '00000000000' ou vazios para liberar a constraint UNIQUE
UPDATE public.motoristas 
SET cpf = NULL 
WHERE cpf = '00000000000' OR cpf = '' OR cpf = '0';

UPDATE public.motoristas 
SET numero_cnh = NULL 
WHERE numero_cnh = '00000000000' OR numero_cnh = '' OR numero_cnh = '0';

-- 5. Atualizar a função handle_new_user() para inserção atômica e segura com flags
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public, auth
LANGUAGE plpgsql AS $$
DECLARE
    v_cargo public.tipo_perfil_enum;
    v_nome TEXT;
    v_tel TEXT;
    v_cpf TEXT;
    v_cnh TEXT;
    v_cat TEXT;
    v_is_admin BOOLEAN := FALSE;
    v_is_gestor BOOLEAN := FALSE;
    v_is_motorista BOOLEAN := TRUE;
BEGIN
    -- Obter nome
    IF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'nome' IS NOT NULL AND TRIM(NEW.raw_user_meta_data->>'nome') != '' THEN
        v_nome := TRIM(NEW.raw_user_meta_data->>'nome');
    ELSIF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'name' IS NOT NULL AND TRIM(NEW.raw_user_meta_data->>'name') != '' THEN
        v_nome := TRIM(NEW.raw_user_meta_data->>'name');
    ELSIF NEW.email IS NOT NULL THEN
        v_nome := SPLIT_PART(NEW.email, '@', 1);
    ELSE
        v_nome := 'Usuário ' || SUBSTRING(NEW.id::text, 1, 8);
    END IF;

    -- Obter telefone
    IF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'telefone' IS NOT NULL AND TRIM(NEW.raw_user_meta_data->>'telefone') != '' THEN
        v_tel := TRIM(NEW.raw_user_meta_data->>'telefone');
    ELSE
        v_tel := NULL;
    END IF;

    -- Obter cargo com fallback seguro
    v_cargo := 'motorista'::public.tipo_perfil_enum;
    IF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'cargo' IS NOT NULL THEN
        BEGIN
            v_cargo := (NEW.raw_user_meta_data->>'cargo')::public.tipo_perfil_enum;
        EXCEPTION WHEN OTHERS THEN
            v_cargo := 'motorista'::public.tipo_perfil_enum;
        END;
    END IF;

    -- Determinar flags booleanas de papel
    IF NEW.raw_user_meta_data IS NOT NULL AND (NEW.raw_user_meta_data->>'is_admin')::boolean IS NOT NULL THEN
        v_is_admin := (NEW.raw_user_meta_data->>'is_admin')::boolean;
    ELSE
        v_is_admin := (v_cargo = 'admin'::public.tipo_perfil_enum);
    END IF;

    IF NEW.raw_user_meta_data IS NOT NULL AND (NEW.raw_user_meta_data->>'is_gestor')::boolean IS NOT NULL THEN
        v_is_gestor := (NEW.raw_user_meta_data->>'is_gestor')::boolean;
    ELSE
        v_is_gestor := (v_cargo = 'gestor'::public.tipo_perfil_enum OR v_is_admin);
    END IF;

    IF NEW.raw_user_meta_data IS NOT NULL AND (NEW.raw_user_meta_data->>'is_motorista')::boolean IS NOT NULL THEN
        v_is_motorista := (NEW.raw_user_meta_data->>'is_motorista')::boolean;
    ELSE
        v_is_motorista := (v_cargo = 'motorista'::public.tipo_perfil_enum);
    END IF;

    -- Obter CPF e CNH se informados
    IF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'cpf' IS NOT NULL AND TRIM(NEW.raw_user_meta_data->>'cpf') != '' THEN
        v_cpf := TRIM(NEW.raw_user_meta_data->>'cpf');
    ELSE
        v_cpf := NULL;
    END IF;

    IF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'numero_cnh' IS NOT NULL AND TRIM(NEW.raw_user_meta_data->>'numero_cnh') != '' THEN
        v_cnh := TRIM(NEW.raw_user_meta_data->>'numero_cnh');
    ELSE
        v_cnh := NULL;
    END IF;

    IF NEW.raw_user_meta_data IS NOT NULL AND NEW.raw_user_meta_data->>'categoria_cnh' IS NOT NULL AND TRIM(NEW.raw_user_meta_data->>'categoria_cnh') != '' THEN
        v_cat := TRIM(NEW.raw_user_meta_data->>'categoria_cnh');
    ELSE
        v_cat := 'B';
    END IF;

    -- Inserir / atualizar em public.perfis
    BEGIN
        INSERT INTO public.perfis (id, nome, email, telefone, cargo, is_admin, is_gestor, is_motorista)
        VALUES (
            NEW.id,
            v_nome,
            COALESCE(NEW.email, NEW.id::text || '@temporario.com'),
            v_tel,
            v_cargo,
            v_is_admin,
            v_is_gestor,
            v_is_motorista
        )
        ON CONFLICT (id) DO UPDATE 
        SET nome = EXCLUDED.nome,
            email = EXCLUDED.email,
            telefone = COALESCE(EXCLUDED.telefone, public.perfis.telefone),
            cargo = EXCLUDED.cargo,
            is_admin = EXCLUDED.is_admin,
            is_gestor = EXCLUDED.is_gestor,
            is_motorista = EXCLUDED.is_motorista,
            atualizado_em = now();
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    -- Se for motorista (ou tiver a flag is_motorista = true), criar registro correspondente em public.motoristas se não existir
    IF v_is_motorista OR v_cargo = 'motorista'::public.tipo_perfil_enum THEN
        BEGIN
            INSERT INTO public.motoristas (
                id, cpf, numero_cnh, categoria_cnh, validade_cnh, status
            ) VALUES (
                NEW.id,
                v_cpf,
                v_cnh,
                v_cat,
                CURRENT_DATE + INTERVAL '5 years',
                'pendente_aprovacao'::public.status_motorista_enum
            )
            ON CONFLICT (id) DO UPDATE
            SET 
                cpf = COALESCE(EXCLUDED.cpf, public.motoristas.cpf),
                numero_cnh = COALESCE(EXCLUDED.numero_cnh, public.motoristas.numero_cnh),
                categoria_cnh = COALESCE(EXCLUDED.categoria_cnh, public.motoristas.categoria_cnh),
                atualizado_em = now();
        EXCEPTION WHEN OTHERS THEN
            BEGIN
                INSERT INTO public.motoristas (
                    id, cpf, numero_cnh, categoria_cnh, validade_cnh, status
                ) VALUES (
                    NEW.id,
                    NULL,
                    NULL,
                    'B',
                    CURRENT_DATE + INTERVAL '5 years',
                    'pendente_aprovacao'::public.status_motorista_enum
                )
                ON CONFLICT (id) DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                NULL;
            END;
        END;
    END IF;

    -- Se for gestor (ou tiver a flag is_gestor = true), criar registro correspondente em public.gestores se não existir
    IF v_is_gestor OR v_cargo = 'gestor'::public.tipo_perfil_enum THEN
        BEGIN
            INSERT INTO public.gestores (id, salario_base, percentual_comissao, ativo)
            VALUES (NEW.id, 0.00, 0.00, true)
            ON CONFLICT (id) DO NOTHING;
        EXCEPTION WHEN OTHERS THEN
            NULL;
        END;
    END IF;

    RETURN NEW;
END;
$$;

-- 6. Garantir que o Trigger está ativo
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
