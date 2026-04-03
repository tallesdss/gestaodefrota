# 📌 Roadmap de Desenvolvimento — Gestão de Frota Premium

Este documento detalha o plano de execução para o frontend da aplicação, organizado por perfis de acesso e etapas lógicas, sob a filosofia de **Comando Arquitetônico**.

> [!IMPORTANT]
> **REGRA DE ESCOPO:** O foco atual é **100% Frontend**. A migração para o backend ocorrerá somente após a conclusão desta etapa de design e funcionalidade mockada.

---

## 👑 Etapas: Administrador (Centro de Comando Master)
*Controle total da infraestrutura, auditoria de ativos e supervisão de toda a operação financeira e humana.*

- [x] **FASE 1: Fundação & Design System (Editorial Command)**
    - [x] **Ambiente:** Inicialização do Flutter e configuração do `pubspec.yaml` (go_router, fl_chart, google_fonts, image_picker).
    - [x] **Design System:** Implementação de `AppColors`, `AppTextStyles` e `AppSpacing` (Camadas Tonais e No-Line Rule).
    - [x] **Camada de Dados Mock:** Criação dos modelos e repositórios com dados fictícios para Veículos, Motoristas, Contratos e Financeiro.
    - [x] **Navegação:** Configuração das rotas base no `app_routes.dart` separando os fluxos `/auth`, `/admin`, `/gestor` e `/driver`.
    - [x] **Fluxo de Onboarding Geral:** Implementação das telas de "Criar Conta" e seleção de perfil (Gestor ou Motorista).

- [x] **FASE 2: Dashboard de Comando & Gestão de Ativos**
    - [x] **Dashboard Principal:** Cards de KPIs monumentais, Gráficos de Receita vs Despesa e Painel de Monitoramento de Alertas (CNH, IPVA).
    - [x] **Módulo Financeiro Editorial:** Tela de fluxo de caixa, confirmação de recebimentos (Baixa Manual) e Controle de Inadimplentes.
    - [x] **Gestão de Usuários e Equipe:** Fluxo de criação e edição de perfis para **Gestores** e **Motoristas**.
    - [x] **Auditoria de Cadastro:** Validação e aprovação dos documentos enviados por novos usuários (Self-Registration).
    - [x] **Gestão de Frota:** Listagem editorial com filtros, detalhes técnicos do veículo e histórico de utilização.
    - [x] **Detalhamento do Perfil do Motorista (Visualização 360º):**
        - [x] **Análise Financeira:** KPI de total rendido (LTV) e saldo devedor atual (Inadimplência).
        - [x] **Histórico de Ativos:** Lista cronológica de veículos alugados e períodos de posse.
        - [x] **Central de Documentos:** Atalhos rápidos para CNH, Contrato Digital e Residência.
        - [x] **Timeline de Atividades:** Histórico completo de eventos, multas e ocorrências.
        - [x] **Histórico de Vistorias:** Resumo de check-ins e check-outs vinculados ao motorista.

- [x] **FASE 3: Estrutura de Contratos & Ativos**
    - [x] **Gestão de Contratos:** Fluxo de criação de novos vínculos entre veículo e motorista.
    - [x] **Regras de Negócio:** Definição de valores, periodicidade e termos do contrato (Interface de alta densidade de dados).

- [x] **FASE 4: Manutenção & Auditoria de Segurança**
    - [x] **Manutenção Preventiva:** Registro e controle de trocas de óleo, pneus e revisões futuras.
    - [x] **Auditoria de Vistorias:** Tela de revisão estrutural para comparar fotos de Check-in vs Check-out e geração de laudo premium.

- [x] **FASE 6: Gestão de Oficinas (Centro de Manutenção Corretiva)**
    - [x] **Módulo de Oficinas Credenciadas:** Listagem editorial com filtros, ratings de prestação de serviço e status de credenciamento.
    - [x] **Perfil 360 da Oficina:**
        - [x] **Dashboard Financeiro:** KPIs de Valor Pago, Saldo a Pagar e Histórico de Gasto Médio.
        - [x] **Linha do Tempo de Manutenções:** Lista completa de serviços realizados em todos os veículos da frota.
        - [x] **Gestão de Suprimentos:** Lista de peças compradas/trocadas e controle de estoque (mock).
        - [x] **Repositório Fiscal:** Central de notas fiscais eletrônicas (NFe) e recibos digitalizados.
    - [x] **Fluxo de Credenciamento (CRUD):** Cadastro completo de novas oficinas parceiras com dados técnicos e bancários.

- [x] **FASE 5: Polimento & UX Premium**

---

## 🏢 Perfil: Gestor (Operação e Supervisão)
*O Gestor utiliza as ferramentas do Administrador com um filtro de permissão em nível de dados (RBAC).*

- [x] **Visibilidade e Ações Operacionais:**
    - [x] **Dashboard Restrito:** Acesso aos dados financeiros do dia-a-dia e status de pagamento.
    - [x] **Gestão de Equipe:** Permissão para cadastrar novos motoristas e monitorar alertas urgentes.
    - [x] **Ações Permitidas:** Gestão de baixas financeiras, edição de documentos de motoristas e acompanhamento de vistorias.
    - [ ] **Restrição:** Sem acesso às configurações estruturais da frota ou auditoria master do sistema.

---

## 🚗 Etapas: Motorista (Mobilidade e Transparência)
*Foco em agilidade, interface de alto contraste para uso em campo (Touch-First) e transparência total de dados.*

- [x] **FASE 1: Identidade Digital & Auto-Cadastro**
    - [x] **Onboarding Premium:** Fluxo guiado para upload de documentos (CNH e Comprovante de Residência) com feedback visual de análise.
    - [x] **Assinatura de Termo de Uso:** Aceite digital dos termos de locação e política de privacidade integrado ao app.
    - [x] **Perfil do Condutor:** Edição de dados pessoais e visualização de "Score de Confiança" (Gamificação mockada).

- [x] **FASE 2: Central de Mobilidade (Home das Operações)**
    - [x] **Status do Veículo Ativo:** Card monumental com placa, modelo, KM atual e status de manutenção preventiva.
    - [x] **Documentos Digitais:** Acesso rápido ao CRLV do veículo e Cartão de Seguro (Disponível para uso offline).
    - [x] **Timeline de Atividades:** Histórico de avisos, manutenções agendadas e mensagens diretas da gestão.

- [x] **FASE 3: Auditoria Progressiva (Vistorias e Check-ins)**
    - [x] **Fluxo de Check-in (Retirada):** Vistoria guiada 360º com fotos obrigatórias (conforme `vistoria.md`) e validação de KM inicial.
    - [x] **Relatório de Ocorrências:** Canal dedicado para reportar novos danos ou problemas mecânicos encontrados durante a jornada.
    - [x] **Fluxo de Check-out (Devolução):** Comparativo visual de fotos anteriores e cálculo automático de KM para fechamento de ciclo.

- [x] **FASE 4: Gestão Financeira Self-Service**
    - [x] **Extrato Consolidado:** Linha do tempo visual detalhando mensalidades, taxas, multas e créditos.
    - [x] **Checkout via PIX:** Geração de QR Code dinâmico ("Copia e Cola") e upload simplificado de comprovante de pagamento.
    - [x] **Central de Recibos:** Histórico de faturas quitadas com opção de download de comprovantes em PDF.

- [x] **FASE 5: Suporte e Segurança**
    - [x] **Notificações Push Premium:** Alertas inteligentes de vencimento, mensagens de sistema e avisos críticos de segurança.
    - [x] **Botão de Emergência/Suporte:** Canal direto de ação rápida (WhatsApp/Telefone) para assistência mecânica ou jurídica 24h.
    - [x] **FAQ do Condutor:** Manual interativo contendo regras de uso da frota, diretrizes de multas e procedimentos pós-acidente.

- [x] **FASE 6: Perfil Detalhado & Gestão de Dados**
    - [x] **Meu Perfil Editorial:** Visualização de Score de confiança, estatísticas de KM rodado e tempo de casa.
    - [x] **Central de Documentos:** Visualização da CNH Digital, Contrato Assinado e Comprovante de Residência com status de validade.
    - [x] **Segurança da Conta:** Fluxo de alteração de senha, autenticação biométrica (mock) e exclusão de conta conforme LGPD.

- [x] **FASE 7: Responsividade & Web Experience (Comando Multi-Plataforma)**
    - [x] **Adaptive Navigation:** Implementação de Sidebar (Lateral) em telas Desktop e Bottom Navigation em Mobile.
    - [x] **Layout Fluído:** Otimização do dashboard e extratos para grids e visualização de alta densidade em monitores grande.
    - [x] **Centralização de Acesso:** Unificação do fluxo de navegação do motorista sob o `DriverScaffold` responsivo.

---

### 📝 Resumo das Responsabilidades Técnicas:
*   **Administrador:** Perfil "Superuser". Possui acesso irrestrito, define a estrutura da frota e possui autoridade final em auditorias.
*   **Gestor:** Foca na saúde financeira imediata e na gestão humana, utilizando um subconjunto das ferramentas do Admin.
*   **Motorista:** Responsável pela operação do ativo e conformidade financeira.
*   **Sistema:** Regula a visibilidade e acesso aos módulos com base no `user_role` atribuído no banco de dados.