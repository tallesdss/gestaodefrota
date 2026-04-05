import '../models/inspection.dart';

List<Inspection> mockInspections = [
  Inspection(
    id: 'insp_001',
    vehicleId: '1',
    driverId: 'd1',
    type: InspectionType.checkin,
    status: InspectionStatus.approved,
    dateTime: DateTime(2026, 03, 30, 08, 30),
    kmAtInspection: 12450,
    fuelLevel: 0.85,
    photos: [
      InspectionPhoto(
        url:
            'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=800',
        title: 'Frente do veículo',
      ),
      InspectionPhoto(
        url:
            'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=800',
        title: 'Traseira',
      ),
      InspectionPhoto(
        url:
            'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=800',
        title: 'Painel ligado (KM visível)',
      ),
      InspectionPhoto(
        url:
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=800',
        title: 'Pneus',
      ),
    ],
    checklist: [
      ChecklistItem(
        title: 'Luzes externas (faróis/lanternas)',
        isChecked: true,
      ),
      ChecklistItem(title: 'Nível de óleo e fluídos', isChecked: true),
      ChecklistItem(title: 'Estado dos pneus e estepe', isChecked: true),
      ChecklistItem(title: 'Higiene e conservação interna', isChecked: true),
    ],
    notes: 'Veículo em perfeitas condições. Pronto para uso.',
    hasNewDamage: false,
  ),
  Inspection(
    id: 'insp_002',
    vehicleId: '2',
    driverId: 'd1',
    type: InspectionType.checkout,
    status: InspectionStatus.pending,
    dateTime: DateTime(2026, 03, 29, 18, 15),
    kmAtInspection: 12550,
    fuelLevel: 0.25,
    photos: [
      InspectionPhoto(
        url:
            'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?q=80&w=800',
        title: 'Frente do veículo',
      ),
      InspectionPhoto(
        url:
            'https://images.unsplash.com/photo-1583121274602-3e2820c69888?q=80&w=800',
        title: 'Painel ligado (KM visível)',
      ),
    ],
    checklist: [
      ChecklistItem(
        title: 'Luzes externas (faróis/lanternas)',
        isChecked: true,
      ),
      ChecklistItem(title: 'Nível de óleo e fluídos', isChecked: true),
      ChecklistItem(title: 'Estado dos pneus e estepe', isChecked: true),
      ChecklistItem(title: 'Higiene e conservação interna', isChecked: true),
    ],
    notes: 'Devolução realizada dentro do horário.',
    hasNewDamage: false,
  ),
  Inspection(
    id: 'insp_003',
    vehicleId: '3',
    driverId: 'd1',
    type: InspectionType.checkin,
    status: InspectionStatus.rejected,
    dateTime: DateTime(2026, 03, 28, 09, 00),
    kmAtInspection: 12650,
    fuelLevel: 1.0,
    photos: [
      InspectionPhoto(
        url:
            'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?q=80&w=800',
        title: 'Frente do veículo',
      ),
    ],
    checklist: [
      ChecklistItem(
        title: 'Luzes externas (faróis/lanternas)',
        isChecked: false,
      ),
      ChecklistItem(title: 'Higiene e conservação interna', isChecked: false),
    ],
    notes:
        'O veículo apresenta sujeira interna excessiva e o farol esquerdo está queimado.',
    hasNewDamage: true,
    reviewReason:
        'Reprovado devido a problemas de conservação e segurança detectados.',
  ),
  // Adicionando mais para cobrir a lista do histórico
  Inspection(
    id: 'insp_004',
    vehicleId: '1',
    driverId: 'd1',
    type: InspectionType.checkout,
    status: InspectionStatus.approved,
    dateTime: DateTime(2026, 03, 27, 20, 00),
    kmAtInspection: 12750,
    fuelLevel: 0.5,
    photos: [],
    checklist: [],
    notes: 'Tudo ok.',
    hasNewDamage: false,
  ),
];
