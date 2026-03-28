class TimelineItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? type; // 'maintenance', 'document', 'vehicle', 'financial'

  TimelineItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.type,
  });
}
