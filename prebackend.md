> **Status:** `100% CONCLUÍDO & VALIDADO`  
> **Próxima Etapa:** Execução da **FASE 1** do [`backendplano.md`](file:///c:/gestaodefrota/backendplano.md) no Supabase.

---

## 🎨 1. Correções de Layout, UI & Design System

- [x] **1.1. Resolução de Overflows de Tela:**
  - [x] Corrigir erro de RenderFlex (`A RenderFlex overflowed by 78 pixels on the bottom`) no Extrato Financeiro / Formulários em telas menores. *(Refatorado com CustomScrollView no Extrato)*
  - [x] Envolver formulários e colunas extensas em `SingleChildScrollView` com `SafeArea` para evitar quebras quando o teclado virtual abrir.
- [x] **1.2. Fallbacks de Imagens & Avatares:**
  - [x] Remover URLs externas instáveis (como `pravatar.cc`) que geram erro de rede `statusCode: 0`.
  - [x] Implementar componente de Avatar (`AppAvatar`) com iniciais do nome e fallback nativo caso a URL da foto seja nula ou falhe em rede.
- [x] **1.3. Auditoria do Design System (Conformidade com `regras.md`):**
  - [x] Verificar se 100% dos textos utilizam `AppTextStyles.*`.
  - [x] Verificar se 100% das cores utilizam `AppColors.*` (sem `Color(0xFF...)` solto).
  - [x] Verificar se 100% dos espaçamentos utilizam `AppSpacing.*`.

---

## 🏗️ 2. Arquitetura, Repositórios & Desacoplamento de Mocks

- [x] **2.1. Desacoplamento de Mocks Locais nas Telas:**
  - [x] Remover listas estáticas mockadas de dentro das telas (ex: `financial_statement_screen.dart`) e migrar todas as chamadas para o `MockRepository`.
  - [x] Garantir a regra arquitetural: `UI → Controller/Repository → Dados`.
- [x] **2.2. Implementação dos 4 Estados Visuais Obrigatórios em Todas as Telas:**
  - [x] **Loading:** Exibir Shimmer ou indicador de carregamento durante a busca de dados.
  - [x] **Success:** Renderizar a interface populada.
  - [x] **Empty:** Exibir widget `AppEmptyState` personalizado quando a lista/registro estiver vazio (sem veículos, sem faturas, etc.).
  - [x] **Error:** Exibir mensagem clara de falha com botão de "Tentar Novamente" (`Retry`).

---

## 📦 3. Adequação dos Modelos de Dados (Mappers para o Banco em Português)

- [x] **3.1. Sincronização de Enums:**
  - [x] Adequar `VehicleStatus` para refletir os status reais (`available`, `rented`, `maintenance`, `inactive`, `sold`).
  - [x] Adequar `DriverStatus` (`active`, `inactive`, `pendingApproval`, `blocked`).
  - [x] Adequar `ContractStatus`, `InspectionType`, `FinancialType`, `MaintenanceStatus`, etc.
- [x] **3.2. Serialização Híbrida (`fromMap`, `toMap` e `toDatabaseMap`):**
  - [x] Atualizar `Vehicle` (`lib/models/vehicle.dart`) com suporte aos campos do banco (`placa`, `marca`, `modelo`, `km_atual`, etc.).
  - [x] Atualizar `Driver` (`lib/models/driver.dart`) com campos de CNH, endereço e `pontuacao_confianca`.
  - [x] Atualizar `Contract` (`lib/models/contract.dart`) com `valor_locacao` e periodicidade.
  - [x] Atualizar `Inspection` (`lib/models/inspection.dart`) com `odometro_km`, `nivel_combustivel` e fotos 360.
  - [x] Atualizar `FinancialEntry` (`lib/models/financial_entry.dart`) com `valor`, `data_vencimento` e `metodo_pagamento`.
  - [x] Atualizar `ExpenseCategory` (`lib/models/expense_category.dart`) com plano de contas.
  - [x] Atualizar `Workshop` (`lib/models/workshop.dart`) e `MaintenanceEntry` (`lib/models/maintenance_entry.dart`).
  - [x] Atualizar `Manager` (`lib/models/manager.dart`) e `TimelineItem` (`lib/models/timeline_item.dart`).

---

## 📝 4. Preparação de Formulários & Validações de Entrada

- [x] **4.1. Validação de Campos Obrigatórios:**
  - [x] Criada a classe `AppValidators` (`lib/core/utils/validators.dart`) com validadores de CPF, CNPJ, Placa Mercosul/antiga, E-mail, Telefone, Valores Monetários e Números Positivos.
  - [x] Validação e formatação de CPF (`000.000.000-00`) e CNPJ (`00.000.000/0000-00`).
  - [x] Validação de Placa de Veículo (Padrão Mercosul / Antigo).
  - [x] Validação de valores monetários (não permitir negativos ou zero quando inapropriado).
  - [x] Validação de formato de e-mail e força mínima de senha.
- [x] **4.2. Feedback Visual de Envio:**
  - [x] Desabilitar botões de salvar durante o envio para evitar submissões duplicadas.
  - [x] Adicionar indicador de loading no botão enquanto a operação assíncrona executa.
  - [x] Suporte a diálogos e feedback com estilo editorial.

---

## 📷 5. Preparação para Captura e Upload de Mídia (Imagens e Arquivos)

- [x] **5.1. Vistoria 360º (Check-in / Check-out):**
  - [x] Conectar os cards de fotos da vistoria (Frente, Traseira, Lateral Esquerda, Lateral Direita, Painel, Hodômetro, Bancos, Placa) ao `image_picker` para seleção via câmera ou galeria.
  - [x] Exibir miniatura (thumbnail) da foto real selecionada diretamente no card com opção de re-captura antes de finalizar a vistoria.
  - [x] Adicionados inputs para KM do Hodômetro, Nível de Combustível, Checklist e Avarias.
- [x] **5.2. Cadastro de Documentos (CNH, Residência e NFe):**
  - [x] Adicionado suporte a seleção de arquivo/foto para CNH e Comprovante de Residência no auto-cadastro do motorista com preview.
  - [x] Adicionado suporte a anexo de foto da Nota Fiscal no cadastro de manutenção da oficina.

---

## 🧭 6. Roteamento, Parâmetros e Auth Guard (`go_router`)

- [x] **6.1. Passagem Dinâmica de Parâmetros:**
  - [x] Rotas de detalhe estruturadas com parâmetros dinâmicos (`/admin/vehicles/detail/:id`, `/admin/drivers/profile/:id`, `/admin/inspections/:id`, `/driver/inspection/:id`, etc.).
- [x] **6.2. Estrutura de Redirecionamento por Perfil:**
  - [x] Rotas separadas por perfis (`/auth`, `/admin/*`, `/gestor/*`, `/driver/*`) preparadas para transição com autenticação real.
