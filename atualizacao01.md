# 🚀 Atualização de Desenvolvimento — Gestão de Frota Premium

Este documento mapeia o estado atual do projeto, os componentes que ainda precisam ser desenvolvidos e o mapeamento obrigatório de cada elemento visual (ícone/botão) para sua respectiva funcionalidade ou tela.

---

## 🏗️ 1. Componentes Faltantes (Base System)
Componentes essenciais para garantir a consistência de "No-Line Rule" e "Editorial Design".

- [x] **AppButton (Premium):** Botão com suporte a gradientes, estados de carregamento (loading), ícones e variantes (Primary, Secondary, Outline, Ghost).
- [x] **AppTextField (Smart):** Campo de texto com validação visual premium, suporte a máscaras (CPF, CNPJ, Placa) e variantes (Transparent/Filled).
- [x] **AppModal / AppBottomSheet:** Sistema de diálogos e folhas inferiores com animações suaves e blur de fundo.
- [x] **AppToast / AppNotification:** Sistema de feedback flutuante para sucesso, erro e avisos.
- [x] **AppSkeleton / Shimmer:** Efeito de carregamento para todos os tipos de cards e tabelas.
- [x] **AppEmptyState:** Componente para telas sem dados, com ilustrações customizadas e botão de "Call to Action".
- [x] **AppFilterBar (Reusable):** Barra lateral ou horizontal padronizada para filtragem de listas (Período, Status, etc).
- [x] **AppPagination:** Componente de paginação para tabelas e listas longas.
- [x] **AppBreadcrumbs:** Navegação de caminho para melhorar a orientação do usuário em fluxos profundos.

---

## 🎨 2. Mapeamento de Gatilhos (Ícone/Botão → Função)
**CRÍTICO:** Cada elemento visual abaixo deve possuir uma página ou ação correspondente.

### 🔔 Notificações & Alertas
- [ ] **Ícone de Sino (Header):** Deve abrir a **Página de Notificações Centralizada**.
    - *Requisito:* Filtros por "Urgente", "Manutenção", "Financeiro".
- [ ] **Badge de Manutenção (Header):** Deve redirecionar para a **Lista de Veículos com Filtro de Manutenção Ativo**.

### ⚙️ Configurações & Perfil
- [ ] **Ícone de Engrenagem (Header):** Deve abrir a **Página de Configurações do Sistema**.
    - *Sub-seções:* Preferências de interface, Unidades de medida (Km/L), Configurações de API.
- [ ] **Avatar do Usuário (Header):** Deve abrir o **Portal do Perfil do Gestor**.
    - *Ações:* Editar Foto, Alterar Senha, Logout.

### 📞 Suporte & Ajuda
- [ ] **Botão "Contatar Consultor" (Sidebar):** Deve abrir um **Modal de Suporte Direto** (WhatsApp/Chat/E-mail).
- [ ] **Ícone de Ajuda/Dúvida (Geral):** Deve linkar para a **Base de Conhecimento/FAQ**.

### 🚗 Operacional (Ações Rápidas)
- [ ] **Botão "Adicionar Veículo" (Lista de Veículos):** Deve abrir o **Formulário de Cadastro de Veículo (Stepped Form)**.
- [ ] **Ícone de "Lupa" (Header):** Sistema de **Busca Global** (Modal que sobrepõe a tela com resultados dinâmicos).

---

## 📍 3. Componentes das Barras (Navegação)
Estruturas de navegação por perfil.

- [x] **AppIcon (Wrapper):** Componente para envolver ícones garantindo o tamanho e contraste correto por camada.
- [ ] **AppLogo:** Componente do logo da marca com variantes (Full, Minimal, Light/Dark).
- [ ] **AdminHeader (Refatoração):** Tornar o header 100% reutilizável com suporte a busca global e notificações.
- [ ] **AdminSidebar / ManagerSidebar:** Menu lateral com suporte a sub-menus (drop-downs) e estado colapsável (Compact Mode).
- [ ] **DriverBottomNav:** Barra de navegação inferior exclusiva para o app do motorista (Foco em mobile).
- [ ] **SectionHeader:** Cabeçalho de seção com ações (Botão Adicionar, Exportar) fixo no scroll.

---

## 👤 4. Componentes de Perfil (User Account)
Elementos voltados para representação do usuário e segurança.

- [ ] **ProfileAvatar (Editor):** Avatar circular com overlay de "Editar" e seletor de imagem.
- [ ] **ProfileInfoCard:** Card informativo de alta densidade para exibir detalhes de contratos ou dados pessoais.
- [ ] **DocumentBadge:** Indicador visual do status de documentos (Validado, Pendente, Expirado).
- [ ] **SecurityToggle:** Componentes específicos para troca de senha e autenticação em duas etapas.

---

## 🛠️ 5. Componentes de Administração (Auditoria & Controle)
Ferramentas específicas para o Admin e Gestor.

- [ ] **AuditTimeline:** Linha do tempo visual para histórico de atividades e vistorias.
- [ ] **StatusIndicator:** Pequenos indicadores circulares (dot) com pulsação para status real-time.
- [ ] **MetricBentoGrid:** Layout de grid (estilo Apple/Bento) para métricas do dashboard.
- [ ] **PermissionChip:** Badge interativo para gerenciar permissões de usuários.
- [ ] **VehicleTypeIcon:** Set de ícones customizados para diferentes tipos de veículos.

---

## ✅ 6. Checklist de Telas & Módulos
Status das interfaces que devem ser criadas/refinadas com base nos gatilhos acima.

### 👑 Módulos do Administrador
- [ ] **Dashboard Principal**
    - [ ] **Precisa:** Modal de Busca Global (Trigger: Lupa/Header).
    - [ ] **Precisa:** Skeletons de Carregamento (Shimmer).
- [ ] **Página de Notificações** (Trigger: Sino/Header).
- [ ] **Página de Configurações** (Trigger: Engrenagem/Header).
- [ ] **Gestão de Veículos**
    - [ ] **Precisa:** Carousel de fotos do veículo com zoom.
    - [ ] **Precisa:** Badge de Status em tempo real (Pulsante).
- [ ] **Módulo Financeiro**
    - [x] Exportação de Relatórios (PDF).
    - [ ] **Precisa:** Modal de Detalhes da Transação ao clicar em linha da tabela.
- [ ] **Auditoria de Cadastro**
    - [ ] **Precisa:** Modal de Justificativa para Recusas.

### 🚗 Módulos do Motorista (Foco Mobile)
- [ ] **Check-in / Check-out:** Com interface de câmera customizada.
- [ ] **Portal de Pagamentos:** Gerador de QR Code PIX e upload de comprovante.

---

> [!TIP]
> **Consistência de Autoridade:** Cada clique deve resultar em uma "Resposta de Autoridade" — ou uma nova página editorial ou um modal de camada tonal superior. Nunca deixe um botão sem `onPressed`.
