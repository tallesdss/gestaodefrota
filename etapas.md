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

- [x] **FASE 3: Estrutura de Contratos & Ativos**
    - [x] **Gestão de Contratos:** Fluxo de criação de novos vínculos entre veículo e motorista.
    - [x] **Regras de Negócio:** Definição de valores, periodicidade e termos do contrato (Interface de alta densidade de dados).

- [x] **FASE 4: Manutenção & Auditoria de Segurança**
    - [x] **Manutenção Preventiva:** Registro e controle de trocas de óleo, pneus e revisões futuras.
    - [x] **Auditoria de Vistorias:** Tela de revisão estrutural para comparar fotos de Check-in vs Check-out e geração de laudo premium.

- [x] **FASE 5: Polimento & UX Premium**
    - [x] **Micro-interações:** Animações de transição (Hero) e feedbacks táteis.
    - [x] **Relatórios PDF:** Geração de extratos financeiros e checklists de vistoria em PDF.
    - [x] **Estados de Carregamento:** Implementação de skeletons e feedback visual de progresso.

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
*Interface focada em agilidade, contraste e uso em campo.*

- [ ] **FASE 1: Onboarding & Portal do Condutor**
    - [ ] **Módulo de Auto-Cadastro:** Entrada do motorista e upload de documentos (CNH, Comprovante de Residência).
    - [ ] **Home:** Status do veículo vinculado e situação financeira imediata.
    - [ ] **Fluxo de Check-in (Início):** Validação de KM, Checklist e Vistoria Fotográfica (6 fotos obrigatórias).
    - [ ] **Fluxo de Check-out (Devolução):** Comparação fotográfica e cálculo automático de KM rodados.

- [ ] **FASE 2: Pagamentos e Financeiro**
    - [ ] **Minhas Mensalidades:** Histórico de pagamentos e próximos vencimentos com visualização de "Status Chips".
    - [ ] **Pagamento via PIX (Mock):** Geração de QR Code estático e upload de comprovante.

---

### 📝 Resumo das Responsabilidades Técnicas:
*   **Administrador:** Perfil "Superuser". Possui acesso irrestrito, define a estrutura da frota e possui autoridade final em auditorias.
*   **Gestor:** Foca na saúde financeira imediata e na gestão humana, utilizando um subconjunto das ferramentas do Admin.
*   **Motorista:** Responsável pela operação do ativo e conformidade financeira.
*   **Sistema:** Regula a visibilidade e acesso aos módulos com base no `user_role` atribuído no banco de dados.