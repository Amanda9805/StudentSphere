class Module {
  final String id;
  final String code;
  final String title;
  final String period;
  final int credits;
  final String level;
  bool published;

  Module({
    required this.id,
    required this.code,
    required this.title,
    required this.period,
    required this.credits,
    required this.level,
    required this.published,
  });

  // Factory method to create a Module from a map
  factory Module.fromMap(Map<dynamic, dynamic> map) {
    return Module(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      period: map['period'] ?? '',
      credits: map['credits'] ?? 0,
      level: map['level'] ?? '',
      published: map['published'] ?? false,
    );
  }

  // Method to convert a Module to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'period': period,
      'credits': credits,
      'level': level,
      'published': published,
    };
  }
}
