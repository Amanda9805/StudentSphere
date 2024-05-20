class Module {
  final String id;
  final String code;
  final String title;
  final String period;
  final int credits;
  final String level;
  bool published;

  Module(
      {required this.id,
      required this.code,
      required this.title,
      required this.period,
      required this.credits,
      required this.level,
      required this.published});
}
