-- Função RPC para promover um usuário a gestor de forma segura
CREATE OR REPLACE FUNCTION public.promover_a_gestor(p_user_id UUID)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER -- Permite executar com privilégios do criador da função (útil para RLS bypass caso necessário)
AS $$
DECLARE
    v_perfil_existente BOOLEAN;
    v_gestor_existente BOOLEAN;
BEGIN
    -- 1. Verificar se o perfil existe
    SELECT EXISTS (
        SELECT 1 FROM public.perfis WHERE id = p_user_id
    ) INTO v_perfil_existente;

    IF NOT v_perfil_existente THEN
        RETURN jsonb_build_object('sucesso', false, 'erro', 'Usuário não encontrado na tabela de perfis.');
    END IF;

    -- 2. Atualizar perfil para gestor
    UPDATE public.perfis
    SET 
        is_gestor = true,
        cargo = 'gestor',
        atualizado_em = now()
    WHERE id = p_user_id;

    -- 3. Inserir na tabela gestores se não existir
    SELECT EXISTS (
        SELECT 1 FROM public.gestores WHERE id = p_user_id
    ) INTO v_gestor_existente;

    IF NOT v_gestor_existente THEN
        INSERT INTO public.gestores (id, salario_base, percentual_comissao, is_aprovado)
        VALUES (p_user_id, 0.00, 0.00, true);
    END IF;

    RETURN jsonb_build_object('sucesso', true, 'mensagem', 'Usuário promovido a gestor com sucesso.');
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('sucesso', false, 'erro', SQLERRM);
END;
$$;
