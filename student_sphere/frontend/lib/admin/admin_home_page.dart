import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';

class AdminHomePage extends StatelessWidget {
  final SphereUser? user;
  const AdminHomePage({Key? key, required this.user}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdminHome(user: user),
    );
  }
}

class AdminHome extends StatelessWidget {
  final SphereUser? user;
  const AdminHome({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Admin, ${user!.fname} ${user!.lname}'),
      ),
      /*body: const Center(
        child: LoginForm(),
      ),*/
    );
  }
}