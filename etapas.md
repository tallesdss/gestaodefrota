# 📌 Roadmap de Desenvolvimento — Gestão de Frota Premium

Este documento detalha o plano de execução para o frontend da aplicação, organizado por perfis de acesso e etapas lógicas, com foco na experiência de **Comando Arquitetônico**.

> [!IMPORTANT]
> **REGRA DE ESCOPO:** O foco atual é **100% Frontend**. A migração para o backend ocorrerá somente após a conclusão desta etapa.

---

## 👑 Etapas: Administrador (Proprietário)
*Controle total da operação, infraestrutura e auditoria.*

- [ ] **FASE 1: Fundação & Design System**
    - [ ] **Ambiente:** Inicialização do Flutter e configuração do `pubspec.yaml` (go_router, fl_chart, google_fonts, image_picker).
    - [ ] **Design System:** Implementação de `AppColors`, `AppTextStyles` e `AppSpacing` seguindo a filosofia de camadas tonais.
    - [ ] **Camada de Dados Mock:** Criação dos modelos e repositórios com dados fictícios para Veículos, Motoristas, Contratos e Financeiro.
    - [ ] **Navegação:** Configuração das rotas base no `app_routes.dart` separando os fluxos `/register`, `/admin`, `/gestor` e `/driver`.
    - [ ] **Fluxo de Onboarding Geral:** Implementação das telas de "Criar Conta" e seleção de perfil (Gestor ou Motorista).

- [ ] **FASE 2: Dashboard de Comando e Gestão de Ativos**
    - [ ] **Dashboard Principal:** Cards de KPI monumentais, Gráficos de Receita vs Despesa e Alertas de documentos (IPVA, CNH).
    - [ ] **Gestão de Usuários:** Fluxo de criação e edição de perfis para **Gestores** e **Motoristas**.
    - [ ] **Auditoria de Cadastro:** Validação e aprovação dos documentos enviados por novos usuários (Self-Registration).
    - [ ] **Gestão de Frota & Motoristas:** Listagem editorial com filtros, detalhes técnicos do veículo e histórico completo do motorista.

- [ ] **FASE 3: Estrutura de Contratos**
    - [ ] **Gestão de Contratos:** Fluxo de criação de novos vínculos entre veículo e motorista.
    - [ ] **Regras de Negócio:** Definição de valores, periodicidade e termos do contrato.

- [ ] **FASE 4: Manutenção & Auditoria de Segurança**
    - [ ] **Manutenção Preventiva:** Registro e controle de trocas de óleo, pneus e revisões futuras.
    - [ ] **Auditoria de Vistorias:** Tela de revisão para comparar fotos de Check-in vs Check-out e geração de laudo simplificado.

- [ ] **FASE 5: Polimento & UX Premium**
    - [ ] **Micro-interações:** Animações de transição e feedbacks táteis.
    - [ ] **Tonal Layering Review:** Revisão de contrastes e superfícies.
    - [ ] **Estados de Carregamento:** Implementação de Skeleton screens (shimmer).

---

## 🏢 Etapas: Gestor
*Operação financeira e supervisão imediata.*

- [ ] **FASE 1: Onboarding & Perfil**
    - [ ] **Módulo de Auto-Cadastro:** Fluxo para o Gestor criar sua conta e enviar documentos de identificação.
    - [ ] **Módulo Financeiro Operacional:** Tela específica para confirmar recebimentos e mudar status para "Pago".
    - [ ] **Controle de Inadimplência:** Visualização clara de parcelas "Em Aberto", "Atrasadas" e "Pagas".
- [ ] **FASE 2: Gestão de Equipe**
    - [ ] **Cadastro de Motoristas:** Permissão para criar e editar perfis de **Motoristas**.
    - [ ] **Monitoramento de Alertas:** Acompanhamento de pendências urgentes sinalizadas pelo sistema (CNH vencendo, mensalidades em atraso).

---

## 🚗 Etapas: Motorista
*Interface móvel focada em agilidade e transparência.*

- [ ] **FASE 1: Onboarding & Portal**
    - [ ] **Módulo de Auto-Cadastro:** Entrada do motorista e envio de documentos (CNH, Comprovante de Residência).
    - [ ] **Home:** Status do veículo vinculado e situação financeira imediata.
    - [ ] **Fluxo de Check-in (Início):** Validação de KM, Checklist de combustível e Vistoria Fotográfica (6 fotos obrigatórias).
    - [ ] **Fluxo de Check-out (Devolução):** Comparação fotográfica e cálculo automático de KM rodados.

- [ ] **FASE 2: Pagamentos e Financeiro**
    - [ ] **Minhas Mensalidades:** Histórico de pagamentos e próximos vencimentos.
    - [ ] **Pagamento via PIX (Mock):** Geração de QR Code estático, função "Copia e Cola" e envio de comprovante via galeria.

---

### 📝 Resumo das Responsabilidades Técnicas:
*   **Administrador:** Define a estrutura, audita vistorias e monitora a saúde global da frota.
*   **Gestor:** Foca no fluxo de caixa e na regularização manual de pagamentos.
*   **Motorista:** Responsável pela integridade física do veículo (vistorias) e pontualidade financeira.
*   **Sistema:** Garante a consistência dos dados mockados e a transição suave entre os estados da aplicação.