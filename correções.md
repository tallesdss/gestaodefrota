# 📑 Histórico Oficial de Revisão e Correções Financeiras

Este documento registra detalhadamente todas as auditorias, revisões de fórmulas matemáticas, consistência contábil e correções implementadas em todos os módulos financeiros do sistema **Gestão de Frota**.

---

## 📊 1. Resumo Executivo das Correções

| Módulo / Camada | Item Auditado | Diagnóstico Inicial | Correção Aplicada | Impacto no Negócio |
| :--- | :--- | :--- | :--- | :--- |
| **PostgreSQL (View)** | `vw_kpis_dashboard_master` | Inadimplência contava apenas status `atrasado` manual; faturas vencidas em `pendente` eram ignoradas. | Atualizado para somar `status = 'atrasado'` OU `(status = 'pendente' AND data_vencimento < CURRENT_DATE)`. | Visão real e imediata de risco de crédito e perdas financeiras no dashboard. |
| **PostgreSQL (Trigger)** | `fn_recalcular_totais_motorista` | Saldo devedor do motorista podia divergir em caso de deleção ou cobranças retroativas. | Recálculo dinâmico garantindo agregação de `pendente` + `atrasado` com filtro estrito de `tipo = 'receita'`. | Eliminação de distorções no limite de crédito e extrato do condutor. |
| **PostgreSQL (RPC)** | `fn_criar_contrato_locacao` | Inserção de caução e 1ª parcela de locação em transação atômica. | Validação de valor de caução `> 0` antes de gerar lançamento; integridade referencial com plano de contas. | Prevenção de duplicidade e cobrança indevida de caução zerado. |
| **Painel Financeiro** | `financial_list_screen.dart` | Cards do Bento Grid (Receita, Despesas, Lucro Líquido) exibiam valores estáticos/mockados. | Fórmulas dinâmicas: `totalIncome = SUM(receitas)`, `totalExpense = SUM(despesas)`, `lucroLiquido = totalIncome - totalExpense`, `margem = (lucro / receita) * 100`. | Métricas financeiras em tempo real fiéis aos dados do banco. |
| **Ranking Financeiro** | `financial_list_screen.dart` | Lista "Top Rentabilidade" com dados fictícios. | Agrupamento dinâmico de faturamento por veículo a partir dos lançamentos reais (`take(3)`). | Identificação precisa dos veículos mais rentáveis da operação. |
| **Cobrança / Atrasos** | `delinquency_list_screen.dart` | Cálculo de dias de atraso considerava a fatura mais recente em vez da mais antiga. | Ajustado para buscar a fatura vencida mais antiga (`isBefore`), calculando dias reais de inadimplência, multa contratual de 2% e juros de 1% a.m. pro-rata. | Cobrança justa e cálculo exato de encargos por atraso. |
| **Contratos de Locação** | `contract_form_screen.dart` | Não havia sincronização entre valor semanal e mensal, e salvamento não executava a RPC com caução. | Implementado cálculo bi-direcional automático (`mensal = semanal * 4.33` e `semanal = mensal / 4.33`) e integração com `ContractRepository.createContractWithDeposit`. | Agilidade no preenchimento e consistência no fluxo de caixa. |
| **Relatórios / PDF** | `report_generator.dart` | PDF exportado calculava apenas um saldo consolidado sem discriminar entradas pagas e pendências. | Adicionado painel com 4 quadrantes: *Receita Total*, *Despesa Total*, *Saldo Líquido*, *Total Pago* e *Total Pendente*. | Conformidade contábil e auditoria fiscal completa. |
| **Relatório Consolidado** | `financial_report_screen.dart` | Tela de relatório consolidado com dados estáticos. | Conexão com `FinancialRepository`, cálculo de margem, distribuição real por categorias e proporção de liquidação. | Visão contábil macro para tomada de decisão estratégica. |

---

## 🧮 2. Detalhamento Técnico das Fórmulas Matemáticas

### 2.1. Cálculo de Inadimplência Real (Dashboard Master)
$$\text{Total Inadimplência} = \sum \text{Valor}(\text{Receitas com } (\text{status} = \text{'atrasado'} \lor (\text{status} = \text{'pendente'} \land \text{data\_vencimento} < \text{hoje})))$$

### 2.2. Cálculo de Lucro Líquido e Margem Operacional
$$\text{Lucro Líquido} = \text{Receitas Totais} - \text{Despesas Totais}$$
$$\text{Margem Operacional (\%)} = \left( \frac{\text{Lucro Líquido}}{\text{Receitas Totais}} \right) \times 100$$

### 2.3. Cálculo de Encargos Moratórios (Motoristas em Atraso)
$$\text{Dias em Atraso} = \text{Hoje} - \min(\text{Data Vencimento das Faturas Pendentes})$$
$$\text{Multa (2\%)} = \text{Débito Principal} \times 0{,}02$$
$$\text{Juros de Mora (1\% a.m. pro-rata)} = \text{Débito Principal} \times \left(\frac{0{,}01}{30}\right) \times \text{Dias em Atraso}$$
$$\text{Débito Corrigido} = \text{Débito Principal} + \text{Multa} + \text{Juros}$$

### 2.4. Conversão Semanal $\leftrightarrow$ Mensal de Locação
* Constante padrão de semanas no mês: **$4{,}3333$** (base 52 semanas / 12 meses).
$$\text{Valor Mensal Estimado} = \text{Valor Semanal} \times 4{,}33$$
$$\text{Valor Semanal Estimado} = \frac{\text{Valor Mensal}}{4{,}33}$$

---

## 🏛️ 3. Arquivos Modificados e Validados

1. [docs/supabase_schema.sql](file:///c:/gestaodefrota/docs/supabase_schema.sql)
   - View `vw_kpis_dashboard_master` atualizada com filtro estrito de vencimento.
   - Função `fn_recalcular_totais_motorista` com consistência de tipos.
2. [frota_app/lib/admin/financial/financial_list_screen.dart](file:///c:/gestaodefrota/frota_app/lib/admin/financial/financial_list_screen.dart)
   - Cálculo 100% dinâmico dos KPIs no Bento Grid e ranking de rentabilidade.
3. [frota_app/lib/admin/financial/delinquency_list_screen.dart](file:///c:/gestaodefrota/frota_app/lib/admin/financial/delinquency_list_screen.dart)
   - Cálculo de mora baseado na fatura mais antiga, juros diários e multa.
4. [frota_app/lib/admin/contracts/contract_form_screen.dart](file:///c:/gestaodefrota/frota_app/lib/admin/contracts/contract_form_screen.dart)
   - Sincronização em tempo real de valores semanal/mensal e RPC de caução.
5. [frota_app/lib/admin/control_panel/financial_report_screen.dart](file:///c:/gestaodefrota/frota_app/lib/admin/control_panel/financial_report_screen.dart)
   - Relatório analítico com agregação por categoria contábil e status.
6. [frota_app/lib/core/utils/report_generator.dart](file:///c:/gestaodefrota/frota_app/lib/core/utils/report_generator.dart)
   - Resumo contábil estruturado no PDF (Entradas, Saídas, Pago e Pendente).
7. [frota_app/lib/core/repositories/contract_repository.dart](file:///c:/gestaodefrota/frota_app/lib/core/repositories/contract_repository.dart)
   - Métodos auxiliares `updateContract` e `createContractWithDeposit`.

---

## ✅ 4. Resultado da Validação Estática
* **`flutter analyze`:** **`No issues found!`** (0 erros e 0 alertas em todo o projeto).
* **Supabase SQL Engine:** DDL e Views sincronizadas com sucesso no PostgreSQL 17.

---

## 🛡️ 5. Auditoria e Correção: Autenticação, Cadastro e RBAC

| Módulo / Camada | Item Auditado | Diagnóstico Inicial | Correção Aplicada | Impacto no Negócio |
| :--- | :--- | :--- | :--- | :--- |
| **Supabase Auth / Trigger** | `handle_new_user()` & `public.motoristas` | Erro `23505 duplicate key value violates unique constraint "motoristas_cpf_key"` ao cadastrar novo usuário porque o trigger tentava inserir CPF `'00000000000'` duplicado. | `cpf` e `numero_cnh` agora aceitam `NULL` no momento do registro inicial (preenchidos no Onboarding); trigger atualizado com blocos `EXCEPTION` defensivos. | Cadastro de novos usuários 100% funcional sem travamentos. |
| **Modelagem RBAC** | `public.perfis` & `UserProfile` | Controle de perfil era estritamente baseado no enum `cargo`, sem suporte a flags booleanas de permissão. | Adicionadas colunas booleanas `is_admin`, `is_gestor`, `is_motorista` em `public.perfis` e modelo [user_profile.dart](file:///c:/gestaodefrota/frota_app/lib/models/user_profile.dart). | Arquitetura unificada de identidade com papéis flexíveis por flags. |

