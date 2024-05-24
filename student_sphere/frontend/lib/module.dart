import 'package:flutter/foundation.dart';

import 'announcement.dart';

class Module {
  final String id;
  final String code;
  final String title;
  final String period;
  final int credits;
  final String level;
  bool published;
  List<Announcement>? announcements;

  Module({
    required this.id,
    required this.code,
    required this.title,
    required this.period,
    required this.credits,
    required this.level,
    required this.published,
    this.announcements = const [],
  });

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
        other.published == published &&
        listEquals(other.announcements, announcements);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        code.hashCode ^
        title.hashCode ^
        period.hashCode ^
        credits.hashCode ^
        level.hashCode ^
        published.hashCode ^
        announcements.hashCode;
  }

  factory Module.fromMap(Map<dynamic, dynamic> map) {
    print('Module Map Data: $map');
    var announcementList = map['announcements'] != null &&
            map['announcements'] is Map<dynamic, dynamic>
        ? (map['announcements'] as Map<dynamic, dynamic>).entries.map((entry) {
            print('Parsing announcement: ${entry.value}');
            return Announcement.fromMap(entry.value as Map<String, dynamic>);
          }).toList()
        : <Announcement>[];

    print('Parsed Announcements: $announcementList');
    return Module(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      period: map['period'] ?? '',
      credits: map['credits'] ?? 0,
      level: map['level'] ?? '',
      published: map['published'] ?? false,
      announcements: announcementList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'period': period,
      'credits': credits,
      'level': level,
      'published': published,
      'announcements':
          announcements!.map((announcement) => announcement.toMap()).toList(),
    };
  }
}
