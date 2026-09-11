# Documentação Oficial e Passo a Passo Completo do Sistema: 100% Supabase

> **Diretiva Absoluta: Zero Mockups.** Todos os dados do sistema vêm única e exclusivamente do banco de dados relacional Supabase (`rwksrejrmjqnuspqnokp.supabase.co`). Todas as listas estáticas legadas em memória foram totalmente removidas.

---

## 1. Veículo Atribuído ao Motorista: BYD MINI (Placa: BVT2356)

### O que ocorreu anteriormente?
Antes da abertura das permissões de acesso do Supabase (RLS), as consultas feitas no modo anônimo falhavam e o código legado recorria a uma lista estática de fallback que continha o nome genérico *"BYD Dolphin Plus EV"*.

### Como está configurado agora?
1. **Remoção de todo e qualquer fallback fictício:** Repositórios e telas agora consultam apenas o banco de dados.
2. **Dados Reais Carregados Diretamente do Supabase:**
   - **Tabela:** `veiculos` (ID: `885b06b4-40dd-46a6-bd2f-77f251566a10`)
   - **Marca:** `BYD`
   - **Modelo:** `MINI`
   - **Placa:** `BVT2356`
   - **Quilometragem Registrada:** `195.000 KM`
   - **Status:** `alugado`
   - **Contrato Ativo:** `CTR-1787373825673` vinculado ao motorista `Carlos Silva Motorista` (`dfc34aba-9a10-4da0-a38f-91b47438bde0`).

---

## 2. Passo a Passo do Fluxo do Administrador

### Passo 1: Cadastro e Gestão de Veículos
- **Tabela no Supabase:** `veiculos`
- O administrador cadastra o veículo com placa, chassi, renavam, marca, modelo, ano e quilometragem inicial.
- O carro da frota ativo no banco é o **BYD MINI (BVT2356)**.

### Passo 2: Cadastro de Motoristas
- **Tabelas no Supabase:** `perfis` e `motoristas`
- O gestor registra o motorista com seus documentos (CNH, CPF, e-mail, telefone).
- O motorista ativo registrado no banco é **Carlos Silva Motorista** (`motorista@gestaodefrota.com`).

### Passo 3: Criação de Contrato e Atribuição do Carro
- **Tabela no Supabase:** `contratos`
- O administrador cria um novo contrato selecionando o motorista e o veículo disponível.
- **Parâmetros definidos pelo administrador:**
  - **Frequência de cobrança:** Semanal ou Mensal.
  - **Valor da locação:** Valor atribuído ao período.
  - **Prazo do contrato:** Número de semanas ou meses.
  - **Dia de vencimento:** Dia da semana ou dia do mês.
- Ao salvar, o status do contrato passa para `ativo` e o status do veículo para `alugado`.

### Passo 4: Geração Automática das Faturas / Parcelas
- **Tabela no Supabase:** `lancamentos_financeiros`
- O sistema gera no banco as parcelas de pagamento de acordo com o prazo do contrato:
  - Frequência semanal: Parcelas a cada 7 dias a partir da data de início.
  - Cada registro possui: `descricao` (ex: "Aluguel Semanal - Parcela 1/4"), `valor`, `data_vencimento`, `status: 'pendente'`.

### Passo 5: Cadastro da Chave PIX da Frota
- **Telas:** `profile_screen.dart` (Perfil) e `settings_screen.dart` (Configurações).
- O administrador abre o diálogo de configuração e insere:
  - **Tipo:** CNPJ, CPF, E-mail, Celular ou Chave Aleatória.
  - **Chave:** A chave bancária da empresa.
  - **Beneficiário / Razão Social:** Nome da empresa ou titular.
  - **Cidade:** Cidade da agência bancária.
- O sistema gera a pré-visualização do QR Code em tempo real e armazena as configurações.

---

## 3. Passo a Passo do Fluxo do Motorista

### Passo 1: Acesso ao Portal do Motorista
- O motorista acessa a tela inicial (`driver_home_screen.dart`).
- O sistema carrega do Supabase:
  - Dados do motorista (`Carlos Silva Motorista`).
  - O contrato ativo (`CTR-1787373825673`).
  - O veículo real em posse: **BYD MINI** com **PLACA: BVT2356** e hodômetro **195.000 KM**.

### Passo 2: Acompanhamento de Vencimentos e Alertas
- O sistema busca em tempo real as faturas do motorista na tabela `lancamentos_financeiros`.
- **Lógica de Alertas:**
  - Se a data atual for maior que a data de vencimento da parcela e ela não estiver paga: exibe o banner vermelho **"ALUGUEL EM ATRASO!"**, informando os dias de atraso e o valor pendente.
  - Se todas as faturas estiverem no prazo ou quitadas: exibe o banner verde **"100% EM DIA"**.

### Passo 3: Pagamento Individual ou Quitação Total
- O motorista tem dois botões de ação:
  - **"PAGAR PARCELA" / "PAGAR PARCELA ATRASADA":** Abre o checkout para a parcela mais antiga em aberto.
  - **"QUITAR TUDO DE UMA VEZ":** Soma o total de todas as parcelas pendentes do contrato e abre o checkout consolidado.

### Passo 4: Escaneamento e Pagamento via PIX (BACEN BRCode)
- A tela de checkout (`pix_checkout_screen.dart`) renderiza o **QR Code PIX Oficial** gerado a partir da chave cadastrada pelo administrador.
- O motorista pode:
  - Escanear o QR Code diretamente pelo aplicativo do banco.
  - Clicar em **"COPIAR CÓDIGO PIX"** (Pix Copia e Cola com cálculo de CRC16).
  - Clicar em **"Copiar Chave"** para realizar transferência manual.

### Passo 5: Anexo de Comprovante e Baixa para PAGO
- Após pagar no banco, o motorista clica em **"Anexar Comprovante de Pagamento"**.
- Seleciona o comprovante (foto ou PDF).
- **Processamento automático:**
  1. O arquivo é enviado diretamente ao bucket do Supabase Storage (`comprovantes-pagamento`).
  2. O lançamento no banco de dados (`lancamentos_financeiros`) é atualizado para `status = 'pago'`, com `data_pagamento = now()` e o link público do comprovante salvo.
  3. O ouvinte reativo `entriesChangedNotifier` notifica a interface, que atualiza a tela na hora com o selo verde **PAGO**.

---

## 4. Passo a Passo do Módulo de Vistorias

- **Tabelas no Supabase:** `vistorias`, `fotos_vistoria`, `itens_checklist_vistoria`.
- O motorista ou vistoriador realiza a vistoria pelo app (`inspection_checkin_screen.dart`).
- As fotos capturadas (frente, traseira, laterais, painel, placa) sobem para o Supabase Storage `fotos-vistorias`.
- Os itens de checklist (pneus, combustível, avarias) são registrados vinculados ao ID do contrato e ao ID do veículo (**BYD MINI**).

---

## 5. Arquitetura das Tabelas do Supabase

| Tabela | Função | Principais Colunas |
| :--- | :--- | :--- |
| `perfis` | Dados de autenticação e papel | `id`, `nome`, `email`, `cargo`, `is_admin`, `is_motorista` |
| `motoristas` | Dados cadastrais do motorista | `id`, `cpf`, `numero_cnh`, `status`, `saldo_devedor` |
| `veiculos` | Cadastro de frota | `id`, `placa`, `marca`, `modelo`, `km_atual`, `status` |
| `contratos` | Locações ativas e histórico | `id`, `numero_contrato`, `motorista_id`, `veiculo_id`, `valor_locacao`, `frequencia_cobranca`, `status` |
| `lancamentos_financeiros` | Contas a pagar e receber | `id`, `contrato_id`, `motorista_id`, `veiculo_id`, `valor`, `data_vencimento`, `status`, `comprovante_url` |
| `vistorias` | Check-ins e check-outs | `id`, `contrato_id`, `veiculo_id`, `tipo`, `odometro_km`, `status` |
| `fotos_vistoria` | Fotos anexadas às vistorias | `id`, `vistoria_id`, `tipo_foto`, `url_foto`, `tem_avaria` |
| `itens_checklist_vistoria` | Itens avaliados | `id`, `vistoria_id`, `item_nome`, `conforme` |
