# 🏛️ Plano de Arquitetura e Migração Backend — Supabase (Gestão de Frota Premium)

> **Projeto Supabase Ativo:** `Gestaodefrota`  
> **Project Reference ID:** `rwksrejrmjqnuspqnokp`  
> **Região:** `South America (São Paulo) - sa-east-1`  
> **Integração MCP:** Ativa via [`.agents/mcp_config.json`](file:///c:/gestaodefrota/.agents/mcp_config.json)

---

## 🎯 1. Visão Geral e Estratégia de Backend

O backend é estruturado no **Supabase (PostgreSQL + Auth + Storage + Realtime + Edge Functions)** para suportar a arquitetura multi-perfil (RBAC) do sistema:
- 👑 **Administrador:** Acesso irrestrito a todas as tabelas, configurações master e auditoria global.
- 🏢 **Gestor:** Acesso operacional (equipe, baixas financeiras, vistorias) com filtros por permissão.
- 🚗 **Motorista:** Acesso restrito exclusivamente aos seus dados pessoais, veículo em posse, vistorias, faturas e pagamentos via PIX.

---

## 🗄️ 2. Mapeamento das Tabelas e Schema Relacional

### 2.1. Autenticação e Perfis (`auth` & `public.profiles`)
Mapeia a conta do usuário do Supabase Auth com seu perfil de sistema e RBAC.
* **`profiles`**
  * `id` (UUID, PK, references `auth.users.id` on delete cascade)
  * `name` (TEXT)
  * `email` (TEXT, UNIQUE)
  * `phone` (TEXT)
  * `avatar_url` (TEXT)
  * `role` (ENUM: `'admin'`, `'gestor'`, `'driver'`)
  * `created_at` (TIMESTAMPTZ)
  * `updated_at` (TIMESTAMPTZ)

---

### 2.2. Módulo de Veículos (`public.vehicles`)
Armazena a frota, dados de documentação, seguros e controle financeiro de parcelas.
* **`vehicles`**
  * `id` (UUID, PK)
  * `plate` (VARCHAR(10), UNIQUE, NOT NULL)
  * `brand` (VARCHAR(50), NOT NULL)
  * `model` (VARCHAR(50), NOT NULL)
  * `year` (INT NOT NULL)
  * `color` (VARCHAR(30))
  * `renavam` (VARCHAR(30))
  * `chassis` (VARCHAR(30))
  * `current_km` (INT NOT NULL DEFAULT 0)
  * `status` (ENUM: `'available'`, `'rented'`, `'maintenance'`, `'inactive'`)
  * `crlv_url` (TEXT)
  * `insurance_policy_number` (TEXT)
  * `insurance_expiration` (DATE)
  * `ipva_status` (ENUM: `'paid'`, `'pending'`, `'overdue'`)
  * `ipva_amount` (NUMERIC(10,2))
  * `ipva_due_date` (DATE)
  * `financing_total_installments` (INT)
  * `financing_paid_installments` (INT)
  * `financing_installment_value` (NUMERIC(10,2))
  * `created_at` (TIMESTAMPTZ)
  * `updated_at` (TIMESTAMPTZ)

---

### 2.3. Módulo de Motoristas (`public.drivers`)
Dados complementares do condutor, pontuação de confiança e auditoria cadastral.
* **`drivers`**
  * `id` (UUID, PK, references `public.profiles.id`)
  * `cpf` (VARCHAR(14), UNIQUE, NOT NULL)
  * `cnh_number` (VARCHAR(20), UNIQUE, NOT NULL)
  * `cnh_category` (VARCHAR(5) NOT NULL)
  * `cnh_expiration` (DATE NOT NULL)
  * `cnh_front_url` (TEXT)
  * `cnh_back_url` (TEXT)
  * `proof_of_residence_url` (TEXT)
  * `address_street` (TEXT)
  * `address_city` (TEXT)
  * `address_state` (VARCHAR(2))
  * `address_zip` (VARCHAR(10))
  * `status` (ENUM: `'pending_approval'`, `'active'`, `'blocked'`, `'inactive'`)
  * `trust_score` (INT DEFAULT 100)
  * `total_lifetime_value` (NUMERIC(12,2) DEFAULT 0.00)
  * `outstanding_balance` (NUMERIC(10,2) DEFAULT 0.00)
  * `created_at` (TIMESTAMPTZ)
  * `updated_at` (TIMESTAMPTZ)

---

### 2.4. Módulo de Contratos de Locação (`public.contracts`)
Vínculo ativo/histórico entre Veículo e Motorista.
* **`contracts`**
  * `id` (UUID, PK)
  * `contract_number` (VARCHAR(50), UNIQUE)
  * `driver_id` (UUID, references `public.drivers.id`)
  * `vehicle_id` (UUID, references `public.vehicles.id`)
  * `start_date` (DATE NOT NULL)
  * `end_date` (DATE)
  * `rental_amount` (NUMERIC(10,2) NOT NULL)
  * `deposit_amount` (NUMERIC(10,2) DEFAULT 0.00)
  * `billing_frequency` (ENUM: `'weekly'`, `'biweekly'`, `'monthly'`)
  * `due_day` (INT)
  * `status` (ENUM: `'active'`, `'completed'`, `'cancelled'`, `'breached'`)
  * `digital_signature_url` (TEXT)
  * `signed_at` (TIMESTAMPTZ)
  * `created_at` (TIMESTAMPTZ)

---

### 2.5. Módulo de Vistorias e Check-ins (`public.inspections`)
Auditoria visual 360º para entrega e devolução de veículos.
* **`inspections`**
  * `id` (UUID, PK)
  * `contract_id` (UUID, references `public.contracts.id`)
  * `vehicle_id` (UUID, references `public.vehicles.id`)
  * `driver_id` (UUID, references `public.drivers.id`)
  * `inspector_id` (UUID, references `public.profiles.id`)
  * `type` (ENUM: `'check_in'`, `'check_out'`, `'routine'`)
  * `odometer_km` (INT NOT NULL)
  * `fuel_level` (ENUM: `'empty'`, `'quarter'`, `'half'`, `'three_quarters'`, `'full'`)
  * `front_photo_url` (TEXT)
  * `back_photo_url` (TEXT)
  * `left_side_photo_url` (TEXT)
  * `right_side_photo_url` (TEXT)
  * `dashboard_photo_url` (TEXT)
  * `tires_photo_url` (TEXT)
  * `damages_json` (JSONB)
  * `status` (ENUM: `'pending_review'`, `'approved'`, `'rejected'`)
  * `notes` (TEXT)
  * `created_at` (TIMESTAMPTZ)

---

### 2.6. Módulo Financeiro & Caixa (`public.financial_entries` & `public.expense_categories`)
Controle de receitas (aluguéis, taxas) e despesas (IPVA, seguros, manutenções, salários).
* **`expense_categories`**
  * `id` (UUID, PK)
  * `name` (VARCHAR(100) NOT NULL)
  * `type` (ENUM: `'expense'`, `'income'`)
  * `parent_id` (UUID, references `public.expense_categories.id`)
  * `is_active` (BOOLEAN DEFAULT TRUE)

* **`financial_entries`**
  * `id` (UUID, PK)
  * `contract_id` (UUID, references `public.contracts.id`, nullable)
  * `driver_id` (UUID, references `public.drivers.id`, nullable)
  * `vehicle_id` (UUID, references `public.vehicles.id`, nullable)
  * `category_id` (UUID, references `public.expense_categories.id`)
  * `type` (ENUM: `'income'`, `'expense'`)
  * `title` (VARCHAR(150) NOT NULL)
  * `amount` (NUMERIC(12,2) NOT NULL)
  * `due_date` (DATE NOT NULL)
  * `payment_date` (DATE)
  * `status` (ENUM: `'pending'`, `'paid'`, `'overdue'`, `'cancelled'`)
  * `payment_method` (ENUM: `'pix'`, `'boleto'`, `'transfer'`, `'cash'`, `'credit_card'`)
  * `pix_qr_code` (TEXT)
  * `receipt_url` (TEXT)
  * `created_by` (UUID, references `public.profiles.id`)
  * `created_at` (TIMESTAMPTZ)

---

### 2.7. Oficinas e Manutenção (`public.workshops` & `public.maintenance_entries`)
* **`workshops`**
  * `id` (UUID, PK)
  * `cnpj` (VARCHAR(18), UNIQUE)
  * `trading_name` (VARCHAR(150) NOT NULL)
  * `corporate_name` (VARCHAR(150))
  * `phone` (VARCHAR(20))
  * `email` (VARCHAR(100))
  * `address` (TEXT)
  * `bank_details_json` (JSONB)
  * `rating` (NUMERIC(2,1) DEFAULT 5.0)
  * `status` (ENUM: `'active'`, `'suspended'`, `'inactive'`)

* **`maintenance_entries`**
  * `id` (UUID, PK)
  * `vehicle_id` (UUID, references `public.vehicles.id`)
  * `workshop_id` (UUID, references `public.workshops.id`)
  * `category_id` (UUID, references `public.expense_categories.id`)
  * `description` (TEXT NOT NULL)
  * `total_cost` (NUMERIC(10,2) NOT NULL)
  * `parts_cost` (NUMERIC(10,2) DEFAULT 0.00)
  * `labor_cost` (NUMERIC(10,2) DEFAULT 0.00)
  * `service_date` (DATE NOT NULL)
  * `odometer_km` (INT NOT NULL)
  * `invoice_nfe_url` (TEXT)
  * `receipt_url` (TEXT)
  * `parts_list_json` (JSONB)
  * `status` (ENUM: `'scheduled'`, `'in_progress'`, `'completed'`, `'cancelled'`)
  * `created_at` (TIMESTAMPTZ)

---

### 2.8. Gestores e Salários (`public.managers`)
* **`managers`**
  * `id` (UUID, PK, references `public.profiles.id`)
  * `base_salary` (NUMERIC(10,2) NOT NULL DEFAULT 0.00)
  * `commission_percentage` (NUMERIC(4,2) DEFAULT 0.00)
  * `permissions_json` (JSONB)
  * `is_active` (BOOLEAN DEFAULT TRUE)

---

## 📦 3. Supabase Storage Buckets

1. `driver-documents`: CNHs e comprovantes de residência (Acesso privado com RLS).
2. `inspection-photos`: Imagens de vistorias 360º e laudos de entrada/saída.
3. `vehicle-documents`: CRLVs digitais, apólices de seguro e notas fiscais.
4. `workshop-invoices`: NFes e recibos de serviços mecânicos.
5. `payment-receipts`: Comprovantes de transferências e PIX enviados pelos condutores.

---

## 🔐 4. Políticas de Segurança (Row Level Security - RLS)

* **Admin Master:** Permissão total (`ALL`) em todas as tabelas baseado no `profile.role = 'admin'`.
* **Gestores:** Permissão de leitura e escrita operacional (`SELECT`, `INSERT`, `UPDATE`) em motoristas, vistorias e financeiro conforme permissões do `managers.permissions_json`.
* **Motoristas:**
  * `profiles` / `drivers`: `SELECT` e `UPDATE` restrito ao seu próprio `auth.uid()`.
  * `contracts`: `SELECT` onde `driver_id = auth.uid()`.
  * `inspections`: `SELECT` onde `driver_id = auth.uid()`, `INSERT` para check-in/out próprios.
  * `financial_entries`: `SELECT` onde `driver_id = auth.uid()`.

---

## 📋 5. Checklist Sequencial de Execução: Migração de Mock para Backend Real

> [!IMPORTANT]
> A execução deve seguir a ordem estrita das fases abaixo para garantir integridade referencial, segurança e zero quebras na interface do aplicativo.

---

### 🔹 FASE 1: Infraestrutura & Banco de Dados (Supabase)
- [ ] **1.1. Script de Migração SQL Master:**
  - [ ] Criar tipos ENUM (`user_role`, `vehicle_status`, `driver_status`, `contract_status`, `inspection_type`, `inspection_status`, `financial_type`, `financial_status`, `payment_method_enum`, `workshop_status`, `maintenance_status`).
  - [ ] Criar tabelas com chaves primárias UUID, chaves estrangeiras e constraints:
    - [ ] `profiles`
    - [ ] `vehicles`
    - [ ] `drivers`
    - [ ] `contracts`
    - [ ] `inspections`
    - [ ] `expense_categories`
    - [ ] `financial_entries`
    - [ ] `workshops`
    - [ ] `maintenance_entries`
    - [ ] `managers`
    - [ ] `timeline_items`
  - [ ] Criar triggers automáticos de `updated_at` em todas as tabelas.
  - [ ] Criar trigger `handle_new_user()` para popular `public.profiles` automaticamente a cada novo registro no `auth.users`.
- [ ] **1.2. Políticas de Segurança (Row Level Security - RLS):**
  - [ ] Ativar RLS em todas as tabelas (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`).
  - [ ] Criar helper function `auth.is_admin()` para otimização de regras de admin.
  - [ ] Criar policies para `profiles`, `vehicles`, `drivers`, `contracts`, `inspections`, `financial_entries`, `workshops`, `maintenance_entries`, `managers`.
- [ ] **1.3. Configuração dos Buckets de Storage:**
  - [ ] Criar bucket `driver-documents` (privado) + RLS policies de upload/download.
  - [ ] Criar bucket `inspection-photos` (privado/autenticado) + RLS policies.
  - [ ] Criar bucket `vehicle-documents` (autenticado) + RLS policies.
  - [ ] Criar bucket `workshop-invoices` (autenticado) + RLS policies.
  - [ ] Criar bucket `payment-receipts` (privado) + RLS policies.
- [ ] **1.4. Execução do Schema & Seed Inicial:**
  - [ ] Executar migration no projeto Supabase `Gestaodefrota` (`rwksrejrmjqnuspqnokp`).
  - [ ] Inserir dados base de categorias de despesas no `expense_categories` (conforme plano de contas).
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

### 🔹 FASE 3: Mapeamento de Modelos (Mappers & Serialization)
- [ ] **3.1. Atualizar Modelos com `fromMap` e `toMap` compatíveis com o PostgreSQL:**
  - [ ] `lib/models/vehicle.dart` (mapear campos snake_case <-> camelCase e enums).
  - [ ] `lib/models/driver.dart` (mapear campos de CNH, endereço e score).
  - [ ] `lib/models/contract.dart` (mapear relacionamentos e periodicidade).
  - [ ] `lib/models/inspection.dart` (mapear URLs das fotos e JSON de danos).
  - [ ] `lib/models/financial_entry.dart` (mapear valores numéricos, datas e método de pagamento).
  - [ ] `lib/models/expense_category.dart` (mapear hierarquia de categorias).
  - [ ] `lib/models/workshop.dart` (mapear CNPJ, dados bancários e status).
  - [ ] `lib/models/maintenance_entry.dart` (mapear lista de peças e NFes).
  - [ ] `lib/models/manager.dart` (mapear salário base e JSON de permissões).
  - [ ] `lib/models/timeline_item.dart` (mapear histórico de eventos).

---

### 🔹 FASE 4: Implementação dos Repositórios Concretos Supabase
- [ ] **4.1. Criar `AuthRepository` (`lib/core/repositories/auth_repository.dart`):**
  - [ ] Login com Email e Senha (`signInWithPassword`).
  - [ ] Cadastro de Motorista / Gestor (`signUp`).
  - [ ] Recuperação de Senha (`resetPasswordForEmail`).
  - [ ] Obter Sessão e Perfil Atual (`getCurrentProfile`).
  - [ ] Logout (`signOut`).
- [ ] **4.2. Criar `VehicleRepository` (`lib/core/repositories/vehicle_repository.dart`):**
  - [ ] Listar veículos com filtros de status e busca (`getVehicles`).
  - [ ] Obter detalhes por ID (`getVehicleById`).
  - [ ] Cadastrar novo veículo (`createVehicle`).
  - [ ] Atualizar dados do veículo / KM / IPVA / Financiamento (`updateVehicle`).
  - [ ] Inativar veículo (`deleteVehicle`).
- [ ] **4.3. Criar `DriverRepository` (`lib/core/repositories/driver_repository.dart`):**
  - [ ] Listar motoristas com status e busca (`getDrivers`).
  - [ ] Obter perfil 360 do motorista (`getDriverById`).
  - [ ] Atualizar status cadastral (Aprovar/Bloquear).
  - [ ] Atualizar Trust Score e saldo devedor.
  - [ ] Upload de CNH e Comprovante de Residência no Storage do Supabase.
- [ ] **4.4. Criar `ContractRepository` (`lib/core/repositories/contract_repository.dart`):**
  - [ ] Criar novo contrato vinculando veículo e motorista.
  - [ ] Listar contratos ativos e histórico.
  - [ ] Finalizar ou rescindir contrato.
- [ ] **4.5. Criar `InspectionRepository` (`lib/core/repositories/inspection_repository.dart`):**
  - [ ] Upload de fotos da vistoria 360º no bucket `inspection-photos`.
  - [ ] Salvar vistoria de Check-in ou Check-out com odômetro e nível de combustível.
  - [ ] Listar vistorias por motorista ou veículo.
  - [ ] Aprovar / Rejeitar laudo de vistoria (Admin/Gestor).
- [ ] **4.6. Criar `FinancialRepository` (`lib/core/repositories/financial_repository.dart`):**
  - [ ] Listar entradas financeiras com filtros de período e status.
  - [ ] Registrar entrada / saída manual (Função de Caixa).
  - [ ] Realizar baixa manual de recebimento.
  - [ ] Gerar cobrança / QR Code PIX para faturas de motorista.
  - [ ] Upload e visualização de comprovantes de pagamento.
- [ ] **4.7. Criar `WorkshopRepository` & `MaintenanceRepository`:**
  - [ ] CRUD completo de oficinas credenciadas.
  - [ ] Registrar nova manutenção com upload de NFe e lista de peças.
  - [ ] Listar manutenções por veículo e por oficina.
- [ ] **4.8. Criar `ManagerRepository`:**
  - [ ] Listar gestores e suas permissões.
  - [ ] Configurar salários e comissões.
  - [ ] Atualizar permissões operacionais.

---

### 🔹 FASE 5: Autenticação Real & Controle de Acesso (RBAC)
- [ ] **5.1. Tela de Login (`/auth`):**
  - [ ] Conectar formulário ao `AuthRepository.signInWithPassword`.
  - [ ] Tratamento de erros de credenciais inválidas.
  - [ ] Redirecionamento automático com base na role (`admin` -> `/admin`, `gestor` -> `/gestor`, `driver` -> `/driver`).
- [ ] **5.2. Fluxo de Auto-Cadastro do Motorista:**
  - [ ] Criar usuário no Supabase Auth + registro inicial em `profiles` e `drivers`.
  - [ ] Upload de CNH e comprovante direto para o bucket `driver-documents`.
  - [ ] Redirecionar para tela de "Aguardando Aprovação".
- [ ] **5.3. Guard de Rotas (`app_routes.dart`):**
  - [ ] Proteger rotas `/admin/*`, `/gestor/*` e `/driver/*` validando a sessão ativa e permissões.

---

### 🔹 FASE 6: Migração do Painel Master (Admin & Gestor)
- [ ] **6.1. Dashboard Principal:**
  - [ ] Conectar cards de KPIs (Veículos Ativos, Taxa de Ocupação, Receita Mensal, Despesas) a queries agregadas do Supabase.
  - [ ] Conectar gráficos de Receita vs Despesa com `financial_entries`.
  - [ ] Painel de alertas de CNH e IPVA com queries filtradas por data de vencimento.
- [ ] **6.2. Módulo de Frota:**
  - [ ] Substituir `mockVehicles` por `VehicleRepository.getVehicles()`.
  - [ ] Conectar tela de criação e edição de veículos ao backend.
- [ ] **6.3. Módulo de Motoristas & Auditoria:**
  - [ ] Substituir `mockDrivers` por `DriverRepository.getDrivers()`.
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
  - [ ] Fluxo de Check-in e Check-out tirando fotos pela câmera e enviando para o bucket `inspection-photos`.
  - [ ] Registro do odômetro e nível de combustível no `inspections`.
- [ ] **7.3. Extrato Financeiro & PIX:**
  - [ ] Listagem de faturas e mensalidades reais daquele motorista.
  - [ ] Geração dinâmica de PIX Copia e Cola.
  - [ ] Upload de comprovante de pagamento para `payment-receipts`.
- [ ] **7.4. Perfil & Documentos:**
  - [ ] Visualização do CRLV e Apólice de Seguro a partir dos links do veículo ativo.
  - [ ] Exibição do Trust Score atualizado do banco.

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
  - [ ] Testar fluxo completo de login e operações para cada role (Admin, Gestor, Driver).
  - [ ] Validar que Motoristas não conseguem acessar dados de terceiros via RLS.
  - [ ] Validar integridade dos uploads e visualização de imagens do Storage.
