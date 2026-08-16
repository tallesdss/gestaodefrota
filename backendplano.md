# 🏛️ Plano de Arquitetura de Backend — Supabase (Gestão de Frota Premium)

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

## 🚀 5. Próximos Passos de Execução

1. [ ] **Gerar Migration SQL Inicial:** Criar o script SQL completo com `TABLES`, `ENUMS`, `INDEXES`, `TRIGGERS` (atualização automática de timestamps e status) e `RLS POLICIES`.
2. [ ] **Executar Schema no Supabase:** Aplicar as migrações no projeto `Gestaodefrota` (`rwksrejrmjqnuspqnokp`).
3. [ ] **Configurar Buckets de Storage:** Provisionar os 5 buckets com as políticas de acesso.
4. [ ] **Implementar Repositories do Flutter:** Integrar o pacote `supabase_flutter` substituindo os mocks pelos repositories reais.
