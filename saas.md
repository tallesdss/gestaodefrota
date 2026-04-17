# Checklist de Telas: Super Administrador (SaaS Master)

Este documento lista todas as telas e funcionalidades necessárias para o **Super Administrador** gerenciar a plataforma como um SaaS, permitindo o isolamento de múltiplas empresas e o controle centralizado.

---

## 1. Dashboard Global (Visão Panorâmica)
- [ ] **Dashboard Master**: Resumo total do ecossistema (Empresas ativas, faturamento mensal acumulado, frota total no sistema).
- [ ] **Gráficos de Crescimento**: Evolução de novas adesões e cancelamentos (Churn rate).
- [ ] **Mapa de Calor**: Localização geográfica das empresas/frotas em tempo real.
- [ ] **Alertas de Faturamento**: Empresas com pagamentos em atraso ou vencendo hoje.

---

## 2. Gestão de Empresas (Tenants)
- [ ] **Listagem de Empresas**: Tabela com filtros por Plano, Status (Ativa/Inativa) e Quantidade de Veículos.
- [ ] **Cadastro de Nova Empresa (Wizard de Onboarding)**:
    - [ ] Dados Cadastrais (CNPJ, Razão Social, Nome Fantasia).
    - [ ] Dados de Contato/Proprietário (Admin Master da empresa).
    - [ ] Configuração de Endereço e Fuso Horário.
- [ ] **Painel de Controle da Empresa (Visão 360)**:
    - [ ] Edição de dados e limite de veículos.
    - [ ] Configuração de Módulos (ex: habilitar ou desabilitar módulo de Oficina/Manutenção).
    - [ ] Histórico de faturas e pagamentos.
    - [ ] Botão "Acessar como Empresa" (Shadow Access para suporte).
- [ ] **Suspensão/Bloqueio**: Interface para bloqueio imediato de acesso por inadimplência.

---

## 3. Planos e Monetização
- [ ] **Gestão de Planos**: Cadastro de tiers (ex: Basic, Pro, Enterprise).
- [ ] **Configuração de Preços/Limites**:
    - [ ] Preço por veículo ou preço fixo.
    - [ ] Limite de usuários administradores por empresa.
    - [ ] Limite de motoristas e vistorias mensais.
- [ ] **Gestão de Cupons e Descontos**: Criação de códigos promocionais para novas empresas.

---

## 4. Financeiro Master
- [ ] **Relatório de Faturamento Global**: Listagem detalhada de todas as receitas.
- [ ] **Controle de Inadimplência**: Sistema de avisos e bloqueios automáticos.
- [ ] **Histórico de Transações**: Integração com gateway de pagamento (Stripe/Asaas/etc).

---

## 5. White-Label e Personalização Global
- [ ] **Configurações de Branding**: 
    - [ ] Upload de logos para o painel de todas as empresas (White-label).
    - [ ] Customização de cores primárias do sistema.
- [ ] **Configurações de E-mail/SMTP**: Personalização do remetente dos e-mails de sistema (notificações, vistorias).

---

## 6. Logs e Segurança
- [ ] **Audit Log Master**: Registro de quem alterou o quê em qual empresa.
- [ ] **Monitoramento de Erros**: Dashboard de logs técnicos para suporte proativo.
- [ ] **Gestão de Usuários Master**: Cadastro de funcionários do Super Admin (Atendentes, Gerentes de Conta).

---

## 7. Módulo de Suporte Centralizado
- [ ] **Central de Ajuda SaaS**: Gestão de manuais e tutoriais que aparecem para todos os clientes.
- [ ] **Sistema de Tickets master**: Recebimento e resposta de chamados de suporte de todas as empresas.
