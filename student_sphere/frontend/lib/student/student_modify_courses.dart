import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import '../auth_service.dart';
import '../degree.dart';
import '../module.dart';
import 'navbarStudent.dart';

class StudentModifyCoursesPage extends StatelessWidget {
  final SphereUser? user;
  final Function(SphereUser) updateUser;

  const StudentModifyCoursesPage(
      {Key? key, required this.user, required this.updateUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentModifyCourses(user: user, updateUser: updateUser),
    );
  }
}

class StudentModifyCourses extends StatefulWidget {
  final SphereUser? user;
  final Function(SphereUser) updateUser;

  const StudentModifyCourses(
      {Key? key, required this.user, required this.updateUser})
      : super(key: key);

  @override
  _StudentModifyCoursesState createState() => _StudentModifyCoursesState();
}

class _StudentModifyCoursesState extends State<StudentModifyCourses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: widget.user, updateUser: widget.updateUser),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Set the desired height
        child: AppBar(
          title: Text(
            'Modify Courses', 
            style: TextStyle(color: Colors.white)
            ),
          backgroundColor: Color(0xFF01324D),
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20), // Adjust the value as needed
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: Center(
        child: StudentModifyCoursesDashboard(
            user: widget.user, updateUser: widget.updateUser),
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
  List<Module> selectedModules = [];

  @override
  void initState() {
    super.initState();
    fetchModules();
  }

  Future<void> fetchModules() async {
    final Map<String, List<Module>> categorizedModules =
        await AuthService.fetchModules();
    final bool isPostgraduate = widget.user!.degree!.contains("Hons");

    setState(() {
      if (isPostgraduate) {
        undergraduateModules = [];
        postgraduateModules = categorizedModules['postgraduate']
                ?.where((module) => module.published)
                .toList() ??
            [];
      } else {
        postgraduateModules = [];
        undergraduateModules = categorizedModules['undergraduate']
                ?.where((module) => module.published)
                .toList() ??
            [];
      }
    });
  }

  void toggleModuleSelection(Module module) {
    setState(() {
      if (selectedModules.contains(module)) {
        selectedModules.remove(module);
      } else {
        // Check if the module is not already registered
        bool isModuleRegistered = widget.user!.registeredModules
            .any((registeredModule) => registeredModule.id == module.id);
        if (!isModuleRegistered) {
          selectedModules.add(module);
        } else {
          // Show a dialog indicating that the module is already registered
          _showResultDialog(
              context, 'Module ${module.code} is already registered.');
        }
      }
    });
  }

  int calculateTotalCredits() {
    return selectedModules.fold(0, (total, module) => total + module.credits);
  } 
  
  void saveChanges() async {
    try {
      // Fetch the existing registered modules
      final List<Module>? registeredModules =
          await AuthService.fetchUserModules(widget.user!.id);
      if (registeredModules == null) {
        throw Exception("Failed to fetch registered modules.");
      }

      // Combine the existing registered modules with the selected modules
      final List<Module> updatedModules = [
        ...registeredModules,
        ...selectedModules
      ];

      // Convert the combined modules to Map<String, dynamic> for database update
      final List<Map<String, dynamic>> updatedModulesData =
          updatedModules.map((module) => module.toMap()).toList();

      // Update the user's registeredModules in the database
      await AuthService.updateUserModules(widget.user!.id, updatedModulesData);

      // Show a dialog to indicate that changes are saved
      _showResultDialog(context, 'Changes saved successfully.');

      // Clear selected modules
      setState(() {
        selectedModules.clear();
      });
    } catch (error) {
      print("Error saving changes: $error");
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
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Total Credits Selected:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    calculateTotalCredits().toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: saveChanges,
              child: Text(
                'Save Changes',
                style: TextStyle(color: Color(0xFF01324D))
              ),
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
        DataColumn(label: Text('Register')),
      ],
      rows: modules.map((module) {
        return DataRow(cells: [
          DataCell(Text(module.code)),
          DataCell(Text(module.title)),
          DataCell(Text(module.credits.toString())),
          DataCell(Text(module.period)),
          DataCell(
            Checkbox(
              value: selectedModules.contains(module),
              onChanged: (bool? value) {
                toggleModuleSelection(module);
              },
            ),
          ),
        ]);
      }).toList(),
    );
  }
}
