import 'module.dart';

class Degree {
  final String title;
  final String level;
  final List<Module>? modules;

  Degree({required this.title, required this.level, this.modules});

  void addModule(Module module) {
    modules?.add(module);
  }
}