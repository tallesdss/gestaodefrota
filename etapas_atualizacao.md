# 🗺️ Roteiro de Implementação de Atualização

Este documento detalha a divisão em etapas da atualização proposta no arquivo `atualizacao01.md`, seguindo rigorosamente o `designsystem.md`.

---

## 🏗️ Etapa 1: Base UI System (Foundation)
Foco em componentes essenciais de interação e entrada, garantindo a estética premium e autoritária.

- [x] **AppButton (Premium):** Botão com suporte a gradientes (135° primary to primary_container), estados de loading, ícones e variantes (Primary, Secondary, Outline, Ghost).
- [x] **AppTextField (Smart):** Campo de texto com background `surface_container_low`, validadores visuais, suporte a máscaras e "Ghost Border" no foco.
- [x] **AppIcon (Wrapper):** Wrapper customizado para `LucideIcons` ou `MaterialIcons` com controle de contraste e tamanho por camada tonal.

## 🎨 Etapa 2: Feedback & Overlays
Sistemas de diálogo e notificações que usam profundidade e blur.

- [x] **AppModal / AppBottomSheet:** Transições suaves, fundo com blur e cantos arredondados (radius md/lg).
- [x] **AppToast / AppNotification:** Feedback flutuante com elevação sutil (Ambient Shadows).
- [x] **AppSkeleton / Shimmer:** Carregamento elegante para cards e tabelas.

## 📍 Etapa 3: Navigation & Control
Componentes que estruturam o fluxo de informações e dados.

- [x] **AppPagination:** Controle de páginas para dados extensos.
- [x] **AppBreadcrumbs:** Navegação hierárquica clara.
- [x] **AppFilterBar:** Sistema de filtros reutilizável (Drawer ou Section).
- [x] **AppEmptyState:** Feedback para listas vazias com CTAs.

## 🧩 Etapa 4: Identidade & Detalhes
Simbologia e componentes de representação da marca e status.

- [ ] **AppLogo:** Variante full e minimalista conforme o tema.
- [ ] **StatusIndicator:** Dots pulsantes para real-time status.
- [ ] **VehicleTypeIcon:** Set de ícones customizados por categoria de veículo.

## 👤 Etapa 5: Perfil & Administração
Componentes de nicho para gestão de usuários e auditoria.

- [ ] **ProfileAvatar (Editor):** Avatar com seletor de mídia integrado.
- [ ] **ProfileInfoCard / DocumentBadge:** Exibição de dados de alta densidade.
- [ ] **AuditTimeline:** Histórico visual de eventos.
- [ ] **MetricBentoGrid:** Layout assimétrico para KPIs.

## ✅ Etapa 6: Refino de Telas (Compliance)
Aplicação dos novos componentes e correção de gaps nas telas existentes.

- [ ] Refatorar Dashboard (Skeletons/Responsividade).
- [ ] Refatorar Gestão de Veículos (Carousel/Status real-time).
- [ ] Refatorar Módulo Financeiro (Filtros Avançados/Paginação).
- [ ] Implementar Portal do Motorista (Check-in/Pagamentos).

---

> [!IMPORTANT]
> **Prioridade Máxima:** Seguir a "No-Line Rule" e utilizar camadas tonais para separação de seções.
