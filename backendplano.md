# 🏛️ Plano de Arquitetura e Migração Backend — Supabase (Gestão de Frota Premium)

> **Backend Oficial Exclusivo:** `Supabase (PostgreSQL + Auth + Storage + Realtime)`  
> **Projeto Supabase Ativo:** `Gestaodefrota`  
> **Project Reference ID:** `rwksrejrmjqnuspqnokp`  
> **Região:** `South America (São Paulo) - sa-east-1`  
> **Padrão de Nomenclatura:** Tabelas, colunas, enums e coleções em **Português** (`snake_case`)  
> **Integração MCP:** Ativa via [`.agents/mcp_config.json`](file:///c:/gestaodefrota/.agents/mcp_config.json)

---

## 🎯 1. Visão Geral e Estratégia de Backend

O backend é estruturado exclusivamente no **Supabase** para suportar a arquitetura multi-perfil (RBAC) do sistema:
- 👑 **Administrador:** Acesso irrestrito a todas as tabelas, configurações master e auditoria global.
- 🏢 **Gestor:** Acesso operacional (equipe, baixas financeiras, vistorias) com filtros por permissão.
- 🚗 **Motorista:** Acesso restrito exclusivamente aos seus dados pessoais, veículo em posse, vistorias, faturas e pagamentos via PIX.

---

## 🗄️ 2. Mapeamento das Tabelas e Schema Relacional (Em Português)

### 2.1. Autenticação e Perfis (`auth.users` & `public.perfis`)
Mapeia a conta de autenticação com o perfil e nível de acesso no sistema.
* **`perfis`**
  * `id` (UUID, PK, referencia `auth.users.id` em cascata)
  * `nome` (TEXT NOT NULL)
  * `email` (TEXT, UNIQUE, NOT NULL)
  * `telefone` (TEXT)
  * `foto_url` (TEXT)
  * `cargo` (ENUM `tipo_perfil_enum`: `'admin'`, `'gestor'`, `'motorista'`)
  * `criado_em` (TIMESTAMPTZ DEFAULT now())
  * `atualizado_em` (TIMESTAMPTZ DEFAULT now())

---

### 2.2. Módulo de Veículos (`public.veiculos`)
Armazena os veículos da frota, dados de documentação, seguro e controle de financiamento.
* **`veiculos`**
  * `id` (UUID, PK DEFAULT gen_random_uuid())
  * `placa` (VARCHAR(10), UNIQUE, NOT NULL)
  * `marca` (VARCHAR(50), NOT NULL)
  * `modelo` (VARCHAR(50), NOT NULL)
  * `ano` (INT NOT NULL)
  * `cor` (VARCHAR(30))
  * `renavam` (VARCHAR(30))
  * `chassi` (VARCHAR(30))
  * `km_atual` (INT NOT NULL DEFAULT 0)
  * `status` (ENUM `status_veiculo_enum`: `'disponivel'`, `'alugado'`, `'manutencao'`, `'inativo'`)
  * `crlv_url` (TEXT)
  * `numero_apolice_seguro` (TEXT)
  * `vencimento_seguro` (DATE)
  * `status_ipva` (ENUM `status_ipva_enum`: `'pago'`, `'pendente'`, `'atrasado'`)
  * `valor_ipva` (NUMERIC(10,2))
  * `vencimento_ipva` (DATE)
  * `financiamento_total_parcelas` (INT)
  * `financiamento_parcelas_pagas` (INT)
  * `financiamento_valor_parcela` (NUMERIC(10,2))
  * `criado_em` (TIMESTAMPTZ DEFAULT now())
  * `atualizado_em` (TIMESTAMPTZ DEFAULT now())

---

### 2.3. Módulo de Motoristas (`public.motoristas`)
Dados complementares do condutor, pontuação de confiança e auditoria cadastral.
* **`motoristas`**
  * `id` (UUID, PK, referencia `public.perfis.id` em cascata)
  * `cpf` (VARCHAR(14), UNIQUE, NOT NULL)
  * `numero_cnh` (VARCHAR(20), UNIQUE, NOT NULL)
  * `categoria_cnh` (VARCHAR(5) NOT NULL)
  * `validade_cnh` (DATE NOT NULL)
  * `cnh_frente_url` (TEXT)
  * `cnh_verso_url` (TEXT)
  * `comprovante_residencia_url` (TEXT)
  * `endereco_rua` (TEXT)
  * `endereco_cidade` (TEXT)
  * `endereco_estado` (VARCHAR(2))
  * `endereco_cep` (VARCHAR(10))
  * `status` (ENUM `status_motorista_enum`: `'pendente_aprovacao'`, `'ativo'`, `'bloqueado'`, `'inativo'`)
  * `pontuacao_confianca` (INT DEFAULT 100)
  * `valor_total_gerado` (NUMERIC(12,2) DEFAULT 0.00)
  * `saldo_devedor` (NUMERIC(10,2) DEFAULT 0.00)
  * `criado_em` (TIMESTAMPTZ DEFAULT now())
  * `atualizado_em` (TIMESTAMPTZ DEFAULT now())

---

### 2.4. Módulo de Contratos de Locação (`public.contratos`)
Vínculo ativo/histórico entre Veículo e Motorista.
* **`contratos`**
  * `id` (UUID, PK DEFAULT gen_random_uuid())
  * `numero_contrato` (VARCHAR(50), UNIQUE)
  * `motorista_id` (UUID, referencia `public.motoristas.id`)
  * `veiculo_id` (UUID, referencia `public.veiculos.id`)
  * `data_inicio` (DATE NOT NULL)
  * `data_fim` (DATE)
  * `valor_locacao` (NUMERIC(10,2) NOT NULL)
  * `valor_caucao` (NUMERIC(10,2) DEFAULT 0.00)
  * `frequencia_cobranca` (ENUM `frequencia_cobranca_enum`: `'semanal'`, `'quinzenal'`, `'mensal'`)
  * `dia_vencimento` (INT)
  * `status` (ENUM `status_contrato_enum`: `'ativo'`, `'concluido'`, `'cancelado'`, `'inadimplente'`)
  * `assinatura_digital_url` (TEXT)
  * `assinado_em` (TIMESTAMPTZ)
  * `criado_em` (TIMESTAMPTZ DEFAULT now())
  * `atualizado_em` (TIMESTAMPTZ DEFAULT now())

---

### 2.5. Módulo de Vistorias e Check-ins (`public.vistorias`)
Auditoria visual 360º para entrega e devolução de veículos.
* **`vistorias`**
  * `id` (UUID, PK DEFAULT gen_random_uuid())
  * `contrato_id` (UUID, referencia `public.contratos.id`)
  * `veiculo_id` (UUID, referencia `public.veiculos.id`)
  * `motorista_id` (UUID, referencia `public.motoristas.id`)
  * `vistoriador_id` (UUID, referencia `public.perfis.id`)
  * `tipo` (ENUM `tipo_vistoria_enum`: `'check_in'`, `'check_out'`, `'rotina'`)
  * `odometro_km` (INT NOT NULL)
  * `nivel_combustivel` (ENUM `nivel_combustivel_enum`: `'vazio'`, `'um_quarto'`, `'meio'`, `'tres_quartos'`, `'cheio'`)
  * `foto_frente_url` (TEXT)
  * `foto_traseira_url` (TEXT)
  * `foto_lateral_esquerda_url` (TEXT)
  * `foto_lateral_direita_url` (TEXT)
  * `foto_painel_url` (TEXT)
  * `foto_pneus_url` (TEXT)
  * `danos_json` (JSONB)
  * `status` (ENUM `status_vistoria_enum`: `'pendente_revisao'`, `'aprovado'`, `'rejeitado'`)
  * `observacoes` (TEXT)
  * `criado_em` (TIMESTAMPTZ DEFAULT now())

---

### 2.6. Módulo Financeiro & Caixa (`public.lancamentos_financeiros` & `public.categorias_despesa`)
Controle de receitas (aluguéis, taxas) e despesas (IPVA, seguros, manutenções, salários).
* **`categorias_despesa`**
  * `id` (UUID, PK DEFAULT gen_random_uuid())
  * `nome` (VARCHAR(100) NOT NULL)
  * `tipo` (ENUM `tipo_categoria_enum`: `'despesa'`, `'receita'`)
  * `categoria_pai_id` (UUID, referencia `public.categorias_despesa.id`)
  * `ativo` (BOOLEAN DEFAULT TRUE)

* **`lancamentos_financeiros`**
  * `id` (UUID, PK DEFAULT gen_random_uuid())
  * `contrato_id` (UUID, referencia `public.contratos.id`, nullable)
  * `motorista_id` (UUID, referencia `public.motoristas.id`, nullable)
  * `veiculo_id` (UUID, referencia `public.veiculos.id`, nullable)
  * `categoria_id` (UUID, referencia `public.categorias_despesa.id`)
  * `tipo` (ENUM `tipo_lancamento_enum`: `'receita'`, `'despesa'`)
  * `titulo` (VARCHAR(150) NOT NULL)
  * `valor` (NUMERIC(12,2) NOT NULL)
  * `data_vencimento` (DATE NOT NULL)
  * `data_pagamento` (DATE)
  * `status` (ENUM `status_financeiro_enum`: `'pendente'`, `'pago'`, `'atrasado'`, `'cancelado'`)
  * `metodo_pagamento` (ENUM `metodo_pagamento_enum`: `'pix'`, `'boleto'`, `'transferencia'`, `'dinheiro'`, `'cartao_credito'`)
  * `pix_copia_cola` (TEXT)
  * `pix_qr_code_url` (TEXT)
  * `comprovante_url` (TEXT)
  * `criado_por` (UUID, referencia `public.perfis.id`)
  * `criado_em` (TIMESTAMPTZ DEFAULT now())

---

### 2.7. Oficinas e Manutenção (`public.oficinas` & `public.manutencoes`)
* **`oficinas`**
  * `id` (UUID, PK DEFAULT gen_random_uuid())
  * `cnpj` (VARCHAR(18), UNIQUE)
  * `nome_fantasia` (VARCHAR(150) NOT NULL)
  * `razao_social` (VARCHAR(150))
  * `telefone` (VARCHAR(20))
  * `email` (VARCHAR(100))
  * `endereco` (TEXT)
  * `dados_bancarios_json` (JSONB)
  * `avaliacao` (NUMERIC(2,1) DEFAULT 5.0)
  * `status` (ENUM `status_oficina_enum`: `'ativo'`, `'suspenso'`, `'inativo'`)

* **`manutencoes`**
  * `id` (UUID, PK DEFAULT gen_random_uuid())
  * `veiculo_id` (UUID, referencia `public.veiculos.id`)
  * `oficina_id` (UUID, referencia `public.oficinas.id`)
  * `categoria_id` (UUID, referencia `public.categorias_despesa.id`)
  * `descricao` (TEXT NOT NULL)
  * `custo_total` (NUMERIC(10,2) NOT NULL)
  * `custo_pecas` (NUMERIC(10,2) DEFAULT 0.00)
  * `custo_mao_de_obra` (NUMERIC(10,2) DEFAULT 0.00)
  * `data_servico` (DATE NOT NULL)
  * `odometro_km` (INT NOT NULL)
  * `nota_fiscal_nfe_url` (TEXT)
  * `comprovante_url` (TEXT)
  * `lista_pecas_json` (JSONB)
  * `status` (ENUM `status_manutencao_enum`: `'agendado'`, `'em_andamento'`, `'concluido'`, `'cancelado'`)
  * `criado_em` (TIMESTAMPTZ DEFAULT now())

---

### 2.8. Gestores e Salários (`public.gestores`)
* **`gestores`**
  * `id` (UUID, PK, referencia `public.perfis.id` em cascata)
  * `salario_base` (NUMERIC(10,2) NOT NULL DEFAULT 0.00)
  * `percentual_comissao` (NUMERIC(4,2) DEFAULT 0.00)
  * `permissoes_json` (JSONB)
  * `ativo` (BOOLEAN DEFAULT TRUE)

---

### 2.9. Histórico de Atividades (`public.historico_atividades`)
* **`historico_atividades`**
  * `id` (UUID, PK DEFAULT gen_random_uuid())
  * `motorista_id` (UUID, referencia `public.motoristas.id`)
  * `veiculo_id` (UUID, referencia `public.veiculos.id`, nullable)
  * `tipo_evento` (VARCHAR(50) NOT NULL)
  * `titulo` (VARCHAR(150) NOT NULL)
  * `descricao` (TEXT)
  * `criado_em` (TIMESTAMPTZ DEFAULT now())

---

## 📦 3. Supabase Storage Buckets (Em Português)

1. `documentos-motoristas`: CNHs e comprovantes de residência (Acesso privado com RLS).
2. `fotos-vistorias`: Imagens de vistorias 360º e laudos de entrada/saída.
3. `documentos-veiculos`: CRLVs digitais, apólices de seguro e notas fiscais.
4. `notas-fiscais-oficinas`: NFes e recibos de serviços mecânicos.
5. `comprovantes-pagamento`: Comprovantes de transferências e PIX enviados pelos condutores.

---

## 🔐 4. Políticas de Segurança (Row Level Security - RLS)

* **Admin Master:** Permissão total (`ALL`) em todas as tabelas baseado em `perfis.cargo = 'admin'`.
* **Gestores:** Permissão de leitura e escrita operacional (`SELECT`, `INSERT`, `UPDATE`) em motoristas, vistorias e financeiro conforme permissões do `gestores.permissoes_json`.
* **Motoristas:**
  * `perfis` / `motoristas`: `SELECT` e `UPDATE` restrito ao seu próprio `auth.uid()`.
  * `contratos`: `SELECT` onde `motorista_id = auth.uid()`.
  * `vistorias`: `SELECT` onde `motorista_id = auth.uid()`, `INSERT` para check-in/out próprios.
  * `lancamentos_financeiros`: `SELECT` onde `motorista_id = auth.uid()`.

---

## 📋 5. Checklist Sequencial de Execução: Migração de Mock para Backend Real

> [!IMPORTANT]
> A execução segue a ordem estrita das fases abaixo para garantir integridade referencial, conformidade com a nomenclatura em português e zero quebras na interface.

---

### 🔹 FASE 1: Infraestrutura & Banco de Dados (Supabase)
- [ ] **1.1. Script de Migração SQL Master (em Português):**
  - [ ] Criar tipos ENUM (`tipo_perfil_enum`, `status_veiculo_enum`, `status_motorista_enum`, `status_contrato_enum`, `tipo_vistoria_enum`, `status_vistoria_enum`, `tipo_lancamento_enum`, `status_financeiro_enum`, `metodo_pagamento_enum`, `status_oficina_enum`, `status_manutencao_enum`, `frequencia_cobranca_enum`, `nivel_combustivel_enum`, `status_ipva_enum`).
  - [ ] Criar tabelas com chaves primárias UUID, chaves estrangeiras e constraints:
    - [ ] `perfis`
    - [ ] `veiculos`
    - [ ] `motoristas`
    - [ ] `contratos`
    - [ ] `vistorias`
    - [ ] `categorias_despesa`
    - [ ] `lancamentos_financeiros`
    - [ ] `oficinas`
    - [ ] `manutencoes`
    - [ ] `gestores`
    - [ ] `historico_atividades`
  - [ ] Criar triggers automáticos de `atualizado_em` em todas as tabelas.
  - [ ] Criar trigger `handle_new_user()` para popular `public.perfis` automaticamente a cada novo registro no `auth.users`.
- [ ] **1.2. Políticas de Segurança (Row Level Security - RLS):**
  - [ ] Ativar RLS em todas as tabelas (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`).
  - [ ] Criar função auxiliar `auth.eh_admin()` para otimização de regras de admin.
  - [ ] Criar policies para `perfis`, `veiculos`, `motoristas`, `contratos`, `vistorias`, `lancamentos_financeiros`, `oficinas`, `manutencoes`, `gestores`.
- [ ] **1.3. Configuração dos Buckets de Storage (em Português):**
  - [ ] Criar bucket `documentos-motoristas` (privado) + RLS policies de upload/download.
  - [ ] Criar bucket `fotos-vistorias` (autenticado) + RLS policies.
  - [ ] Criar bucket `documentos-veiculos` (autenticado) + RLS policies.
  - [ ] Criar bucket `notas-fiscais-oficinas` (autenticado) + RLS policies.
  - [ ] Criar bucket `comprovantes-pagamento` (privado) + RLS policies.
- [ ] **1.4. Execução do Schema & Seed Inicial no Supabase:**
  - [ ] Executar migration no projeto Supabase `Gestaodefrota` (`rwksrejrmjqnuspqnokp`).
  - [ ] Inserir dados base de categorias de despesas no `categorias_despesa` (conforme plano de contas).
  - [ ] Criar primeiro usuário Administrador Master no Supabase Auth.

---

### 🔹 FASE 2: Configuração do Cliente Flutter
- [ ] **2.1. Instalação de Dependências:**
  - [ ] Adicionar `supabase_flutter: ^2.8.0` no `frota_app/pubspec.yaml`.
  - [ ] Adicionar dependências auxiliares se necessário (`flutter_dotenv`).
  - [ ] Rodar `flutter pub get`.
- [ ] **2.2. Inicialização & Configuração Central:**
  - [ ] Criar arquivo de constantes/ambiente `lib/core/config/supabase_config.dart` (URL e Anon Key).
  - [ ] Inicializar `Supabase.initialize()` no `lib/main.dart`.
  - [ ] Criar helper global `supabase` (`Supabase.instance.client`).

---

### 🔹 FASE 3: Mapeamento de Modelos (Mappers & Serialization em Português)
- [ ] **3.1. Atualizar Modelos com `fromMap` e `toMap` mapeando as tabelas e colunas em português:**
  - [ ] `lib/models/vehicle.dart` (mapear com a tabela `veiculos`: `placa`, `marca`, `modelo`, `ano`, `status`, `km_atual`, etc.).
  - [ ] `lib/models/driver.dart` (mapear com a tabela `motoristas`: `cpf`, `numero_cnh`, `categoria_cnh`, `pontuacao_confianca`, etc.).
  - [ ] `lib/models/contract.dart` (mapear com a tabela `contratos`: `numero_contrato`, `motorista_id`, `veiculo_id`, `valor_locacao`, etc.).
  - [ ] `lib/models/inspection.dart` (mapear com a tabela `vistorias`: `tipo`, `odometro_km`, `nivel_combustivel`, `danos_json`, fotos).
  - [ ] `lib/models/financial_entry.dart` (mapear com a tabela `lancamentos_financeiros`: `titulo`, `valor`, `data_vencimento`, `status`, `pix_copia_cola`).
  - [ ] `lib/models/expense_category.dart` (mapear com a tabela `categorias_despesa`: `nome`, `tipo`, `categoria_pai_id`).
  - [ ] `lib/models/workshop.dart` (mapear com a tabela `oficinas`: `cnpj`, `nome_fantasia`, `razao_social`, `avaliacao`).
  - [ ] `lib/models/maintenance_entry.dart` (mapear com a tabela `manutencoes`: `veiculo_id`, `oficina_id`, `custo_total`, `lista_pecas_json`).
  - [ ] `lib/models/manager.dart` (mapear com a tabela `gestores`: `salario_base`, `percentual_comissao`, `permissoes_json`).
  - [ ] `lib/models/timeline_item.dart` (mapear com a tabela `historico_atividades`: `tipo_evento`, `titulo`, `descricao`).

---

### 🔹 FASE 4: Implementação dos Repositórios Concretos Supabase
- [ ] **4.1. Criar `AuthRepository` (`lib/core/repositories/auth_repository.dart`):**
  - [ ] Login com Email e Senha (`signInWithPassword`).
  - [ ] Cadastro de Motorista / Gestor (`signUp`).
  - [ ] Recuperação de Senha (`resetPasswordForEmail`).
  - [ ] Obter Sessão e Perfil Atual (`obterPerfilAtual`).
  - [ ] Logout (`signOut`).
- [ ] **4.2. Criar `VehicleRepository` (`lib/core/repositories/vehicle_repository.dart`):**
  - [ ] Listar veículos com filtros de status e busca (`obterVeiculos`).
  - [ ] Obter detalhes por ID (`obterVeiculoPorId`).
  - [ ] Cadastrar novo veículo (`criarVeiculo`).
  - [ ] Atualizar dados do veículo / KM / IPVA / Financiamento (`atualizarVeiculo`).
  - [ ] Inativar veículo (`deletarVeiculo`).
- [ ] **4.3. Criar `DriverRepository` (`lib/core/repositories/driver_repository.dart`):**
  - [ ] Listar motoristas com status e busca (`obterMotoristas`).
  - [ ] Obter perfil 360 do motorista (`obterMotoristaPorId`).
  - [ ] Atualizar status cadastral (Aprovar/Bloquear).
  - [ ] Atualizar pontuação de confiança e saldo devedor.
  - [ ] Upload de CNH e comprovante de residência no bucket `documentos-motoristas`.
- [ ] **4.4. Criar `ContractRepository` (`lib/core/repositories/contract_repository.dart`):**
  - [ ] Criar novo contrato vinculando veículo e motorista.
  - [ ] Listar contratos ativos e histórico.
  - [ ] Finalizar ou rescindir contrato.
- [ ] **4.5. Criar `InspectionRepository` (`lib/core/repositories/inspection_repository.dart`):**
  - [ ] Upload de fotos da vistoria 360º no bucket `fotos-vistorias`.
  - [ ] Salvar vistoria de Check-in ou Check-out com odômetro e nível de combustível.
  - [ ] Listar vistorias por motorista ou veículo.
  - [ ] Aprovar / Rejeitar laudo de vistoria (Admin/Gestor).
- [ ] **4.6. Criar `FinancialRepository` (`lib/core/repositories/financial_repository.dart`):**
  - [ ] Listar lançamentos financeiros com filtros de período e status.
  - [ ] Registrar entrada / saída manual (Função de Caixa).
  - [ ] Realizar baixa manual de recebimento.
  - [ ] Gerar cobrança / QR Code PIX para faturas de motorista.
  - [ ] Upload e visualização de comprovantes de pagamento no bucket `comprovantes-pagamento`.
- [ ] **4.7. Criar `WorkshopRepository` & `MaintenanceRepository`:**
  - [ ] CRUD completo de oficinas credenciadas na tabela `oficinas`.
  - [ ] Registrar nova manutenção com upload de NFe no bucket `notas-fiscais-oficinas`.
  - [ ] Listar manutenções por veículo e por oficina.
- [ ] **4.8. Criar `ManagerRepository`:**
  - [ ] Listar gestores e suas permissões a partir da tabela `gestores`.
  - [ ] Configurar salários e comissões.
  - [ ] Atualizar permissões operacionais no `permissoes_json`.

---

### 🔹 FASE 5: Autenticação Real & Controle de Acesso (RBAC)
- [ ] **5.1. Tela de Login (`/auth`):**
  - [ ] Conectar formulário ao `AuthRepository.signInWithPassword`.
  - [ ] Tratamento de erros de credenciais inválidas.
  - [ ] Redirecionamento automático com base no cargo (`admin` -> `/admin`, `gestor` -> `/gestor`, `motorista` -> `/driver`).
- [ ] **5.2. Fluxo de Auto-Cadastro do Motorista:**
  - [ ] Criar usuário no Supabase Auth + registro inicial em `perfis` e `motoristas`.
  - [ ] Upload de CNH e comprovante direto para o bucket `documentos-motoristas`.
  - [ ] Redirecionar para tela de "Aguardando Aprovação".
- [ ] **5.3. Guard de Rotas (`app_routes.dart`):**
  - [ ] Proteger rotas `/admin/*`, `/gestor/*` e `/driver/*` validando a sessão ativa e permissões.

---

### 🔹 FASE 6: Migração do Painel Master (Admin & Gestor)
- [ ] **6.1. Dashboard Principal:**
  - [ ] Conectar cards de KPIs (Veículos Ativos, Taxa de Ocupação, Receita Mensal, Despesas) a queries agregadas do Supabase.
  - [ ] Conectar gráficos de Receita vs Despesa com `lancamentos_financeiros`.
  - [ ] Painel de alertas de CNH e IPVA com queries filtradas por data de vencimento.
- [ ] **6.2. Módulo de Frota:**
  - [ ] Substituir `mockVehicles` por `VehicleRepository.obterVeiculos()`.
  - [ ] Conectar tela de criação e edição de veículos ao backend.
- [ ] **6.3. Módulo de Motoristas & Auditoria:**
  - [ ] Substituir `mockDrivers` por `DriverRepository.obterMotoristas()`.
  - [ ] Tela de auditoria de documentos conectada aos links seguros do Storage.
  - [ ] Visualização 360 do motorista carregando histórico real de contratos, vistorias e débitos.
- [ ] **6.4. Módulo de Vistorias:**
  - [ ] Comparativo de Check-in vs Check-out com fotos reais do Storage.
  - [ ] Aprovação de laudos salvando no banco.
- [ ] **6.5. Módulo de Oficinas & Manutenções:**
  - [ ] Perfil 360 da oficina com KPIs financeiros calculados a partir das manutenções reais.
  - [ ] Formulário de nova manutenção com upload de NFe.
- [ ] **6.6. Módulo Financeiro & Painel de Controle:**
  - [ ] Fluxo de caixa em tempo real e conciliação de recebimentos.
  - [ ] Gestão de categorias de despesas dinâmicas do banco.
  - [ ] Configuração de salários e permissões dos gestores.

---

### 🔹 FASE 7: Migração do Portal do Motorista (Driver Portal)
- [ ] **7.1. Home do Motorista:**
  - [ ] Carregar dados reais do veículo em posse a partir do contrato ativo.
  - [ ] Exibir status real de manutenção preventiva e KM do ativo.
- [ ] **7.2. Vistorias 360º:**
  - [ ] Fluxo de Check-in e Check-out tirando fotos pela câmera e enviando para o bucket `fotos-vistorias`.
  - [ ] Registro do odômetro e nível de combustível na tabela `vistorias`.
- [ ] **7.3. Extrato Financeiro & PIX:**
  - [ ] Listagem de faturas e mensalidades reais daquele motorista.
  - [ ] Geração dinâmica de PIX Copia e Cola.
  - [ ] Upload de comprovante de pagamento para `comprovantes-pagamento`.
- [ ] **7.4. Perfil & Documentos:**
  - [ ] Visualização do CRLV e Apólice de Seguro a partir dos links do veículo ativo.
  - [ ] Exibição da pontuação de confiança atualizada do banco.

---

### 🔹 FASE 8: Realtime & Notificações
- [ ] **8.1. Inscrições em Tempo Real (Supabase Realtime):**
  - [ ] Atualização instantânea de novas vistorias submetidas no painel do Gestor/Admin.
  - [ ] Notificação instantânea ao motorista quando um pagamento ou vistoria for aprovado.
  - [ ] Atualização dinâmica do saldo de caixa ao registrar novas entradas/saídas.

---

### 🔹 FASE 9: Limpeza, Seed & Validação Final
- [ ] **9.1. Limpeza de Mocks:**
  - [ ] Remover pasta `lib/mock/` e classe `MockRepository`.
  - [ ] Garantir que 100% dos imports apontem para os novos repositórios Supabase.
- [ ] **9.2. Testes de Integração & RLS:**
  - [ ] Testar fluxo completo de login e operações para cada cargo (`admin`, `gestor`, `motorista`).
  - [ ] Validar que Motoristas não conseguem acessar dados de terceiros via RLS.
  - [ ] Validar integridade dos uploads e visualização de imagens do Storage.
