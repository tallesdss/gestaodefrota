import '../models/manager.dart';

final List<Manager> mockManagers = [
  Manager(
    id: '1',
    name: 'Ricardo Almeida',
    email: 'ricardo@frota.com',
    phone: '(11) 98888-7777',
    status: ManagerStatus.active,
    avatarUrl: 'https://i.pravatar.cc/150?u=1',
    isApproved: true,
  ),
  Manager(
    id: '2',
    name: 'Fernanda Lima',
    email: 'fernanda@frota.com',
    phone: '(11) 97777-6666',
    status: ManagerStatus.active,
    avatarUrl: 'https://i.pravatar.cc/150?u=2',
    isApproved: false,
  ),
  Manager(
    id: '3',
    name: 'Marcos Silva',
    email: 'marcos@frota.com',
    phone: '(11) 96666-5555',
    status: ManagerStatus.inactive,
    avatarUrl: 'https://i.pravatar.cc/150?u=3',
    isApproved: true,
  ),
];
