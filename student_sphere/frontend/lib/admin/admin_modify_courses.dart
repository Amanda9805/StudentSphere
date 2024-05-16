import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import 'navbarAdmin.dart';
import 'degree_page.dart';

class AdminModifyPage extends StatelessWidget {
  final SphereUser? user;
  const AdminModifyPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdminModify(user: user),
    );
  }
}

class AdminModify extends StatelessWidget {
  final SphereUser? user;
  const AdminModify({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: user),
      appBar: AppBar(
        title: Text('Modify Degrees and Courses'),
      ),
      body: const Center(
        child: AdminModifyDashboard(),
      ),
    );
  }
}

class AdminModifyDashboard extends StatefulWidget {
  const AdminModifyDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminModifyDashboard> {
  List<String> undergraduateDegrees = [];
  List<String> postgraduateDegrees = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDegreeList('Undergraduate', undergraduateDegrees),
        _buildDegreeList('Postgraduate', postgraduateDegrees),
      ],
    );
  }

  Widget _buildDegreeList(String title, List<String> degrees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<Map<String, String>>(
                    context: context,
                    builder: (BuildContext context) => AddDegreeModal(),
                  );
                  if (result != null) {
                    final level = result['level'];
                    final degreeTitle = result['title'];
                    if (level == 'Undergraduate') {
                      setState(() {
                        undergraduateDegrees.add(degreeTitle!);
                      });
                    } else if (level == 'Postgraduate') {
                      setState(() {
                        postgraduateDegrees.add(degreeTitle!);
                      });
                    }
                  }
                },
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: degrees.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildDegreeCard(context, degrees[index], title, index);
          },
        ),
      ],
    );
  }

  Widget _buildDegreeCard(BuildContext context, String degreeTitle, String level, int index) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      /*child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DegreePage(degree: degree),
            ),
          );
        },*/
        child: Card(
          child: ListTile(
            title: Text(degreeTitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Add your edit logic here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      if (level == 'Undergraduate') {
                        undergraduateDegrees.removeAt(index);
                      } else if (level == 'Postgraduate') {
                        postgraduateDegrees.removeAt(index);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class AddDegreeModal extends StatefulWidget {
  const AddDegreeModal({Key? key}) : super(key: key);

  @override
  _AddDegreeModalState createState() => _AddDegreeModalState();
}

class _AddDegreeModalState extends State<AddDegreeModal> {
  String selectedLevel = 'Undergraduate'; // Initial selected level
  late TextEditingController selectedTitle;

  @override
  void initState() {
    super.initState();
    selectedTitle = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Degree'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: selectedTitle,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: DropdownButton<String>(
                value: selectedLevel,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLevel = newValue;
                    });
                  }
                },
                items: <String>['Undergraduate', 'Postgraduate']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            )
            // Add more fields for modules if needed
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Add logic to save degree to Firebase
            Navigator.of(context).pop({'title': selectedTitle.text, 'level': selectedLevel});
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    selectedTitle.dispose();
    super.dispose();
  }
}
