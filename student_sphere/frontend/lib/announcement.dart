class Announcement {
  final String title;
  final String description;
  final DateTime date;

  Announcement({
    required this.title,
    required this.description,
    required this.date,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) {
    print('Announcement Map Data: $map');
    return Announcement(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
