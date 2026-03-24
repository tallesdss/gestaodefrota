# 🚗 Flutter Frontend — Gestão de Frota
> Apenas frontend | Dados mock hardcoded | Flutter Web + Mobile

---

## 📋 ÍNDICE
1. [Estrutura do Projeto](#1-estrutura-do-projeto)
2. [Modelos de Dados Mock](#2-modelos-de-dados-mock)
3. [Navegação & Rotas](#3-navegação--rotas)
4. [Tema & Design System](#4-tema--design-system)
5. [Portal Admin — Telas](#5-portal-admin--telas)
6. [Portal Motorista — Telas](#6-portal-motorista--telas)
7. [Componentes Reutilizáveis](#7-componentes-reutilizáveis)

---

## 1. Estrutura do Projeto

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   ├── routes/
│   │   └── app_routes.dart
│   └── widgets/                  ← componentes reutilizáveis
│       ├── stat_card.dart
│       ├── vehicle_card.dart
│       ├── driver_card.dart
│       ├── status_badge.dart
│       ├── section_header.dart
│       └── custom_bottom_nav.dart
├── mock/
│   ├── mock_vehicles.dart
│   ├── mock_drivers.dart
│   ├── mock_contracts.dart
│   ├── mock_financials.dart
│   └── mock_inspections.dart
├── models/
│   ├── vehicle.dart
│   ├── driver.dart
│   ├── contract.dart
│   ├── financial_entry.dart
│   └── inspection.dart
├── admin/
│   ├── dashboard/
│   ├── vehicles/
│   ├── drivers/
│   ├── contracts/
│   ├── financial/
│   ├── maintenance/
│   └── inspections/
└── driver_portal/
    ├── home/
    ├── checkin/
    ├── checkout/
    ├── history/
    └── payments/
```

- [x] Criar projeto Flutter (`flutter create frota_app`)
- [x] Adicionar dependências no `pubspec.yaml`:
  - [x] `go_router` — navegação
  - [x] `fl_chart` — gráficos
  - [x] `image_picker` — câmera/galeria (check-in)
  - [x] `intl` — formatação de datas e moeda (R$)
  - [x] `google_fonts` — tipografia
  - [x] `shimmer` — loading skeleton
  - [x] `provider` — gerenciamento de estado
- [x] Criar estrutura de pastas conforme acima.

---

## 2. Modelos de Dados Mock

### 2.1 — `models/vehicle.dart`
- [x] `id`, `plate`, `brand`, `model`, `year`, `color`
- [x] `status` (enum: available / rented / maintenance)
- [x] `currentKm`, `fuelLevel`
- [x] `contractType` (enum: uber / prefecture)
- [x] `imageUrl` (asset local)
- [x] `ipvaExpiry`, `insuranceExpiry`, `licensingExpiry`

### 2.2 — `models/driver.dart`
- [x] `id`, `name`, `cpf`, `phone`, `email`
- [x] `type` (enum: uber / prefecture)
- [x] `status` (enum: active / inactive)
- [x] `cnhNumber`, `cnhExpiry`, `cnhCategory`
- [x] `currentVehicleId` (nullable)
- [x] `avatarUrl` (asset local)

### 2.3 — `models/contract.dart`
- [x] `id`, `vehicleId`, `driverId`
- [x] `type` (uber / prefecture)
- [x] `startDate`, `endDate`
- [x] `weeklyValue` ou `monthlyValue`
- [x] `status` (enum: active / expired / cancelled)
- [x] `depositPaid` (bool)

### 2.4 — `models/financial_entry.dart`
- [x] `id`, `type` (enum: income / expense)
- [x] `category` (aluguel / manutenção / ipva / seguro / multa / outro)
- [x] `vehicleId` (nullable), `driverId` (nullable)
- [x] `amount`, `date`, `description`
- [x] `isPaid` (bool)

### 2.5 — `models/inspection.dart`
- [x] `id`, `vehicleId`, `driverId`
- [x] `type` (enum: checkin / checkout)
- [x] `dateTime`, `kmAtInspection`
- [x] `fuelLevel`
- [x] `photos` (List de asset paths ou URLs fake)
- [x] `notes`, `hasNewDamage` (bool)

### 2.6 — `mock/` — Dados hardcoded
- [x] `mock_vehicles.dart` — lista com veículos variados
- [x] `mock_drivers.dart` — lista com motoristas
- [x] `mock_contracts.dart` — contratos ativos
- [x] `mock_financials.dart` — entradas financeiras
- [x] `mock_inspections.dart` — vistorias com dados completos

---

## 3. Navegação & Rotas

### `core/routes/app_routes.dart` com `go_router`
- [ ] Rota `/login` — tela de seleção (admin ou motorista)
- [ ] Rota `/admin` — shell com sidebar (desktop) ou bottom nav (mobile)
  - [ ] `/admin/dashboard`
  - [ ] `/admin/vehicles` e `/admin/vehicles/:id`
  - [ ] `/admin/drivers` e `/admin/drivers/:id`
  - [ ] `/admin/contracts` e `/admin/contracts/:id`
  - [ ] `/admin/financial`
  - [ ] `/admin/maintenance`
  - [ ] `/admin/inspections`
- [ ] Rota `/driver` — shell com bottom nav (mobile-first)
  - [ ] `/driver/home`
  - [ ] `/driver/checkin` (fluxo em etapas)
  - [ ] `/driver/checkout` (fluxo em etapas)
  - [ ] `/driver/history`
  - [ ] `/driver/payments`
  - [ ] `/driver/profile`

---

## 4. Tema & Design System

### `core/theme/app_colors.dart`
- [x] Cor primária (ex: azul escuro `#1A2B4A`)
- [x] Cor de destaque/acento (ex: laranja `#F5A623`)
- [x] Cores de status: verde (ok), amarelo (atenção), vermelho (alerta)
- [x] Fundo claro e fundo escuro (para dark mode opcional)
- [x] Cor de superfície dos cards

### `core/theme/app_text_styles.dart`
- [x] Display large (títulos de dashboard)
- [x] Heading (títulos de seção)
- [x] Body (texto corrido)
- [x] Label (labels de campo, badges)
- [x] Caption (datas, textos secundários)

### `core/theme/app_theme.dart`
- [x] `ThemeData` configurado com as cores e fontes acima
- [x] Estilo padrão de `Card`, `AppBar`, `Button`, `TextField`

---

## 5. Portal Admin — Telas

### Tela 5.1 — Login / Seleção de Perfil
- [ ] Tela inicial com logo da empresa
- [ ] Dois botões grandes: **"Entrar como Admin"** / **"Entrar como Motorista"**
- [ ] (Mock: clique direto, sem validar senha)

---

### Tela 5.2 — Dashboard Admin

#### Layout
- [ ] `AppBar` com logo, nome do usuário e ícone de notificação
- [ ] Sidebar fixa no desktop / `BottomNavigationBar` no mobile
- [ ] Corpo com `SingleChildScrollView`

#### Seção: Cards de Resumo (topo)
- [ ] Widget `StatCard` reutilizável (ícone + label + valor + cor)
- [ ] Card: **Veículos Disponíveis** (ex: 18)
- [ ] Card: **Veículos Alugados** (ex: 43)
- [ ] Card: **Em Manutenção** (ex: 4)
- [ ] Card: **Receita do Mês** (ex: R$ 48.200)
- [ ] Card: **Custos do Mês** (ex: R$ 12.800)
- [ ] Card: **Lucro Líquido** (ex: R$ 35.400)

#### Seção: Gráfico Receita vs Custos
- [ ] Gráfico de barras agrupadas com `fl_chart`
- [ ] Eixo X: últimos 6 meses
- [ ] Legenda: Receita (verde) / Custos (vermelho)
- [ ] Dados vindos de `mock_financials.dart`

#### Seção: Distribuição da Frota
- [ ] Gráfico de pizza/donut com `fl_chart`
- [ ] Fatias: Disponível / Alugado / Manutenção
- [ ] Legenda com contagem e percentual

#### Seção: Aluguéis Vencendo em 7 Dias
- [ ] Lista horizontal de cards (contrato, motorista, veículo, dias restantes)
- [ ] Badge vermelho se já venceu, amarelo se vence hoje/amanhã

#### Seção: Alertas de Documentos
- [ ] Lista: veículo + tipo do documento + data de vencimento + badge de urgência
- [ ] Dados vindos de `mock_vehicles.dart` (ipvaExpiry, insuranceExpiry)

---

### Tela 5.3 — Lista de Veículos

- [ ] `SearchBar` no topo
- [ ] Filtros em chips: Todos / Disponível / Alugado / Manutenção / Uber / Prefeitura
- [ ] Lista de `VehicleCard`:
  - [ ] Foto do veículo (asset local ou placeholder)
  - [ ] Placa em destaque
  - [ ] Modelo, ano, cor
  - [ ] `StatusBadge` (colorido por status)
  - [ ] Nome do motorista atual (ou "Disponível")
  - [ ] Km atual
  - [ ] Ícone de seta para detalhes
- [ ] FAB (botão flutuante) "+" para adicionar veículo (abre formulário)

---

### Tela 5.4 — Detalhes do Veículo

- [ ] **Header:** foto grande do veículo + placa + modelo + `StatusBadge`
- [ ] **Abas (`TabBar`):**
  - [ ] Aba **Geral:** dados básicos, km, combustível, documentos com datas
  - [ ] Aba **Contrato:** contrato ativo (motorista, valor, datas)
  - [ ] Aba **Financeiro:** receita total gerada vs custos associados ao veículo
  - [ ] Aba **Histórico:** lista de check-ins/check-outs com miniatura das fotos
  - [ ] Aba **Manutenção:** lista de manutenções realizadas

---

### Tela 5.5 — Formulário de Veículo (Adicionar/Editar)

- [ ] Campo: Placa
- [ ] Campo: Marca
- [ ] Campo: Modelo
- [ ] Campo: Ano
- [ ] Campo: Cor
- [ ] Campo: Km atual
- [ ] Campo: Tipo de contrato (Uber / Prefeitura)
- [ ] Campo: Data IPVA
- [ ] Campo: Data Seguro
- [ ] Campo: Data Licenciamento
- [ ] Área de upload de fotos (mock: seleciona da galeria, exibe preview)
- [ ] Botão Salvar (atualiza mock local com `setState` ou `provider`)
- [ ] Botão Cancelar

---

### Tela 5.6 — Lista de Motoristas

- [ ] `SearchBar`
- [ ] Filtros em chips: Todos / Uber / Prefeitura / Ativo / Inativo
- [ ] Lista de `DriverCard`:
  - [ ] Avatar (foto ou inicial do nome)
  - [ ] Nome completo
  - [ ] CPF (mascarado: ***.***)
  - [ ] Tipo (Uber / Prefeitura) com ícone
  - [ ] Status badge
  - [ ] Veículo atual (placa) ou "Sem veículo"
- [ ] FAB "+" para adicionar motorista

---

### Tela 5.7 — Detalhes do Motorista

- [ ] **Header:** avatar + nome + status + tipo
- [ ] **Abas (`TabBar`):**
  - [ ] Aba **Perfil:** dados pessoais, CNH (número, categoria, validade)
  - [ ] Aba **Contrato:** contrato ativo, histórico de contratos
  - [ ] Aba **Pagamentos:** parcelas pagas / pendentes / atrasadas
  - [ ] Aba **Vistorias:** histórico de check-ins e check-outs

---

### Tela 5.8 — Formulário de Motorista (Adicionar/Editar)

- [ ] Upload de foto de perfil (mock: preview local)
- [ ] Campo: Nome completo
- [ ] Campo: CPF
- [ ] Campo: Telefone
- [ ] Campo: E-mail
- [ ] Campo: Tipo (Uber / Prefeitura)
- [ ] Campo: Número CNH
- [ ] Campo: Categoria CNH
- [ ] Campo: Validade CNH
- [ ] Botão Salvar / Cancelar

---

### Tela 5.9 — Lista de Contratos

- [ ] Filtros em chips: Ativos / Vencendo / Encerrados
- [ ] Lista de cards de contrato:
  - [ ] Veículo (placa + modelo)
  - [ ] Motorista (nome)
  - [ ] Tipo (Uber / Prefeitura)
  - [ ] Valor (R$/semana ou R$/mês)
  - [ ] Datas (início → fim)
  - [ ] Status badge + dias restantes
- [ ] FAB "+" para novo contrato

---

### Tela 5.10 — Detalhes do Contrato

- [ ] Dados completos do contrato
- [ ] Seção **Pagamentos:** lista de parcelas com status (pago / pendente / atrasado)
  - [ ] Cada parcela: data vencimento, valor, status badge
  - [ ] Botão "Marcar como pago" (atualiza mock)
- [ ] Botão "Encerrar Contrato" (muda status no mock)

---

### Tela 5.11 — Formulário de Contrato (Novo)

- [ ] Dropdown: Selecionar Veículo (lista apenas disponíveis)
- [ ] Dropdown: Selecionar Motorista (lista apenas ativos sem veículo)
- [ ] Seleção de tipo: Uber / Prefeitura
- [ ] Campo: Valor do aluguel
- [ ] Seleção: Periodicidade (Semanal / Mensal)
- [ ] DatePicker: Data de início
- [ ] DatePicker: Data de término
- [ ] Campo: Valor da caução
- [ ] Switch: Caução paga
- [ ] Campo: Observações
- [ ] Botão Criar Contrato

---

### Tela 5.12 — Financeiro (Visão Geral)

- [ ] Seletor de período (mês/ano) no topo
- [ ] Cards: Total Receitas / Total Custos / Lucro Líquido / Em Atraso
- [ ] Gráfico de linha: evolução do lucro nos últimos 6 meses
- [ ] Gráfico de pizza: composição dos custos por categoria
- [ ] **Abas:**
  - [ ] Aba **Receitas:** lista de pagamentos recebidos
  - [ ] Aba **Despesas:** lista de custos lançados
  - [ ] Aba **Inadimplência:** pagamentos em atraso com dias de atraso

---

### Tela 5.13 — Lançar Receita (Modal/Bottom Sheet)

- [ ] Dropdown: Veículo
- [ ] Dropdown: Motorista
- [ ] Campo: Valor (R$)
- [ ] DatePicker: Data do pagamento
- [ ] Campo: Descrição
- [ ] Switch: Pago
- [ ] Botão Salvar

---

### Tela 5.14 — Lançar Despesa (Modal/Bottom Sheet)

- [ ] Dropdown: Veículo
- [ ] Dropdown: Categoria (Manutenção / IPVA / Seguro / Multa / Combustível / Outro)
- [ ] Campo: Valor (R$)
- [ ] DatePicker: Data
- [ ] Campo: Descrição
- [ ] Botão Salvar

---

### Tela 5.15 — Manutenções

- [ ] Lista de manutenções com cards:
  - [ ] Veículo (placa + modelo)
  - [ ] Tipo de manutenção
  - [ ] Data
  - [ ] Custo
  - [ ] Status (concluída / agendada)
- [ ] FAB "+" para registrar manutenção

---

### Tela 5.16 — Formulário de Manutenção

- [ ] Dropdown: Veículo
- [ ] Dropdown: Tipo (Preventiva / Corretiva / Troca de Óleo / Pneu / Revisão / Outro)
- [ ] DatePicker: Data de entrada na oficina
- [ ] DatePicker: Data de saída
- [ ] Campo: Km no momento
- [ ] Campo: Oficina / Fornecedor
- [ ] Campo: Descrição do serviço
- [ ] Campo: Custo total (R$)
- [ ] DatePicker: Próxima manutenção prevista
- [ ] Botão Salvar

---

### Tela 5.17 — Vistorias (Visão Admin)

- [ ] Lista de todas as vistorias:
  - [ ] Tipo (Check-in / Check-out) com ícone diferente
  - [ ] Veículo + Motorista
  - [ ] Data e hora
  - [ ] Km registrado
  - [ ] Miniatura da primeira foto
- [ ] Toque na vistoria abre detalhes

---

### Tela 5.18 — Detalhes da Vistoria (Admin)

- [ ] Header: tipo, veículo, motorista, data/hora
- [ ] Km registrado + nível de combustível
- [ ] **Galeria de fotos:** grid 2x3 com as 6 fotos
  - [ ] Toque expande a foto em tela cheia
- [ ] Observações do motorista
- [ ] (Se check-out) Comparativo: fotos entrada vs saída lado a lado
- [ ] Campo de observação do admin (editável no mock)
- [ ] Botão "Gerar PDF" (mock: exibe snackbar "PDF gerado!")

---

## 6. Portal Motorista — Telas

> Layout mobile-first. Fundo escuro ou cores contrastantes para uso ao sol.

### Tela 6.1 — Home do Motorista

- [ ] Header com avatar + "Olá, [Nome]!"
- [ ] Card grande: veículo atual (foto, placa, modelo) ou "Nenhum veículo ativo"
- [ ] Card: próximo pagamento (valor + data de vencimento)
- [ ] Botão principal grande:
  - [ ] **"Fazer Check-in"** (se sem veículo)
  - [ ] **"Fazer Check-out"** (se com veículo)
- [ ] Lista de notificações recentes

---

### Tela 6.2 — Check-in (Fluxo em Etapas)

> `PageView` ou `Stepper` com 6 etapas. Barra de progresso no topo.

- [ ] **Etapa 1 — Veículo**
  - [ ] Exibe card do veículo designado (foto, placa, modelo)
  - [ ] Botão "Confirmar, é esse meu veículo"

- [ ] **Etapa 2 — Quilometragem**
  - [ ] Campo numérico grande (teclado numérico)
  - [ ] Label: "Digite o km mostrado no odômetro"
  - [ ] Validação: não pode ser vazio

- [ ] **Etapa 3 — Nível de Combustível**
  - [ ] Ícone visual de tanque com seletor deslizante ou botões
  - [ ] Opções: 1/8, 1/4, 1/2, 3/4, Cheio

- [ ] **Etapa 4 — Fotos Obrigatórias**
  - [ ] Grid de 6 slots de foto com label e ícone de câmera:
    - [ ] 📸 Frente
    - [ ] 📸 Traseira
    - [ ] 📸 Lateral Esquerda
    - [ ] 📸 Lateral Direita
    - [ ] 📸 Painel (com km visível)
    - [ ] 📸 Interior
  - [ ] Toque no slot abre câmera (image_picker)
  - [ ] Slot preenchido exibe miniatura + ícone de check verde
  - [ ] Botão "Próximo" só habilita após todas as 6 fotos

- [ ] **Etapa 5 — Observações**
  - [ ] Campo de texto: "Descreva avarias ou observações"
  - [ ] Checkbox: "Veículo em bom estado, sem avarias visíveis"

- [ ] **Etapa 6 — Confirmação**
  - [ ] Resumo: km, combustível, 6 fotos (thumbnails), observações
  - [ ] Botão grande "Confirmar Check-in"
  - [ ] Tela de sucesso: ícone animado ✓ + "Check-in realizado!" + número da vistoria

---

### Tela 6.3 — Check-out (Fluxo em Etapas)

- [ ] **Etapa 1 — Confirmação**
  - [ ] Card do veículo + data/hora do check-in original
  - [ ] Km registrado no check-in

- [ ] **Etapa 2 — Quilometragem Final**
  - [ ] Campo numérico grande
  - [ ] Exibe: "Km na retirada: X" para referência
  - [ ] Calcula e exibe: "Km rodados: Y" em tempo real
  - [ ] Validação: km final ≥ km inicial

- [ ] **Etapa 3 — Nível de Combustível**
  - [ ] Mesmo seletor da etapa de check-in

- [ ] **Etapa 4 — Fotos de Devolução**
  - [ ] Mesmos 6 slots obrigatórios
  - [ ] Abaixo de cada slot: miniatura da foto do check-in para comparação

- [ ] **Etapa 5 — Observações de Devolução**
  - [ ] Campo de texto: intercorrências, danos novos
  - [ ] Checklist: "Veículo limpo" / "Sem danos novos" / "Documentos no veículo"

- [ ] **Etapa 6 — Confirmação**
  - [ ] Resumo completo (km rodados, tempo total, fotos)
  - [ ] Botão "Confirmar Devolução"
  - [ ] Tela de sucesso animada

---

### Tela 6.4 — Histórico de Vistorias

- [ ] Lista de cards por vistoria:
  - [ ] Ícone: seta verde para baixo (check-in) / seta vermelha para cima (check-out)
  - [ ] Data e hora
  - [ ] Veículo (placa)
  - [ ] Km registrado
  - [ ] Miniatura da primeira foto
- [ ] Toque abre detalhes com todas as fotos e observações

---

### Tela 6.5 — Meus Pagamentos

- [ ] Card destacado: próximo vencimento (valor + data + dias restantes)
- [ ] Lista de parcelas:
  - [ ] Data de vencimento
  - [ ] Valor
  - [ ] Status badge: Pago (verde) / Pendente (amarelo) / Atrasado (vermelho)
- [ ] Seção inferior: informações de pagamento (PIX mock)

---

### Tela 6.6 — Meu Perfil

- [ ] Avatar + nome + tipo (Uber / Prefeitura)
- [ ] Dados: telefone, e-mail (editáveis), CNH, validade CNH
- [ ] Veículo atual vinculado
- [ ] Botão "Sair"

---

## 7. Componentes Reutilizáveis

- [x] `StatCard` — card de KPI (ícone + label + valor + cor de fundo)
- [x] `VehicleCard` — card de veículo para listas
- [ ] `DriverCard` — card de motorista para listas
- [ ] `ContractCard` — card de contrato com status
- [x] `StatusBadge` — chip colorido por status (disponível/alugado/manutenção/pago/atrasado)
- [x] `SectionHeader` — título de seção com linha decorativa
- [ ] `PhotoSlot` — slot de foto com câmera + preview + check (usado no check-in/out)
- [ ] `FuelSelector` — seletor visual de nível de combustível
- [ ] `StepperProgress` — barra de progresso das etapas (check-in/out)
- [ ] `EmptyState` — tela vazia com ícone e mensagem (para listas sem dados)
- [ ] `ConfirmDialog` — diálogo de confirmação reutilizável
- [ ] `LoadingOverlay` — overlay de carregamento (mock de 1s para simular API)

---

## 🗺️ Ordem de Desenvolvimento

```
ETAPA 1 — Base (fazer primeiro)
├── Estrutura de pastas
├── pubspec.yaml com dependências
├── Tema e cores (app_theme.dart)
└── Modelos + dados mock

ETAPA 2 — Admin: Visão Geral
├── Tela de login/seleção
├── Dashboard com cards e gráficos
└── Navegação (sidebar/bottom nav)

ETAPA 3 — Admin: Veículos e Motoristas
├── Lista de veículos + detalhes + formulário
└── Lista de motoristas + detalhes + formulário

ETAPA 4 — Admin: Contratos e Financeiro
├── Lista e detalhes de contratos
├── Formulário de contrato
└── Telas financeiras com gráficos

ETAPA 5 — Admin: Manutenção e Vistorias
├── Lista e formulário de manutenção
└── Lista e detalhes de vistorias (admin)

ETAPA 6 — Portal do Motorista
├── Home + perfil + pagamentos
├── Fluxo de check-in (6 etapas)
└── Fluxo de check-out (6 etapas)

ETAPA 7 — Polimento
├── Animações e transições
├── Estados de loading (shimmer)
├── Tratamento de erros e empty states
└── Responsividade desktop/mobile
```

---

> **Total de telas:** ~30 telas/fluxos  
> **Dados:** 100% mock hardcoded — sem chamada de rede  
> **Próximo passo:** Etapa 1 — criar projeto e estrutura base