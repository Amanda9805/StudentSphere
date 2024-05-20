import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import '../auth_service.dart';
import '../degree.dart';
import '../module.dart';
import 'navbarStudent.dart';

class StudentModifyCoursesPage extends StatelessWidget {
  final SphereUser? user;
  const StudentModifyCoursesPage({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentModifyCourses(user: user),
    );
  }
}

class StudentModifyCourses extends StatelessWidget {
  final SphereUser? user;
  const StudentModifyCourses({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: user),
      appBar: AppBar(
        title: Text('Welcome Student, ${user!.fname} ${user!.lname}'),
      ),
      body: Center(
        child: StudentModifyCoursesDashboard(user: user),
      ),
    );
  }
}

class StudentModifyCoursesDashboard extends StatefulWidget {
  final SphereUser? user;
  const StudentModifyCoursesDashboard({Key? key, this.user}) : super(key: key);

  @override
  _StudentModifyCoursesDashboardState createState() =>
      _StudentModifyCoursesDashboardState();
}

class _StudentModifyCoursesDashboardState
    extends State<StudentModifyCoursesDashboard> {
  List<Module> undergraduateModules = [];
  List<Module> postgraduateModules = [];

  @override
  void initState() {
    super.initState();
    //fetchModules();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
