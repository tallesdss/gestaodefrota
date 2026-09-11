# 🚗 LAUDO TÉCNICO — GESTÃO DE FROTA
### Análise Revisada — Reorganizada por Prioridade Operacional

> **Data:** 11/09/2026 | **Sistema:** Flutter + Supabase PostgreSQL 17 | **Ref:** `rwksrejrmjqnuspqnokp`
>
> **Modelo de Pagamento Definido:** Sem gateway PIX — Admin disponibiliza chave PIX; motorista anexa comprovante manualmente.

---

## 📊 RESUMO DA SITUAÇÃO ATUAL

O backend (Supabase) está bem modelado. O app Flutter compila e roda. O problema central é que **vários módulos críticos ainda usam `MockRepository`** (dados falsos) ao invés do Supabase real. Os cálculos financeiros existem no código mas não persistem corretamente. A estrutura de rotas e telas está pronta — falta conectar cada tela ao banco de dados real e implementar as Edge Functions de cálculo.

---

---

# ✅ GRUPO 1 — JÁ FEITO E FUNCIONANDO

> Itens confirmados após análise dos arquivos de código e repositórios.

### 🏗️ Backend & Infraestrutura Supabase
- [x] Schema relacional completo (17 ENUMs, 13 tabelas normalizadas em 3FN)
- [x] Todos os índices B-Tree em chaves estrangeiras criados
- [x] RLS habilitado em 100% das tabelas
- [x] Trigger `trg_km_vistoria` — atualiza `km_atual` do veículo ao registrar vistoria
- [x] Trigger `trg_km_manutencao` — atualiza `km_atual` ao registrar manutenção
- [x] Trigger `trg_status_veiculo_contrato` — muda status do veículo para `alugado`/`disponivel` ao criar/encerrar contrato
- [x] Trigger `trg_financeiro_motorista` — recalcula `valor_total_gerado` e `saldo_devedor` do motorista
- [x] Trigger `on_auth_user_created` — cria perfil automaticamente no cadastro
- [x] RPC `fn_criar_contrato_locacao` — cria contrato + caução + 1ª mensalidade em transação ACID
- [x] View `vw_kpis_dashboard_master` — KPIs agregados em tempo real
- [x] View `vw_extrato_completo_motorista` — extrato financeiro com JOINs relacionais
- [x] 5 buckets de Storage configurados (`documentos-motoristas`, `fotos-vistorias`, `documentos-veiculos`, `notas-fiscais-oficinas`, `comprovantes-pagamento`)
- [x] MCP Supabase ativo e apontando para o projeto correto

### 📱 Flutter — Módulo de Frota
- [x] `VehicleListScreen` — lista veículos com filtro de status conectada ao Supabase
- [x] `VehicleFormScreen` — cria/edita veículo com persistência real no Supabase
- [x] `VehicleRepository` — CRUD completo com fallback em memória

### 👤 Flutter — Módulo de Motoristas
- [x] `DriverListScreen` — lista motoristas com status e busca (Supabase real)
- [x] `DriverFormScreen` — cadastro de motorista com upload de documentos no Storage
- [x] `DriverRepository` — leitura com JOIN de perfis, contratos e veículos
- [x] `DriverProfileScreen` — perfil completo do motorista (55KB, mais completo do sistema)
- [x] `DriverTimelineScreen` — histórico de atividades conectado ao `historico_atividades`
- [x] `DriverInspectionHistoryScreen` — histórico de vistorias do motorista

### 🔐 Flutter — Autenticação
- [x] `LoginScreen` — autenticação real via Supabase Auth
- [x] `RegisterScreen` — cadastro com criação automática de perfil
- [x] `ForgotPasswordScreen` — reset de senha via Supabase Auth
- [x] `AuthRepository` — login, signup, logout, reset senha com metadados
- [x] Roteamento por cargo (`admin`, `gestor`, `motorista`) após login

### 📋 Flutter — Módulo de Vistorias (Admin)
- [x] `InspectionAuditScreen` — lista vistorias pendentes de aprovação
- [x] `InspectionFormScreen` — criação de vistoria administrativa
- [x] `InspectionDetailScreen` (Admin) — detalhe com fotos do Storage
- [x] `InspectionRepository` — CRUD com upload em cascata de fotos e checklist

### 🔧 Flutter — Módulo de Manutenção
- [x] `MaintenanceListScreen` — lista de ordens de serviço (Supabase real)
- [x] `MaintenanceFormScreen` — criação de OS com seleção de oficina e itens
- [x] `MaintenanceDetailScreen` — detalhe completo da manutenção
- [x] `MaintenanceRepository` — CRUD + inserção em lote de `itens_manutencao`

### 🏢 Flutter — Módulo de Oficinas
- [x] `WorkshopListScreen` — lista de oficinas credenciadas
- [x] `WorkshopFormScreen` — cadastro de oficina com dados bancários e PIX
- [x] `WorkshopDetailScreen` — detalhe completo com avaliação
- [x] `WorkshopRepository` — CRUD completo no Supabase

### 📱 Flutter — Portal do Motorista (Vistorias)
- [x] `InspectionCheckInScreen` — vistoria de entrada com captura de 8 fotos + upload no Storage
- [x] `InspectionCheckOutScreen` — vistoria de saída conectada ao banco
- [x] `OccurrenceReportScreen` — reporte de ocorrência conectado
- [x] `InspectionHistoryScreen` — histórico de vistorias do motorista
- [x] `DriverInspectionDetailScreen` — detalhe da vistoria com galeria de fotos

### 📱 Flutter — Portal do Motorista (Perfil)
- [x] `DriverProfileDetailScreen` — visualização do perfil conectado ao Supabase
- [x] `DriverDocumentsScreen` — visualização de CNH e comprovante do Storage
- [x] `AccountSecurityScreen` — alteração de senha via Auth
- [x] `DriverActivityTimelineScreen` — timeline de atividades

### 💰 Flutter — PIX (Geração de Payload)
- [x] `PixService.generatePixPayload()` — geração correta de payload EMV BACEN BRCode com CRC16-CCITT
- [x] `PixCheckoutScreen` — tela de checkout com exibição do QR Code gerado localmente
- [x] Upload de comprovante de pagamento no bucket `comprovantes-pagamento`
- [x] `ReceiptsHistoryScreen` — histórico de comprovantes do motorista

### 📊 Flutter — Dashboard
- [x] `AdminDashboardScreen` — conectado à view `vw_kpis_dashboard_master` (taxa de ocupação, KPIs)
- [x] Exibição de lançamentos em atraso no dashboard

### ⚙️ Flutter — Painel de Controle
- [x] `ControlPanelScreen` — tela de navegação do painel
- [x] `CashFlowFormScreen` — lançamento manual de despesa/receita conectado ao `FinancialRepository`
- [x] `ExpenseCategoriesScreen` — gestão de categorias de despesa (Supabase real)

---

---

# 🔴 GRUPO 2 — PRIORIDADE MÁXIMA PARA O SISTEMA FUNCIONAR

> Estes itens bloqueiam o funcionamento real do sistema. Devem ser implementados em ordem.

---

## 🗄️ BANCO DE DADOS — Supabase (Fazer primeiro, desbloqueia tudo)

- [x] **[DB-01] CRÍTICO** — Criar tabela `configuracoes_sistema` no Supabase
  > O `PixService` tenta salvar a chave PIX nessa tabela e falha silenciosamente porque ela **não existe no schema**
  ```sql
  CREATE TABLE public.configuracoes_sistema (
    chave VARCHAR(100) PRIMARY KEY,
    valor JSONB NOT NULL,
    atualizado_em TIMESTAMPTZ DEFAULT now()
  );
  ALTER TABLE public.configuracoes_sistema ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Admin gerencia configuracoes"
    ON public.configuracoes_sistema FOR ALL
    USING (public.eh_admin());
  ```

- [x] **[DB-02] CRÍTICO** — Verificar seed de categorias contábeis no banco
  > A UUID `'10000000-0000-0000-0000-000000000002'` está hardcoded em 3 arquivos Flutter para "Aluguel/Locação" — ela precisa existir na tabela `categorias_despesa`. Verificar via Supabase Dashboard e inserir se não existir.

- [x] **[DB-03] CRÍTICO** — Criar Edge Function `fn_gerar_parcelas_contrato`
  > Calcula e insere todas as parcelas de aluguel no `lancamentos_financeiros` quando um contrato é criado. A RPC atual só gera 1 parcela — o ciclo completo precisa ser gerado.
  - Parâmetros: `contrato_id`, `valor_locacao`, `frequencia` (semanal/quinzenal/mensal), `dia_vencimento`, `data_inicio`, `data_fim` (opcional), `num_parcelas`
  - Loop de INSERT em `lancamentos_financeiros` com cada data de vencimento calculada
  - Suporte a frequência **semanal** (+7 dias), **quinzenal** (+14 dias) e **mensal** (+1 mês)
  - Titulo de cada parcela: `"Aluguel [Semanal/Mensal] — Parcela N de TOTAL — Contrato NÚMERO"`

- [x] **[DB-04] CRÍTICO** — Criar Edge Function `fn_marcar_lancamentos_atrasados`
  > Calcula e insere todas as parcelas de aluguel no `lancamentos_financeiros` quando um contrato é criado. A RPC atual só gera 1 parcela — o ciclo completo precisa ser gerado.
  - Parâmetros: `contrato_id`, `valor_locacao`, `frequencia` (semanal/quinzenal/mensal), `dia_vencimento`, `data_inicio`, `data_fim` (opcional), `num_parcelas`
  - Loop de INSERT em `lancamentos_financeiros` com cada data de vencimento calculada
  - Suporte a frequência **semanal** (+7 dias), **quinzenal** (+14 dias) e **mensal** (+1 mês)
  - Titulo de cada parcela: `"Aluguel [Semanal/Mensal] — Parcela N de TOTAL — Contrato NÚMERO"`

- [x] **[DB-05]** — Corrigir `vw_kpis_dashboard_master`: excluir veículos `inativo` e `vendido` do denominador da taxa de ocupação
  ```sql
  -- Alterar linha do denominador para:
  NULLIF((SELECT COUNT(*) FROM public.veiculos WHERE status NOT IN ('inativo','vendido')), 0)
  ```

- [x] **[DB-06]** — Proteger token do MCP: adicionar `.agents/mcp_config.json` ao `.gitignore` e revogar o token exposto no repositório git via Supabase Dashboard

---

## 🔑 ADMIN — Atribuir Veículo ao Motorista (Fluxo de Contrato)

- [x] **[CTR-01]** `ContractListScreen` → Remover dependência de `MockRepository` e integrar com `ContractRepository` real.
  > Arquivo: `lib/admin/contracts/contract_list_screen.dart`
  > Substituir `MockRepository` por `ContractRepository().getContracts()` — a tela nunca mostra contratos reais do Supabase

- [x] **[CTR-02]** `ContractFormScreen` → Filtrar motoristas que já têm contrato ativo (não devem aparecer).
  > Arquivo: `lib/admin/contracts/contract_form_screen.dart`
  > - Substituir `MockRepository` por `VehicleRepository().getVehicles(status: 'disponivel')` no dropdown de veículos
  > - Substituir por `DriverRepository().getDrivers(status: 'ativo')` no dropdown de motoristas
  > - Filtrar motoristas que já têm contrato ativo (não devem aparecer)
  > - Ao salvar: chamar `createContractAtomic()` via RPC e em seguida chamar a Edge Function `fn_gerar_parcelas_contrato` com o `contractId` retornado

- [x] **[CTR-03]** Adicionar campo de **frequência de cobrança** no `ContractFormScreen`. O campo `frequencia_cobranca` (semanal/quinzenal/mensal) existe no banco mas não está no formulário Flutter — adicioná-lo como dropdown obrigatório.

- [x] **[CTR-04]** — Implementar ação de **encerrar contrato** na lista de contratos
  > Botão "Encerrar Contrato" que chama `concludeContract(id)` — o trigger `trg_status_veiculo_contrato` devolve o veículo para `disponivel` automaticamente

---

## 🚗 MOTORISTA — Check-in (Vistoria de Entrada)

- [x] **[CHK-01]** — Corrigir `DriverHomeScreen`: vulnerabilidade de segurança no fallback de usuário
  > Arquivo: `lib/driver_portal/home/driver_home_screen.dart`
  > O fallback quando `auth.uid()` é null itera sobre todos os motoristas ativos — motorista pode ver dados de outro. Se não houver sessão, redirecionar para login imediatamente (sem fallback)

- [x] **[CHK-02]** — Verificar e testar fluxo completo de Check-in
  > O `InspectionCheckInScreen` já está conectado ao `InspectionRepository` e faz upload de fotos no Storage. Testar o fluxo completo:
  > 1. Motorista logado → busca contrato ativo → busca veículo do contrato
  > 2. Preenche KM, nível de combustível, checklist
  > 3. Captura fotos obrigatórias (Frente, Traseira, Laterais, Hodômetro)
  > 4. Submete → INSERT em `vistorias` + INSERT em `fotos_vistoria` + INSERT em `itens_checklist_vistoria`
  > 5. Trigger `trg_km_vistoria` atualiza `veiculos.km_atual`
  > 6. INSERT em `historico_atividades` com evento de check-in

- [x] **[CHK-03]** — Garantir que check-in só é possível se motorista tem contrato ativo
  > Bloquear botão de check-in na `DriverHomeScreen` se `_activeContract == null`

---

## 💰 FINANCEIRO — Pagamentos e Cálculos

- [x] **[FIN-01] CRÍTICO** — Migrar `FinancialListScreen` do `MockRepository` para `FinancialRepository` real
  > Arquivo: `lib/admin/financial/financial_list_screen.dart`
  > Substituir `final MockRepository _repository = MockRepository()` por `final FinancialRepository _financialRepo = FinancialRepository()`
  > Usar `_financialRepo.getFinancialEntries()` — atualmente a tela principal financeira do Admin **nunca mostra dados reais**

- [x] **[FIN-02] CRÍTICO** — Migrar `DelinquencyListScreen` do `MockRepository` para repositórios reais
  > Arquivo: `lib/admin/financial/delinquency_list_screen.dart`
  > Substituir por: `FinancialRepository().getFinancialEntries(status: 'atrasado')` para buscar inadimplentes reais
  > O cálculo de multa (2%) + juros (1% a.m.) já existe no código — apenas trocar a fonte de dados

- [x] **[FIN-03]** — Implementar geração de parcelas após criar contrato
  > No `ContractFormScreen`, após `createContractAtomic()` retornar o `contractId`, chamar a Edge Function `fn_gerar_parcelas_contrato` para gerar todas as parcelas do ciclo completo no Supabase

- [x] **[FIN-04]** — Implementar frequência **quinzenal** em `generateContractInstallments()`
  > Arquivo: `lib/core/repositories/financial_repository.dart` linha ~195
  > Adicionar caso `'quinzenal'`: `currentDue = currentDue.add(const Duration(days: 14))`

- [x] **[FIN-05]** — Baixa de pagamento via comprovante (fluxo sem gateway PIX)
  > Quando o motorista faz upload do comprovante no `PixCheckoutScreen`:
  > 1. Upload do arquivo no bucket `comprovantes-pagamento` ✅ (já funciona)
  > 2. Chamar `markAsPaid(entryId, receiptUrl: signedUrl)` ✅ (já existe)
  > 3. **Falta:** salvar o `pix_copia_cola` e `pix_qr_code_url` no `lancamentos_financeiros` do Supabase ao gerar o QR (para o admin ver qual lançamento o motorista está pagando)
  > 4. **Falta:** Admin precisa confirmar/validar o comprovante — adicionar botão "Confirmar Pagamento" na tela de detalhe do motorista ou na tela financeira

- [x] **[FIN-06]** — Exibir chave PIX do admin para o motorista na tela de pagamento
  > No `PixCheckoutScreen`, além do QR Code, exibir a chave PIX cadastrada pelo admin (lida de `configuracoes_sistema`) com botão "Copiar Chave PIX" para pagamento manual

- [x] **[FIN-07]** — No `FinancialReportScreen`: filtrar apenas lançamentos `status = 'pago'` nos cálculos de lucro/margem
  > Arquivo: `lib/admin/control_panel/financial_report_screen.dart`
  > Os totais de receita e despesa devem refletir apenas o que foi efetivamente recebido/pago — hoje inclui `pendente` e `atrasado`

- [x] **[FIN-08]** — Adicionar filtro de **mês/ano** no `FinancialReportScreen`
  > Dropdown de período para visualizar lucratividade por mês — hoje mostra acumulado histórico sem corte

- [x] **[FIN-09]** — Edge Function: cálculo de **lucro líquido por veículo**
  > Criar view ou função SQL:
  > `lucro_veiculo = SUM(receitas pagas do veículo) - SUM(despesas pagas do veículo - manutenções)`
  > Exibir no `VehicleDetailScreen` como card de rentabilidade do ativo

---

## 🔐 AUDITORIA — Aprovação de Cadastro de Motorista

- [x] **[AUD-01]** `RegistrationAuditScreen` → Integrar com `DriverRepository` real (exibir `status = 'pendente_aprovacao'`).
  > Arquivo: `lib/admin/users/registration_audit_screen.dart`
  > A tela já importa `DriverRepository` mas continua usando `MockRepository`. Substituir `_repository.getDrivers()` por `_driverRepo.getDrivers(status: 'pendente_aprovacao')`

- [x] **[AUD-02]** Implementar botão "Aprovar" que altera `motoristas.status` de `pendente_aprovacao` para `ativo`
  > Chamar `DriverRepository().approveDriver(driverId)` que executa:
  > ```sql
  > UPDATE motoristas SET status = 'ativo' WHERE id = driverId
  > ```
  > Após aprovação, o motorista pode receber contratos

- [x] **[AUD-03]** — Implementar botão "Rejeitar" que altera `motoristas.status` para `bloqueado` com motivo

---

## ⚙️ PAINEL ADMIN — Configuração da Chave PIX

- [x] **[PIX-01] CRÍTICO** — Criar tela de configuração PIX no Painel de Controle
  > Admin cadastra: nome do beneficiário, cidade, tipo de chave PIX (CPF/CNPJ/email/telefone/aleatória) e valor da chave
  > Salvar em `configuracoes_sistema` com chave `'admin_pix_config'` via `PixService.updateConfig()`
  > O `PixService` já está implementado para ler/salvar nessa tabela — só precisa da tabela no banco (DB-01) e da UI

- [x] **[PIX-02]** — Exibir chave PIX configurada na tela `ControlPanelScreen`
  > Mostrar resumo da chave ativa com botão para editar

---

## 🛡️ RBAC — Guard de Rotas por Perfil

- [x] **[RBAC-01]** — Implementar guard de rota no `GoRouter` para verificar `cargo` do usuário
  > Impedir que Gestor acesse `/admin/control-panel/*` mesmo conhecendo a URL
  > Verificar `SupabaseConfig.currentUser?.userMetadata['cargo']` ou buscar `perfis.cargo` na sessão

- [x] **[RBAC-02]** — Corrigir `DriverHomeScreen` e `FinancialStatementScreen`: remover o fallback inseguro
  > Ambas as telas têm código que itera todos os motoristas ativos quando `uid` está vazio — vulnerabilidade grave. Se não houver sessão ativa → redirecionar para login

---

---

# 🔵 GRUPO 3 — APERFEIÇOAMENTOS (Após sistema funcionando)

> Melhorias de UX, edição de perfil e funcionalidades secundárias. Implementar somente após o Grupo 2 estar completo.

---

## 👤 Edição de Perfil

- [ ] **[PERF-01]** — Implementar edição de nome, telefone e foto do perfil pelo próprio motorista
  > Tela `DriverProfileSetupScreen` existe mas precisa persistir dados em `perfis` no Supabase

- [ ] **[PERF-02]** — Implementar upload/atualização de foto de perfil no Storage (`documentos-motoristas`)
  > Usar campo `perfis.foto_url` para exibir e atualizar o avatar

- [ ] **[PERF-03]** — Implementar edição de dados do veículo pelo Admin no `VehicleDetailScreen`
  > Integração direta com edição inline de campos (placa, KM, IPVA, seguro)

- [ ] **[PERF-04]** — Tela de edição de lançamento financeiro individual
  > No `FinancialListScreen`, o botão "Editar Lançamento" existe na UI mas tem comentário `// Lógica de edição futura` — implementar formulário de edição

## 💼 Gestores e Permissões

- [ ] **[GES-01]** — Migrar `ManagerSalariesScreen` do mock para o Supabase
  > Criar tabela `pagamentos_gestores` e conectar a tela — atualmente usa lista hardcoded com nomes fictícios

- [ ] **[GES-02]** — Implementar cálculo de comissão do gestor
  > Usar `gestores.percentual_comissao` × receita do período gerenciado para gerar sugestão de comissão

- [ ] **[GES-03]** — Implementar RBAC granular via `gestor_permissoes`
  > Consultar a tabela `gestor_permissoes` no Flutter para habilitar/desabilitar ações por gestor

- [ ] **[GES-04]** — Implementar RPC de promoção de usuário a gestor em `UserSearchPromotionScreen`
  > Criar RPC segura que altera `perfis.cargo = 'gestor'` e insere em `gestores`

## 🔧 Manutenção — Funcionalidades Extras

- [ ] **[MAN-01]** — Upload de Nota Fiscal (NFe) no formulário de manutenção
  > Campo `nota_fiscal_nfe_url` existe na tabela mas não há botão de upload na UI

- [ ] **[MAN-02]** — Alerta de manutenção preventiva por KM
  > Quando `veiculos.km_atual` atingir múltiplo de KM configurável, gerar item em `historico_atividades`

- [ ] **[MAN-03]** — Ao encerrar manutenção (`status = 'concluido'`), gerar lançamento de despesa automaticamente em `lancamentos_financeiros`

## 🚗 Frota — Alertas de Documentação

- [ ] **[DOC-01]** — Alerta de vencimento de CNH do motorista (30 dias de antecedência)
  > Consultar `motoristas.validade_cnh` e exibir alerta no painel admin

- [ ] **[DOC-02]** — Alerta de vencimento de seguro do veículo
  > Consultar `veiculos.vencimento_seguro` e exibir alerta no painel admin

- [ ] **[DOC-03]** — Trigger que muda `status_ipva` para `atrasado` quando `vencimento_ipva < CURRENT_DATE`

## 🗂️ Histórico e Relatórios

- [ ] **[REL-01]** — Conectar `VehicleUsageHistoryScreen` ao histórico real de contratos do veículo
  > Exibir todos os contratos do veículo com datas, motoristas e valores

- [ ] **[REL-02]** — Adicionar exportação de relatório financeiro (PDF ou CSV)
  > No `FinancialReportScreen`, botão de exportar o período filtrado

- [ ] **[REL-03]** — Conectar `SalaryHistoryScreen` ao histórico real de pagamentos de gestores

## 🛠️ Qualidade de Código

- [ ] **[CODE-01]** — Renomear `mock_repository.dart` para `app_repository.dart` (nome "mock" é enganoso — é uma façade real)

- [ ] **[CODE-02]** — Substituir todos os `catch (_) {}` silenciosos por logging com `debugPrint` e feedback visual ao usuário

- [ ] **[CODE-03]** — Centralizar `_isValidUuid()` em `lib/core/utils/validators.dart` — hoje duplicado em 6+ repositórios

- [ ] **[CODE-04]** — Implementar paginação (offset/limit) nas queries de listagem de lançamentos financeiros, vistorias e veículos

- [ ] **[CODE-05]** — Fixar versão do MCP: mudar `@supabase/mcp-server-supabase@latest` para versão fixada

## 🔧 Suporte ao Motorista

- [ ] **[SUP-01]** — Tela de suporte funcional: criar tabela `chamados_suporte` e conectar `DriverSupportScreen`

- [ ] **[SUP-02]** — `OccurrenceReportScreen`: garantir que ocorrências são persistidas em `chamados_suporte` ou `historico_atividades`

---

---

## 📊 SCORECARD E PROGRESSO

| Dimensão | Antes | Meta Grupo 2 |
|---|---|---|
| Contratos (atribuição de veículo) | 3/10 | 9/10 |
| Check-in do Motorista | 7/10 | 9/10 |
| Financeiro Admin (lista) | 2/10 | 9/10 |
| Cálculo de Parcelas | 4/10 | 9/10 |
| Cálculo de Lucro/Margem | 4/10 | 8/10 |
| Inadimplência | 3/10 | 8/10 |
| Aprovação de Cadastros | 4/10 | 9/10 |
| Configuração PIX Admin | 0/10 | 9/10 |
| Pagamento com Comprovante | 6/10 | 9/10 |
| Guard de Rotas/Segurança | 4/10 | 8/10 |

---

## 🎯 ORDEM DE EXECUÇÃO RECOMENDADA

```
FASE 1 — Base de Dados (desbloqueiam tudo)
  DB-01: Criar tabela configuracoes_sistema
  DB-02: Confirmar seed de categorias contábeis
  DB-03: Edge Function fn_gerar_parcelas_contrato
  DB-04: Edge Function fn_marcar_lancamentos_atrasados
  DB-05: Corrigir denominador da taxa de ocupação
  DB-06: Proteger token do MCP

FASE 2 — Fluxo Principal Admin (Admin atribui carro ao motorista)
  CTR-01: ContractListScreen → Supabase real
  CTR-02: ContractFormScreen → VehicleRepository + DriverRepository reais
  CTR-03: Adicionar campo frequência de cobrança no formulário
- [x] **[AUD-01]** `RegistrationAuditScreen` → Integrar com `DriverRepository` real (exibir `status = 'pendente_aprovacao'`).
- [x] **[PIX-01]** Tela de configuração PIX no Painel de Controle

FASE 3 — Fluxo Principal Motorista (Check-in + Pagamento)
  CHK-01: Corrigir fallback inseguro no DriverHomeScreen
  CHK-02: Testar fluxo completo de Check-in end-to-end
  CHK-03: Bloquear check-in sem contrato ativo
  FIN-05: Persistir QR/PIX no banco + fluxo de comprovante
  FIN-06: Exibir chave PIX do admin para o motorista

FASE 4 — Financeiro Completo
  FIN-01: FinancialListScreen → FinancialRepository real
  FIN-02: DelinquencyListScreen → dados reais
  FIN-03: Gerar parcelas após criar contrato
  FIN-07: Filtrar apenas pagos no relatório
  FIN-08: Filtro por mês/ano no relatório
  RBAC-01: Guard de rotas por cargo
  RBAC-02: Remover fallback inseguro nas telas do motorista

FASE 5 — Aperfeiçoamentos (Grupo 3, sem pressa)
  PERF-01 a PERF-04, GES-01 a GES-04, MAN-01 a MAN-03, etc.
```
