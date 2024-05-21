import 'module.dart';
import 'user_role.dart';

class SphereUser {
  final String id;
  final String fname;
  final String lname;
  final String username;
  final String email;
  final UserRole role;
  final String? degree;
  List<Module> registeredModules;

  SphereUser(
      {required this.id,
      required this.fname,
      required this.lname,
      required this.email,
      required this.username,
      required this.role,
      this.degree,
      this.registeredModules = const []});

  String getFname() {
    return fname;
  }

  SphereUser copyWith({
    String? id,
    String? fname,
    String? lname,
    String? username,
    String? email,
    UserRole? role,
    String? degree,
    List<Module>? registeredModules,
  }) {
    return SphereUser(
      id: id ?? this.id,
      fname: fname ?? this.fname,
      lname: lname ?? this.lname,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      degree: degree ?? this.degree,
      registeredModules: registeredModules ?? this.registeredModules,
    );
  }

  @override
  String toString() {
    return 'SphereUser(id: $id, fname: $fname, lname: $lname, username: $username, email: $email, role: $role, degree: $degree, registeredModules: $registeredModules)';
  }
}
