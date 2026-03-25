# 🚗 Fleet App — Gestão de Frota Premium

> **The Architectural Command:** Transforming complex fleet data into a high-end, authoritative editorial experience.

This project is a sophisticated **Fleet Management System** built with Flutter. It rejects the "generic SaaS" aesthetic in favor of **Architectural Command**—a design philosophy centered on space, tonal layering, and professional control.

---

## 🏛️ Propósito & Filosofia

O projeto foi concebido para ser mais do que uma simples ferramenta de gestão; é um **jornal financeiro premium** para frotas. 

*   **Comando Arquitetônico:** Uso intencional de espaços e camadas tonais para reduzir o ruído visual.
*   **Autoridade Editorial:** Tipografia sofisticada (Manrope & Inter) que comunica confiança e precisão.
*   **Experiência High-End:** Ausência de bordas rígidas, substituídas por transições de cores e glassmorphism.

---

## 🛠️ Funcionalidades Principais

### 👤 Portal do Administrador (Desktop & Tablet)
*   **Dashboard de Comando:** KPIs monumentais de receita, custos e saúde da frota com gráficos `fl_chart`.
*   **Gestão de Ativos:** Controle completo de veículos, motoristas e contratos (Uber/Prefeitura).
*   **Monitoramento Financeiro:** Fluxo de caixa, inadimplência e rentabilidade por veículo.
*   **Controle Operacional:** Agendamento de manutenções e revisão de vistorias detalhadas.

### 📱 Portal do Motorista (Mobile-First)
*   **Check-in/Check-out Digital:** Fluxo guiado em 6 etapas com registro fotográfico e odômetro.
*   **Histórico de Uso:** Acesso rápido a vistorias passadas e comprovantes.
*   **Central de Pagamentos:** Status de parcelas do aluguel e informações de repasse.

---

## 🏗️ Arquitetura & Tech Stack

O desenvolvimento segue regras rigorosas de escalabilidade e limpeza de código:

*   **Framework:** Flutter (Web, Android & iOS).
*   **Navegação:** `go_router` para rotas profundamente vinculadas.
*   **Estado:** `Provider` para gerenciamento reativo.
*   **Padrões:** Repository Pattern, Separation of Concerns e Modelagem Tipada.
*   **UI/UX:** Design System customizado (AppColors, AppTextStyles, AppSpacing).

---

## 🚀 Escopo de Desenvolvimento (Somente Frontend)

Este projeto será desenvolvido seguindo a estratégia **Frontend First**.

1.  **Fase 1 (Atual):** Desenvolvimento de 100% da interface, fluxos e lógica de UI com dados mockados (hardcoded).
2.  **Fase 2 (Futuro):** Migração total para o backend e integração com banco de dados real após a conclusão e validação do frontend.

### Primeiros Passos
1.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```
2.  **Execute o projeto:**
    ```bash
    flutter run
    ```


---

## 🚫 Regras de Desenvolvimento

*   **No-Line Rule:** Proibido o uso de bordas sólidas de 1px para separação de seções.
*   **Surface Hierarchy:** Profundidade alcançada através de camadas de cores, não sombras genéricas.
*   **Zero Hardcode:** Todas as cores e espaçamentos devem vir do Design System.

---
*Desenvolvido com foco em excelência visual e rigor técnico.*

