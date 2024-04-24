import 'user_role.dart';

class SphereUser {
  final String fname;
  final String lname;
  final String username;
  final String email;
  final UserRole role;

  SphereUser({required this.fname, required this.lname, required this.email, required this.username, required this.role});

  String getFname() {
    return fname;
  }
}