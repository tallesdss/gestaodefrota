# Plano de Transformação SaaS - Gestão de Frota

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

## 3. Checklist de Telas e Funcionalidades: Super Administrador (SaaS Master)

Abaixo, o checklist das telas necessárias para a parte de Super Administração que ainda precisam ser implementadas no frontend:

### 3.1 Dashboard Global (Visão Panorâmica)
- [ ] **Dashboard Master**: Resumo total do ecossistema (Empresas ativas, faturamento mensal acumulado, frota total no sistema).
- [ ] **Gráficos de Crescimento**: Evolução de novas adesões e cancelamentos (Churn rate).
- [ ] **Mapa de Calor**: Localização geográfica das empresas/frotas em tempo real.
- [ ] **Alertas de Faturamento**: Empresas com pagamentos em atraso ou vencendo hoje.

### 3.2 Gestão de Empresas (Tenants)
- [ ] **Listagem de Empresas**: Tabela com filtros por Plano, Status (Ativa/Inativa) e Quantidade de Veículos.
- [ ] **Cadastro de Nova Empresa (Wizard de Onboarding)**:
    - [ ] Dados Cadastrais (CNPJ, Razão Social, Nome Fantasia).
    - [ ] Dados de Contato/Proprietário (Admin Master da empresa).
    - [ ] Configuração de Endereço e Fuso Horário.
    - [ ] Configuração de Plano (Seleção de limite de veículos e módulos ativos).
- [ ] **Painel de Controle da Empresa (Visão 360)**:
    - [ ] Edição de dados e limite de veículos.
    - [ ] Configuração de Módulos (ex: habilitar ou desabilitar módulo de Oficina/Manutenção).
    - [ ] Histórico de faturas e pagamentos.
    - [ ] Botão "Acessar como Empresa" (Shadow Access para suporte).
- [ ] **Suspensão/Bloqueio**: Interface para bloqueio imediato de acesso por inadimplência.

### 3.3 Planos e Monetização
- [ ] **Gestão de Planos**: Cadastro de tiers (ex: Basic, Pro, Enterprise).
- [ ] **Configuração de Preços/Limites**:
    - [ ] Preço por veículo ou preço fixo.
    - [ ] Limite de usuários administradores por empresa.
    - [ ] Limite de motoristas e vistorias mensais.
    - [ ] Definição de permissões por plano (ex: Plano Básico não tem acesso ao módulo de oficina).
- [ ] **Gestão de Cupons e Descontos**: Criação de códigos promocionais para novas empresas.

### 3.4 Financeiro Master
- [ ] **Relatório de Faturamento Global**: Listagem detalhada de todas as receitas e relatórios de inadimplência.
- [ ] **Controle de Inadimplência**: Sistema de avisos e bloqueios automáticos.
- [ ] **Histórico de Transações**: Integração com gateway de pagamento (Stripe/Asaas/etc).

### 3.5 White-Label e Personalização Global
- [ ] **Configurações de Branding**: 
    - [ ] Upload de logos para o painel de todas as empresas (White-label).
    - [ ] Customização de cores primárias do sistema.
- [ ] **Configurações de E-mail/SMTP**: Personalização do remetente dos e-mails de sistema (notificações, vistorias).

### 3.6 Logs e Segurança
- [ ] **Audit Log Master**: Registro de quem alterou o quê em qual empresa.
- [ ] **Monitoramento de Erros**: Dashboard de logs técnicos para suporte proativo.
- [ ] **Gestão de Usuários Master**: Cadastro de funcionários do Super Admin (Atendentes, Gerentes de Conta).

### 3.7 Módulo de Suporte Centralizado
- [ ] **Central de Ajuda SaaS**: Gestão de manuais e tutoriais que aparecem para todos os clientes.
- [ ] **Sistema de Tickets master**: Recebimento e resposta de chamados de suporte de todas as empresas.

---

## 4. Diretrizes de Design (Super Admin)

Seguindo o **Design System: Architectural Command**:
- **Paleta Elevada:** O Super Admin deve usar tons levemente mais escuros que o admin comum para denotar autoridade (ex: `surface` com um toque mais focado em Azul Profundo).
- **Sem Linhas:** Divisões entre empresas na listagem devem usar `tonal layering`, não bordas de 1px.
- **Tipografia:** Uso extensivo de *Manrope* para KPIs globais, transmitindo segurança e controle.

---

> [!NOTE]  
> Este documento é um guia de implementação frontend para a branch `CRMSAAS`. Este planejamento visa a escalabilidade da plataforma para múltiplos clientes.
