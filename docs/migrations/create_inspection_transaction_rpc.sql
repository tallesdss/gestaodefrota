CREATE OR REPLACE FUNCTION public.fn_criar_vistoria_completa(
    p_vistoria JSONB,
    p_fotos JSONB,
    p_checklist JSONB
) RETURNS UUID
LANGUAGE plpgsql
SET search_path = public, auth
AS $$
DECLARE
    v_vistoria_id UUID;
    v_motorista_id UUID := (p_vistoria->>'motorista_id')::UUID;
    v_veiculo_id UUID := (p_vistoria->>'veiculo_id')::UUID;
    v_contrato_id UUID := (p_vistoria->>'contrato_id')::UUID;
BEGIN
    IF auth.uid() IS NULL OR
       (auth.uid() <> v_motorista_id AND NOT public.eh_gestor_ou_admin()) THEN
        RAISE EXCEPTION 'Usuário sem permissão para registrar esta vistoria.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM public.contratos c
        WHERE c.id = v_contrato_id
          AND c.motorista_id = v_motorista_id
          AND c.veiculo_id = v_veiculo_id
          AND c.status = 'ativo'
    ) THEN
        RAISE EXCEPTION 'A vistoria deve pertencer ao veículo do contrato ativo.';
    END IF;

    INSERT INTO public.vistorias (
        contrato_id,
        veiculo_id,
        motorista_id,
        tipo,
        odometro_km,
        nivel_combustivel,
        tem_avaria_nova,
        status,
        observacoes
    ) VALUES (
        v_contrato_id,
        v_veiculo_id,
        v_motorista_id,
        (p_vistoria->>'tipo')::public.tipo_vistoria_enum,
        (p_vistoria->>'odometro_km')::INT,
        (p_vistoria->>'nivel_combustivel')::NUMERIC,
        COALESCE((p_vistoria->>'tem_avaria_nova')::BOOLEAN, FALSE),
        COALESCE((p_vistoria->>'status')::public.status_vistoria_enum, 'pendente_revisao'),
        p_vistoria->>'observacoes'
    ) RETURNING id INTO v_vistoria_id;

    INSERT INTO public.fotos_vistoria (
        vistoria_id,
        tipo_foto,
        url_foto,
        tem_avaria,
        descricao_avaria
    )
    SELECT
        v_vistoria_id,
        foto.tipo_foto::public.tipo_foto_vistoria_enum,
        foto.url_foto,
        COALESCE(foto.tem_avaria, FALSE),
        foto.descricao_avaria
    FROM jsonb_to_recordset(COALESCE(p_fotos, '[]'::JSONB)) AS foto(
        tipo_foto TEXT,
        url_foto TEXT,
        tem_avaria BOOLEAN,
        descricao_avaria TEXT
    );

    INSERT INTO public.itens_checklist_vistoria (
        vistoria_id,
        item_nome,
        conforme,
        observacao
    )
    SELECT
        v_vistoria_id,
        item.item_nome,
        COALESCE(item.conforme, FALSE),
        item.observacao
    FROM jsonb_to_recordset(COALESCE(p_checklist, '[]'::JSONB)) AS item(
        item_nome TEXT,
        conforme BOOLEAN,
        observacao TEXT
    );

    RETURN v_vistoria_id;
END;
$$;

REVOKE ALL ON FUNCTION public.fn_criar_vistoria_completa(JSONB, JSONB, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_criar_vistoria_completa(JSONB, JSONB, JSONB) TO authenticated, service_role;
