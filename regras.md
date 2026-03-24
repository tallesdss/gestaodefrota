# 🚫 REGRAS DO PROJETO — FLEET APP (VIDEOCODING)

> Objetivo: manter consistência, escalabilidade e evitar retrabalho durante desenvolvimento 100% por videcoding.

---

## 🧠 1. PRINCÍPIO BASE

* Todo código deve ser:

  * Simples
  * Reutilizável
  * Padronizado
  * Escalável

* **Nunca codar "rápido" quebrando padrão.**

* **Somente Frontend:** Este projeto deve ser desenvolvido utilizando **apenas** o frontend com dados fictícios (mocks). Nenhuma integração com backend real ou banco de dados externo deve ser feita. Toda a lógica de persistência deve ser simulada localmente.

---

## 🏗️ 2. ARQUITETURA (OBRIGATÓRIO)

### 2.1 Separação de camadas

NUNCA acessar mock direto da UI.

Sempre usar:

UI → Controller/Provider → Repository → Mock

---

### 2.2 Repository Pattern (mesmo com mock)

Toda feature DEVE ter repository.

Exemplo:

* VehicleRepository
* DriverRepository
* ContractRepository

---

### 2.3 Modelos são obrigatórios

NUNCA usar Map solto.

Sempre criar model tipado:

* fromMap()
* toMap()

---

## 🎨 3. DESIGN SYSTEM (REGRA CRÍTICA)

### 3.1 Proibido hardcode

❌ NÃO usar:

* Color(0xFF...)
* SizedBox(height: 16)
* TextStyle(...)

✅ SEMPRE usar:

* AppColors.*
* AppSpacing.*
* AppTextStyles.*

---

### 3.2 Componentização obrigatória

Se repetiu 2x → vira widget.

Exemplo:

* Card → componente
* Item de lista → componente
* Botão custom → componente

---

### 3.3 Nada de UI gigante

❌ Widgets com mais de 150 linhas são proibidos

Quebrar em:

* sub-widgets
* componentes reutilizáveis

---

## 🔁 4. ESTADO (MUITO IMPORTANTE)

### 4.1 Nunca usar setState para regra de negócio

setState só para UI local simples.

---

### 4.2 Sempre usar Provider/Riverpod

Estado global deve ficar em:

* controllers
* providers

---

### 4.3 Estados obrigatórios

Toda tela deve tratar:

* loading
* success
* empty
* error

---

## 📡 5. PREPARAÇÃO PARA BACKEND

Mesmo sendo mock:

* Simular delay (Future.delayed)
* Simular erro (random)
* Estrutura pronta para API

---

## 🧩 6. COMPONENTES REUTILIZÁVEIS

Criar em `core/widgets/`

Obrigatórios:

* StatCard
* VehicleCard
* StatusBadge
* EmptyState
* LoadingOverlay

---

## 🧭 7. NAVEGAÇÃO

* Usar apenas go_router
* Rotas centralizadas
* Nunca navegar com Navigator.push direto

---

## 🧪 8. PADRÃO DE NOMES

### Arquivos:

snake_case.dart

### Classes:

PascalCase

### Variáveis:

camelCase

---

## 🚀 9. PERFORMANCE

* Usar const sempre que possível
* ListView.builder obrigatório para listas
* Evitar rebuild desnecessário

---

## 📱 10. RESPONSIVIDADE

Sempre testar:

* Mobile
* Tablet
* Desktop

---

## ♿ 11. ACESSIBILIDADE

Obrigatório:

* Semantics em ícones
* Touch mínimo 44x44
* Contraste adequado

---

## 🛑 12. PROIBIÇÕES

❌ Não usar:

* Código duplicado
* Lógica dentro de Widget
* Dados mock direto na UI
* Hardcode de cor/spacing/texto

---

## ✅ 13. CHECKLIST ANTES DE FINALIZAR QUALQUER TELA

* [ ] Usa AppColors?
* [ ] Usa AppTextStyles?
* [ ] Usa AppSpacing?
* [ ] Tem loading?
* [ ] Tem empty state?
* [ ] Tem error state?
* [ ] Está responsivo?
* [ ] Código está limpo?

---

## 🧠 REGRA FINAL

> Se está funcionando mas está feio por dentro → NÃO está pronto.

---
