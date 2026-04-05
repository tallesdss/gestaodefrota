import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/expense_category.dart';

List<ExpenseCategory> mockExpenseCategories = [
  ExpenseCategory(
    name: 'Manutenção',
    icon: Icons.build_outlined,
    color: AppColors.error,
    subgroups: [
      ExpenseSubgroup(
        name: 'Motor',
        items: [
          ExpenseSubcategory(name: 'Troca de óleo e filtro de óleo'),
          ExpenseSubcategory(name: 'Troca de correia dentada'),
          ExpenseSubcategory(name: 'Troca de correia do alternador'),
          ExpenseSubcategory(name: 'Troca de bomba d\'água'),
          ExpenseSubcategory(name: 'Troca de bomba de combustível'),
          ExpenseSubcategory(name: 'Troca de velas de ignição'),
          ExpenseSubcategory(name: 'Troca de bobina de ignição'),
          ExpenseSubcategory(name: 'Limpeza de injetores'),
          ExpenseSubcategory(name: 'Troca de filtro de combustível'),
          ExpenseSubcategory(name: 'Troca de filtro de ar'),
          ExpenseSubcategory(name: 'Troca de junta do cabeçote'),
          ExpenseSubcategory(name: 'Regulagem de válvulas'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Suspensão',
        items: [
          ExpenseSubcategory(name: 'Troca de amortecedores'),
          ExpenseSubcategory(name: 'Troca de molas'),
          ExpenseSubcategory(name: 'Troca de pivôs'),
          ExpenseSubcategory(name: 'Troca de bandejas e buchas'),
          ExpenseSubcategory(name: 'Troca de barra estabilizadora'),
          ExpenseSubcategory(name: 'Troca de rolamento de roda'),
          ExpenseSubcategory(name: 'Alinhamento e balanceamento'),
          ExpenseSubcategory(name: 'Troca de terminal de direção'),
          ExpenseSubcategory(name: 'Troca de caixa de direção'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Freios',
        items: [
          ExpenseSubcategory(name: 'Troca de pastilhas de freio'),
          ExpenseSubcategory(name: 'Troca de discos de freio'),
          ExpenseSubcategory(name: 'Troca de lonas e tambores'),
          ExpenseSubcategory(name: 'Troca de fluido de freio'),
          ExpenseSubcategory(name: 'Troca de cilindro mestre'),
          ExpenseSubcategory(name: 'Troca de mangueiras de freio'),
          ExpenseSubcategory(name: 'Regulagem do freio de mão'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Transmissão',
        items: [
          ExpenseSubcategory(name: 'Troca de óleo do câmbio'),
          ExpenseSubcategory(
            name: 'Troca de embreagem (disco, plato e rolamento)',
          ),
          ExpenseSubcategory(name: 'Troca de cabo de embreagem'),
          ExpenseSubcategory(name: 'Troca de junta homocinética'),
          ExpenseSubcategory(name: 'Troca de semi-eixo'),
          ExpenseSubcategory(name: 'Troca de óleo do diferencial'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Arrefecimento',
        items: [
          ExpenseSubcategory(name: 'Troca de fluido de arrefecimento'),
          ExpenseSubcategory(name: 'Troca de radiador'),
          ExpenseSubcategory(name: 'Troca de mangueiras do radiador'),
          ExpenseSubcategory(name: 'Troca de termostato'),
          ExpenseSubcategory(name: 'Troca de ventoinha'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Elétrica',
        items: [
          ExpenseSubcategory(name: 'Troca de bateria'),
          ExpenseSubcategory(name: 'Troca de alternador'),
          ExpenseSubcategory(name: 'Troca de motor de arranque'),
          ExpenseSubcategory(name: 'Troca de fusíveis e relés'),
          ExpenseSubcategory(
            name: 'Troca de lâmpadas (faróis, lanternas, setas)',
          ),
          ExpenseSubcategory(
            name: 'Troca de sensores (rotação, temperatura, ABS)',
          ),
          ExpenseSubcategory(name: 'Reparo de chicote elétrico'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Pneus',
        items: [
          ExpenseSubcategory(name: 'Troca de pneus'),
          ExpenseSubcategory(name: 'Rodízio de pneus'),
          ExpenseSubcategory(name: 'Troca de estepe'),
          ExpenseSubcategory(name: 'Calibragem de pressão'),
          ExpenseSubcategory(name: 'Troca de válvulas'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Ar-condicionado',
        items: [
          ExpenseSubcategory(name: 'Recarga de gás'),
          ExpenseSubcategory(name: 'Troca de filtro de cabine'),
          ExpenseSubcategory(name: 'Troca de compressor'),
          ExpenseSubcategory(name: 'Troca de condensador'),
        ],
      ),
    ],
  ),
  ExpenseCategory(
    name: 'Abastecimento',
    icon: Icons.local_gas_station_outlined,
    color: AppColors.primary,
    subgroups: [
      ExpenseSubgroup(
        name: 'Combustível',
        items: [
          ExpenseSubcategory(name: 'Abastecimento de gasolina'),
          ExpenseSubcategory(name: 'Abastecimento de etanol'),
          ExpenseSubcategory(name: 'Abastecimento de diesel'),
          ExpenseSubcategory(name: 'Abastecimento de GNV'),
          ExpenseSubcategory(name: 'Recarga elétrica'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Lubrificantes e fluidos',
        items: [
          ExpenseSubcategory(name: 'Completar óleo do motor'),
          ExpenseSubcategory(name: 'Completar fluido de freio'),
          ExpenseSubcategory(name: 'Completar fluido de direção hidráulica'),
          ExpenseSubcategory(name: 'Completar aditivo do radiador'),
          ExpenseSubcategory(
            name: 'Completar fluido de limpador de para-brisa',
          ),
        ],
      ),
    ],
  ),
  ExpenseCategory(
    name: 'Limpeza e Estética',
    icon: Icons.auto_awesome_outlined,
    color: Colors.blue,
    subgroups: [
      ExpenseSubgroup(
        name: 'Limpeza',
        items: [
          ExpenseSubcategory(name: 'Lavagem externa'),
          ExpenseSubcategory(name: 'Lavagem interna'),
          ExpenseSubcategory(name: 'Limpeza de estofados'),
          ExpenseSubcategory(name: 'Higienização de ar-condicionado'),
          ExpenseSubcategory(name: 'Limpeza de motor'),
          ExpenseSubcategory(name: 'Polimento de faróis'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Funilaria',
        items: [
          ExpenseSubcategory(name: 'Reparo de amassados'),
          ExpenseSubcategory(name: 'Troca de para-choque dianteiro'),
          ExpenseSubcategory(name: 'Troca de para-choque traseiro'),
          ExpenseSubcategory(name: 'Troca de capô'),
          ExpenseSubcategory(name: 'Troca de porta'),
          ExpenseSubcategory(name: 'Troca de paralama'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Pintura',
        items: [
          ExpenseSubcategory(name: 'Pintura total'),
          ExpenseSubcategory(name: 'Pintura parcial'),
          ExpenseSubcategory(name: 'Polimento'),
          ExpenseSubcategory(name: 'Vitrificação de pintura'),
          ExpenseSubcategory(name: 'Envelopamento'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Vidros',
        items: [
          ExpenseSubcategory(name: 'Troca de para-brisa'),
          ExpenseSubcategory(name: 'Troca de vidro lateral'),
          ExpenseSubcategory(name: 'Troca de vidro traseiro'),
          ExpenseSubcategory(name: 'Reparo de trinca'),
          ExpenseSubcategory(name: 'Troca de borracha de vedação'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Acessórios',
        items: [
          ExpenseSubcategory(name: 'Troca de retrovisores'),
          ExpenseSubcategory(name: 'Troca de maçanetas'),
          ExpenseSubcategory(name: 'Instalação de engate reboque'),
          ExpenseSubcategory(name: 'Troca de tapetes e frisos'),
        ],
      ),
    ],
  ),
  ExpenseCategory(
    name: 'Documentos e IPVA',
    icon: Icons.description_outlined,
    color: const Color(0xFF607D8B),
    subgroups: [
      ExpenseSubgroup(
        name: 'Impostos e taxas',
        items: [
          ExpenseSubcategory(name: 'Pagamento de IPVA'),
          ExpenseSubcategory(name: 'Pagamento de DPVAT / DPEG'),
          ExpenseSubcategory(name: 'Licenciamento anual (CRLV)'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Seguro',
        items: [
          ExpenseSubcategory(name: 'Renovação de seguro compreensivo'),
          ExpenseSubcategory(name: 'Acionamento de seguro'),
          ExpenseSubcategory(name: 'Vistoria de seguro'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Infrações',
        items: [
          ExpenseSubcategory(name: 'Registro de multa'),
          ExpenseSubcategory(name: 'Recurso de multa'),
          ExpenseSubcategory(name: 'Indicação de condutor'),
          ExpenseSubcategory(name: 'Pagamento de multa'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Sinistros',
        items: [
          ExpenseSubcategory(name: 'Registro de boletim de ocorrência'),
          ExpenseSubcategory(name: 'Orçamento de reparo pós-sinistro'),
          ExpenseSubcategory(name: 'Acompanhamento de reparo'),
          ExpenseSubcategory(name: 'Baixa do veículo (furto/perda total)'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Vistoria e transferência',
        items: [
          ExpenseSubcategory(name: 'Vistoria cautelar'),
          ExpenseSubcategory(name: 'Transferência de propriedade'),
          ExpenseSubcategory(name: 'Emplacamento de veículo novo'),
        ],
      ),
    ],
  ),
];
