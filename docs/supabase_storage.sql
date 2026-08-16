-- ==============================================================================
-- 📦 CONFIGURAÇÃO DOS BUCKETS DO SUPABASE STORAGE E POLÍTICAS RLS
-- ==============================================================================

-- Inserir os 5 buckets oficiais
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('documentos-motoristas', 'documentos-motoristas', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
    ('fotos-vistorias', 'fotos-vistorias', true, 15728640, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('documentos-veiculos', 'documentos-veiculos', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
    ('notas-fiscais-oficinas', 'notas-fiscais-oficinas', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
    ('comprovantes-pagamento', 'comprovantes-pagamento', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
ON CONFLICT (id) DO UPDATE 
SET public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Políticas de Storage RLS (storage.objects)
DO $$ BEGIN
    DROP POLICY IF EXISTS "Upload em fotos-vistorias por autenticados" ON storage.objects;
    CREATE POLICY "Upload em fotos-vistorias por autenticados" ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (bucket_id = 'fotos-vistorias');

    DROP POLICY IF EXISTS "Leitura publica de fotos-vistorias" ON storage.objects;
    CREATE POLICY "Leitura publica de fotos-vistorias" ON storage.objects
    FOR SELECT TO public USING (bucket_id = 'fotos-vistorias');

    DROP POLICY IF EXISTS "Upload em documentos-motoristas por autenticados" ON storage.objects;
    CREATE POLICY "Upload em documentos-motoristas por autenticados" ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (bucket_id = 'documentos-motoristas');

    DROP POLICY IF EXISTS "Leitura de documentos-motoristas por proprietario ou gestor" ON storage.objects;
    CREATE POLICY "Leitura de documentos-motoristas por proprietario ou gestor" ON storage.objects
    FOR SELECT TO authenticated USING (
        bucket_id = 'documentos-motoristas' AND (
            (storage.foldername(name))[1] = auth.uid()::text 
            OR public.eh_gestor_ou_admin()
        )
    );

    DROP POLICY IF EXISTS "Upload e leitura em documentos-veiculos por autenticados" ON storage.objects;
    CREATE POLICY "Upload e leitura em documentos-veiculos por autenticados" ON storage.objects
    FOR ALL TO authenticated USING (bucket_id = 'documentos-veiculos');

    DROP POLICY IF EXISTS "Upload e leitura em notas-fiscais-oficinas por autenticados" ON storage.objects;
    CREATE POLICY "Upload e leitura em notas-fiscais-oficinas por autenticados" ON storage.objects
    FOR ALL TO authenticated USING (bucket_id = 'notas-fiscais-oficinas');

    DROP POLICY IF EXISTS "Upload em comprovantes-pagamento por autenticados" ON storage.objects;
    CREATE POLICY "Upload em comprovantes-pagamento por autenticados" ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (bucket_id = 'comprovantes-pagamento');

    DROP POLICY IF EXISTS "Leitura de comprovantes-pagamento por proprietario ou gestor" ON storage.objects;
    CREATE POLICY "Leitura de comprovantes-pagamento por proprietario ou gestor" ON storage.objects
    FOR SELECT TO authenticated USING (
        bucket_id = 'comprovantes-pagamento' AND (
            (storage.foldername(name))[1] = auth.uid()::text 
            OR public.eh_gestor_ou_admin()
        )
    );
END $$;
