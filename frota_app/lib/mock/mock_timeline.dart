import '../models/timeline_item.dart';

List<TimelineItem> mockTimeline = [
  TimelineItem(
    id: 't1',
    title: 'Troca de Óleo Realizada',
    description: 'Veículo: Onix ABC-1234',
    date: DateTime(2026, 03, 25),
    type: 'maintenance',
  ),
  TimelineItem(
    id: 't2',
    title: 'Novo Veículo Vinculado',
    description: 'Chevrolet Onix',
    date: DateTime(2026, 03, 12),
    type: 'vehicle',
  ),
  TimelineItem(
    id: 't3',
    title: 'Pagamento Mensalidade',
    description: 'Referente a Fevereiro - R\$ 2.400,00',
    date: DateTime(2026, 03, 01),
    type: 'financial',
  ),
  TimelineItem(
    id: 't4',
    title: 'Renovação de Seguro',
    description: 'Apólice vigorando até 2026',
    date: DateTime(2026, 02, 15),
    type: 'financial',
  ),
  TimelineItem(
    id: 't5',
    title: 'Vistoria Realizada',
    description: 'Check-in Aprovado - KM 10.500',
    date: DateTime(2026, 02, 01),
    type: 'document',
  ),
  TimelineItem(
    id: 't6',
    title: 'Pagamento Mensalidade',
    description: 'Referente a Janeiro - R\$ 2.400,00',
    date: DateTime(2026, 01, 15),
    type: 'financial',
  ),
  TimelineItem(
    id: 't7',
    title: 'Manutenção Preventiva',
    description: 'Troca de pastilhas de freio',
    date: DateTime(2026, 01, 05),
    type: 'maintenance',
  ),
  TimelineItem(
    id: 't8',
    title: 'Contrato Assinado',
    description: 'Novo contrato de locação Uber',
    date: DateTime(2025, 12, 12),
    type: 'document',
  ),
  TimelineItem(
    id: 't9',
    title: 'Vistoria de Entrada',
    description: 'Veículo entregue em boas condições',
    date: DateTime(2025, 12, 10),
    type: 'document',
  ),
  TimelineItem(
    id: 't10',
    title: 'Aprovação de Perfil',
    description: 'Documentação validada com sucesso',
    date: DateTime(2025, 12, 05),
    type: 'document',
  ),
];
