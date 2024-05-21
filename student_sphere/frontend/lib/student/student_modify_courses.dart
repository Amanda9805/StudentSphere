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

class StudentModifyCourses extends StatefulWidget {
  final SphereUser? user;
  const StudentModifyCourses({Key? key, required this.user}) : super(key: key);

  @override
  _StudentModifyCoursesState createState() => _StudentModifyCoursesState();
}

class _StudentModifyCoursesState extends State<StudentModifyCourses> {
  SphereUser? user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  void updateUser(SphereUser newUser) {
    setState(() {
      user = newUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: user),
      appBar: AppBar(
        title: Text('Modify Courses'),
      ),
      body: Center(
        child:
            StudentModifyCoursesDashboard(user: user, updateUser: updateUser),
      ),
    );
  }
}

class StudentModifyCoursesDashboard extends StatefulWidget {
  final SphereUser? user;
  final Function(SphereUser) updateUser; // Callback function
  StudentModifyCoursesDashboard({Key? key, this.user, required this.updateUser})
      : super(key: key);

  @override
  _StudentModifyCoursesDashboardState createState() =>
      _StudentModifyCoursesDashboardState();
}

class _StudentModifyCoursesDashboardState
    extends State<StudentModifyCoursesDashboard> {
  List<Module> undergraduateModules = [];
  List<Module> postgraduateModules = [];
  Set<Module> selectedModules = {}; // Track selected modules

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
        // If the degree is postgraduate, display only published postgraduate modules
        undergraduateModules = [];
        postgraduateModules = categorizedModules['postgraduate']
                ?.where((module) => module.published)
                .toList() ??
            [];
      } else {
        // If the degree is undergraduate or does not contain "Hons", display only published undergraduate modules
        postgraduateModules = [];
        undergraduateModules = categorizedModules['undergraduate']
                ?.where((module) => module.published)
                .toList() ??
            [];
      }
    });
  }

  void toggleModuleSelection(Module module, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedModules.add(module);
      } else {
        selectedModules.remove(module);
      }
    });
  }

  Future<void> saveChanges() async {
    try {
      // Merge selected modules with existing registered modules without duplication
      final updatedModules = Set<Module>.from(widget.user!.registeredModules);
      updatedModules.addAll(selectedModules);

      // Update the user object with the new registered modules
      final updatedUser = widget.user!.copyWith(
        registeredModules: updatedModules.toList(),
      );

      // Update the registered modules in the database
      await AuthService.updateUserModules(
          widget.user!.id, updatedModules.toList());

      // Call the callback function to update the user object in the parent widget
      widget.updateUser(updatedUser);

      _showResultDialog(context, 'Selected modules registered successfully!');
    } catch (error) {
      print('Error saving changes: $error');
      _showResultDialog(context, 'Failed to save changes: $error');
    }
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
          Center(
            child: ElevatedButton(
              onPressed: saveChanges,
              child: Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleList(String title, List<Module> modules) {
    final bool isPostgraduate = widget.user!.degree!.contains("Hons");

    if ((title == 'Postgraduate Courses' && isPostgraduate) ||
        (title == 'Undergraduate Courses' && !isPostgraduate)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Available Courses",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buildModuleCard(context, modules),
                  ],
                ),
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
          label: Text('Register'), // Column for register checkbox
        ),
      ],
      rows: modules.map((module) {
        bool isSelected = selectedModules.contains(module);

        return DataRow(cells: [
          DataCell(Text(module.code)),
          DataCell(Text(module.title)),
          DataCell(Text(module.credits.toString())),
          DataCell(Text(module.period)),
          DataCell(
            Row(
              children: [
                // Render a Checkbox
                Tooltip(
                  message: 'Register',
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      toggleModuleSelection(module, value!);
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
