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
    fetchModules();
  }

  Future<void> fetchModules() async {
    final Map<String, List<Module>> categorizedModules =
        await AuthService.fetchModules();

    final bool isPostgraduate = widget.user!.degree!
        .contains("Hons"); // Check if degree contains "Hons"

    setState(() {
      if (isPostgraduate) {
        // If the degree is postgraduate, display postgraduate modules
        undergraduateModules = [];
        postgraduateModules = categorizedModules['postgraduate'] ?? [];
      } else {
        // If the degree is undergraduate or does not contain "Hons", display undergraduate modules
        postgraduateModules = [];
        undergraduateModules = categorizedModules['undergraduate'] ?? [];
      }
    });
  }

  void _showResultDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Result'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleList('Undergraduate Courses', undergraduateModules),
          _buildModuleList('Postgraduate Courses', postgraduateModules),
        ],
      ),
    );
  }

  Widget _buildModuleList(String title, List<Module> modules) {
    final bool isPostgraduate = widget.user!.degree!.contains("Hons");

    if ((title == 'Postgraduate Courses' && isPostgraduate) ||
        (title == 'Undergraduate Courses' && !isPostgraduate)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  buildModuleCard(context, modules),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // Return an empty container if the condition is not met
      return Container();
    }
  }

  Widget buildModuleCard(BuildContext context, List<Module> modules) {
    return DataTable(
      columns: [
        DataColumn(label: Text('Module Code')),
        DataColumn(label: Text('Module Title')),
        DataColumn(label: Text('Credits')),
        DataColumn(label: Text('Period')),
        DataColumn(
          label: Text('Register'), // Column for Edit and Delete buttons
        ),
      ],
      rows: modules.map((module) {
        bool isSelected = false; // Add a boolean to track selection

        return DataRow(cells: [
          DataCell(Text(module.code)),
          DataCell(Text(module.title)),
          DataCell(Text(module.credits.toString())),
          DataCell(Text(module.period)),
          DataCell(
            Row(
              children: [
                // Render a Checkbox instead of IconButton
                Tooltip(
                  message: 'Register',
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        isSelected = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ]);
      }).toList(),
    );
  }
}
