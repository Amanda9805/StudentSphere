import 'package:flutter/material.dart';

import '../degree.dart';

class DegreePage extends StatelessWidget {
  final Degree degree;
  const DegreePage({Key? key, required this.degree}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DegreeData(degree: degree),
    );
  }
}

class DegreeData extends StatelessWidget {
  final Degree degree;
  const DegreeData({Key? key, required this.degree}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: ManageDegree()
    );
  }
}
