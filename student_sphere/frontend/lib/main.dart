// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:student_sphere/register.dart';
import 'admin_home_page.dart';
import 'student_home_page.dart';
import 'user_role.dart';
import 'user.dart';
import 'auth_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: const Center(
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 30,
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
        ),
        SizedBox(
          width: 250,
          height: 30,
          child: TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () async {
              // Perform login logic here
              SphereUser? user = await AuthService.loginUser(emailController.text, passwordController.text);
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    // Navigate to appropriate screen based on user role
                    return user.role == UserRole.student
                        ? StudentHomePage(user: user)
                        : AdminHomePage(user: user);
                  }),
                );
              } else {
                // Handle invalid login
              }
            },
            child: Text('Login'),

          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegistrationPage()),
              );
            },
            child: Text('Register'),
          ),
        )
      ],
    );
  }
}
