# ☁️ SaaS Roadmap: Completação do Frontend Multi-Tenant

Este documento serve como o guia mestre para a finalização do sistema SaaS na branch `CRMSAAS`. O foco é exclusivamente no **Frontend** e na experiência do **SaaS Master (Super Administrador)**.

---

## 🏛️ Fase 1: Gestão de Empresas (Tenants) - 🟢 CONCLUÍDO
1.  **Dashboard Master das Empresas**:
    *   [x] Listagem consolidada com filtros (Status, Plano).
    *   [x] KPIs globais (Total de veículos, faturamento aproximado).
2.  **Tela de Detalhes da Empresa**:
    *   [x] Visualização de dados cadastrais.
    *   [x] Estatísticas de uso de recursos (Barra de progresso).
    *   [x] Gestão de usuários/colaboradores daquela empresa.
    *   [x] Ações: Suspender, Bloquear, Excluir.
3.  **Shadow Mode (Impersonation)**:
    *   [x] Funcionalidade "Entrar como Cliente".
    *   [x] Header de segurança indicando a sessão ativa.
    *   [x] Botão para sair da sessão e voltar ao painel master.

---

## 💰 Fase 2: Faturamento e Assinaturas - 🟢 CONCLUÍDO
1.  **Módulo Financeiro Master**:
    *   [x] Painel de faturas pendentes de todas as empresas (`BillingManagementScreen`).
    *   [x] Sistema de avisos automáticos de faturamento.
2.  **Configuração de Planos**:
    *   [x] Visualização de planos existentes.
    *   [x] CRUD completo de novos planos (`PlanManagementScreen`).
    *   [x] Gestão de limites de recursos por plano.

- [x] **Balancete de Pagamentos (Billing Overview)**:
    - [x] Lista de faturas geradas por empresa.
    - [x] Status visual: **Pago** vs **Pendente**.
    - [x] Botão de "Confirmar Pagamento Manual".
- [x] **Dashboard de Receita (MRR)**:
    - [x] Visualização do faturamento mensal recorrente total.
- [x] **Controle de Inadimplência**:
    - [x] Interface para listar todas as empresas com faturas atrasadas.

---

## 🎨 Fase 3: White-Label & Personalização
*Dar identidade visual para os clientes.*

- [ ] **Módulo de Customização de Marca**:
    - [ ] Upload de logotipos personalizados por tenant.
    - [ ] Seletor de cores primárias e secundárias.

---

## 🔧 Fase 4: Suporte & Auditoria - 🟢 CONCLUÍDO
- [x] **Log de Auditoria Master**:
    - [x] Tela para visualizar ações críticas tomadas em qualquer empresa (`AuditLogScreen`).
    - [x] Rastreamento de Impersonation, Pagamentos e Alterações de Planos.

---

## 🏗️ Guia de Implementação (Status)

### 1. Sistema de "Shadow Mode" (Impersonation) - ✅ CONCLUÍDO
*   Implementado via `SuperAdminManager` sincronizado com `TenantManager`.
*   Banner de segurança adicionado ao `AdminScaffold` e `DriverScaffold`.

### 2. Edição de Dados da Empresa - ✅ CONCLUÍDO
*   Tela `CompanyDetailScreen` unifica visualização e ações rápidas.

### 3. Faturamento & Auditoria - ✅ CONCLUÍDO
*   Implementado `SaaSFinancialManager` (State) e `AuditManager` (Logs).
*   Interfaces premium para gestão de faturas e planos.

---

### 📝 Resumo Técnico:
*   **Branch:** `CRMSAAS`
*   **Estado:** Fase 1, 2 e 4 Finalizadas.
*   **Foco Visual:** Design System *Architectural Command*.

---

> [!TIP]
> **Dica para o Desenvolvedor**: Use o `TenantManager` para centralizar a troca de contexto. Todas as telas existentes (Veículos, Financeiro, etc) já filtram os dados automaticamente se o `companyId` for alterado.
