# ☁️ SaaS Roadmap: Completação do Frontend Multi-Tenant

Este documento serve como o guia mestre para a finalização do sistema SaaS na branch `CRMSAAS`. O foco é exclusivamente no **Frontend** e na experiência do **SaaS Master (Super Administrador)**.

---

## 🏛️ Fase 1: Gestão de Empresas (Tenants)
*O coração do SaaS: Gerenciar quem entra e como opera.*

- [x] **Módulo de Onboarding (Wizard)**: Fluxo passo-a-passo para criação de novos inquilinos (`CompanyWizardScreen`).
- [ ] **Dashboard Master das Empresas**:
    - [ ] Listagem consolidada de todas as empresas cadastradas.
    - [ ] Filtros por status (Ativo, Suspenso, Aguardando Pagamento).
- [ ] **Tela de Detalhes & Edição da Empresa**:
    - [ ] Edição de dados cadastrais (Razão Social, CNPJ, Contato).
    - [ ] Configuração de limites (Máximo de veículos, usuários, motoristas).
    - [ ] Upgrade/Downgrade de planos.
- [ ] **Funcionalidade: Entrar como Empresa (Impersonation)**:
    - [ ] Botão "Acessar Painel" na listagem de empresas.
    - [ ] Lógica para commutar o `companyId` no `TenantManager`.
    - [ ] Header de segurança indicando: *"Você está navegando como [Empresa X]"* com botão de "Sair e Voltar ao Master".

---

## 💰 Fase 2: Controle Financeiro & Cobrança (Billing Master)
*Monitorar se as empresas estão em dia e o faturamento global.*

- [ ] **Balancete de Pagamentos (Billing Overview)**:
    - [ ] Lista de faturas geradas por empresa.
    - [ ] Status visual: **Pago** vs **Pendente**.
    - [ ] Botão de "Confirmar Pagamento Manual" (para transferências diretas).
- [ ] **Dashboard de Receita (MRR)**:
    - [ ] Visualização do faturamento mensal recorrente total.
    - [ ] Gráfico de crescimento de faturamento vs meses anteriores.
- [ ] **Controle de Inadimplência**:
    - [ ] Interface para listar todas as empresas com faturas atrasadas.
    - [ ] Botão rápido para "Suspender Acesso" da empresa inadimplente.
- [ ] **Configuração de Planos**:
    - [x] Visualização de planos existentes.
    - [ ] CRUD completo de novos planos (Preço, recorrência e permissões).

---

## 🎨 Fase 3: White-Label & Personalização
*Dar identidade visual para os clientes.*

- [ ] **Módulo de Customização de Marca**:
    - [ ] Upload de logotipos personalizados por tenant.
    - [ ] Seletor de cores primárias e secundárias para o Dashboard do cliente.
- [ ] **Dynamic Theme Engine**:
    - [ ] Lógica de frontend para aplicar o esquema de cores injetado pelo `TenantManager` em toda a UI.

---

## 🔧 Fase 4: Suporte & Auditoria
- [ ] **Log de Auditoria Master**:
    - [ ] Tela para visualizar ações críticas tomadas em qualquer empresa.
- [ ] **Central de Comunicados**:
    - [ ] Enviar avisos globais (banners) que aparecem para todos os administradores das empresas.

---

## 🏗️ Guia de Implementação (Passo a Passo)

### 1. Sistema de "Shadow Mode" (Impersonation)
O Super Admin precisa navegar pelo sistema como se fosse o cliente.
- [ ] Criar modal de confirmação ao clicar em "Acessar Empresa".
- [ ] No `TenantManager`, adicionar um `bool isImpersonating` e o `originalMasterId`.
- [ ] Atualizar o `AppBar` para exibir uma faixa colorida (branding Master) quando estiver nesse modo.

### 2. Edição de Dados da Empresa
- [ ] Criar formulário em `lib/super_admin/companies/edit_company_screen.dart`.
- [ ] Permitir alteração de status (`active`, `suspended`, `trial`).

### 3. Painel de Faturas (Ocupado/Não Pago)
- [ ] Mockar uma lista de faturas em `mock_billings.dart`.
- [ ] Criar tela `BillingManagementScreen` com cards coloridos por status.

---

### 📝 Resumo Técnico:
*   **Branch:** `CRMSAAS`
*   **Estado:** Frontend Mockado (Sem persistência real em DB por enquanto).
*   **Foco Visual:** Design System *Architectural Command* (Limpo, tonal, premium).

---

> [!TIP]
> **Dica para o Desenvolvedor**: Use o `TenantManager` para centralizar a troca de contexto. Todas as telas existentes (Veículos, Financeiro, etc) já filtram os dados automaticamente se o `companyId` for alterado.
