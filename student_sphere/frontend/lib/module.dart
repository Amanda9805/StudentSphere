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

  // Override the == operator to compare module instances by their properties
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Module &&
        other.id == id &&
        other.code == code &&
        other.title == title &&
        other.period == period &&
        other.credits == credits &&
        other.level == level &&
        other.published == published;
  }

  // Override the hashCode getter to use the properties of the module
  @override
  int get hashCode {
    return id.hashCode ^
        code.hashCode ^
        title.hashCode ^
        period.hashCode ^
        credits.hashCode ^
        level.hashCode ^
        published.hashCode;
  }

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
