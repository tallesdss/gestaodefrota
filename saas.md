# Plano de Transformação SaaS - Gestão de Frota

Este documento detalha o planejamento para transformar o sistema atual de gestão de frota em uma plataforma **SaaS (Software as a Service)** multi-empresa. O objetivo é permitir que múltiplas empresas utilizem o sistema de forma isolada, sendo gerenciadas por um **Super Administrador**.

---

## 1. Arquitetura Multi-tenancy (Frontend)

Para suportar múltiplas empresas no frontend, seguiremos estes princípios:
- **Identificadores de Empresa:** Todas as requisições e dados serão filtrados por um `company_id`.
- **White-labeling:** O sistema deve suportar personalização básica (logo e cores primárias) por empresa.
- **Isolamento de Rotas:** Subdomínios ou contextos de rota claros para cada empresa (ex: `app.frota.com/empresa-a/...`).

---

## 2. Módulo Super Administrador (Super Admin)

O Super Administrador é o nível mais alto de acesso, responsável por gerenciar o ecossistema SaaS.

### Funções Principais:
- **Gestão de Empresas:** Cadastro, Bloqueio/Ativação e Edição de dados corporativos.
- **Controle de Assinaturas:** Gestão de planos (Básico, Pro, Enterprise) e vencimentos.
- **Monitoramento Global:** Dashboards com métricas agregadas de todos os clientes.
- **Suporte Centralizado:** Acesso a logs de erros e tickets de suporte de todas as empresas.

---

## 3. Detalhamento das Telas do Super Administrador

### 3.1 Dashboard Global
- **KPIs:** Total de empresas ativas, total de veículos no sistema (soma de todos), faturamento mensal total.
- **Gráficos:** Crescimento de novas empresas por mês, distribuição de planos.
- **Alertas:** Empresas com faturas vencidas, empresas próximas do limite de veículos do plano.

### 3.2 Gestão de Empresas (Listagem e Filtros)
- **Componentes:** Tabela de alta fidelidade com filtros por status (Ativa/Inativa), plano e data de adesão.
- **Ações:** "Visualizar como empresa" (Shadow mode), Editar, Suspender Acesso.

### 3.3 Cadastro de Novas Empresas (Onboarding)
- **Campos:** 
  - Dados Jurídicos (CNPJ, Nome Fantasia, Razão Social).
  - Dados do Proprietário (Nome, E-mail, Telefone).
  - Configuração de Plano (Seleção de limite de veículos e módulos ativos).
  - Configuração Inicial (Moeda, Fuso Horário).

### 3.4 Gestão de Planos
- Cadastro de níveis de serviço (Tiers).
- Definição de permissões por plano (ex: Plano Básico não tem acesso ao módulo de oficina).

---

## 4. Checklist de Telas (Super Administrador)

Abaixo, o checklist das telas necessárias para a parte de Super Administração que ainda precisam ser implementadas no frontend:

- [ ] **Login de Super Administrador** (Layout diferenciado para acesso master)
- [ ] **Dashboard Global Master** (Métricas agregadas de todo o ecossistema)
- [ ] **Módulo: Gestão de Empresas**
    - [ ] Listagem de Empresas (Com filtros avançados e status)
    - [ ] Formulário de Cadastro de Empresa (Passo a passo/Onboarding)
    - [ ] Tela de Detalhes da Empresa (Visão 360 do cliente)
    - [ ] Edição de Dados e Configurações de Empresa
- [ ] **Módulo: Planos e Tarifação**
    - [ ] Listagem de Planos Disponíveis
    - [ ] Criação/Edição de Planos (Configuração de limites e preços)
- [ ] **Módulo: Financeiro Global**
    - [ ] Relatórios de Inadimplência
    - [ ] Histórico de Faturas SaaS
- [ ] **Módulo: Configurações do Sistema**
    - [ ] Branding Global (White-label do Super Admin)
    - [ ] Logs de Atividade Global (Audit Log)

---

## 5. Diretrizes de Design (Super Admin)

Seguindo o **Design System: Architectural Command**:
- **Paleta Elevada:** O Super Admin deve usar tons levemente mais escuros que o admin comum para denotar autoridade (ex: `surface` com um toque mais focado em Azul Profundo).
- **Sem Linhas:** Divisões entre empresas na listagem devem usar `tonal layering`, não bordas de 1px.
- **Tipografia:** Uso extensivo de *Manrope* para KPIs globais, transmitindo segurança e controle.

---

> [!NOTE]  
> Este documento é um guia de implementação frontend para a branch `CRMSAAS`. Nenhuma alteração no código atual do projeto foi realizada.
