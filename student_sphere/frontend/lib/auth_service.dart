import 'package:student_sphere/user_role.dart';
import 'package:firebase_database/firebase_database.dart'; 
import 'degree.dart';
import 'user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  
  static void initializeFirebase() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
  }
  
  static UserRole getRole(String role){
    if(role == "UserRole.student"){
      return UserRole.student;
    }
    else if(role == "UserRole.administrator"){
      return UserRole.administrator;
    }
    else{
      return UserRole.unknown;
    }
  }

  static Future<SphereUser?> registerUser(String fname, String lname, String email, String password,String username, UserRole role) async {
     try {
      // Initialize Firebase if not already initialized.
      initializeFirebase();

      // Register the user with Firebase Authentication.
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user's unique ID (UID)
      String userId = userCredential.user!.uid;

      DatabaseReference ref = FirebaseDatabase.instance.ref('users/$userId');

      // Create a map representing the user data
      await ref.set({
        'firstName': fname,
        'lastName': lname,
        'email': email,
        'username': username,
        'role': role.toString()
      });

      print('User data saved successfully.');

      SphereUser user = SphereUser(fname: fname, lname: lname, username: username, email: email, role: role);//id: userCredential.user?.uid, email: userCredential.user?.email);

      // Return the registered user.
      return user;
    } catch (error) {
      // Handle registration errors here.
      print("Registration failed: $error");
      return null; // Return null if registration fails.
    }
  }
  
  static Future<SphereUser?> loginUser(String email, String password) async {
    try {
      // Initialize Firebase if not already initialized.
      initializeFirebase();

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      SphereUser? user;

      String userId = userCredential.user!.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('users/$userId').get();

      if (snapshot.exists) {
          final userData = snapshot.value as Map<dynamic, dynamic>;

          final String fname = userData['firstName'];
          final String lname = userData['lastName'];
          final String username = userData['username'];
          final String email = userData['email'];
          final UserRole role = getRole(userData['role']);

          user = SphereUser(fname: fname, lname: lname, email: email, username: username, role: role);

      } else {
          print('No data available.');
      }

      return user;
    } catch (error) {
      // Handle login errors here.
      print("Login failed: $error");
      if (error is FirebaseException) {
        // Handle Firebase exceptions separately
        // Example: if (error.code == 'user-not-found') { ... }
      }
      return null;
    }
  }

  // Add more methods as needed
  //get degrees
  static Future<List> fetchDegrees() async {
    try {
      final database = FirebaseDatabase.instance;
      final ref = database.ref();
      
      final undergraduateSnapshot = await ref.child('degrees/undergraduate').get();
      final postgraduateSnapshot = await ref.child('degrees/postgraduate').get();

      final List<Degree> degrees = [];

      if (undergraduateSnapshot.exists) {
        final Map<dynamic, dynamic> undergraduateDataMap = undergraduateSnapshot.value as Map<dynamic, dynamic>;
        final List<dynamic> undergraduateData = undergraduateDataMap.values.toList();

        for (var data in undergraduateData) {
          degrees.add(Degree(
            title: data['title'],
            level: 'undergraduate',
          ));
        }
      }

      if (postgraduateSnapshot.exists) {
        final Map<dynamic, dynamic> postgraduateDataMap = postgraduateSnapshot.value as Map<dynamic, dynamic>;
        final List<dynamic> postgraduateData = postgraduateDataMap.values.toList();

        for (var data in postgraduateData) {
          degrees.add(Degree(
            title: data['title'],
            level: 'postgraduate',
          ));
        }
      }

      return degrees;
    } catch (error) {
      print("Failed to fetch degrees: $error");
      return [];
    }
  }
  
  // Add a new degree
  static Future<void> addDegree(Degree degree) async {
    try {
      final database = FirebaseDatabase.instance;
      final ref = database.ref('degrees/${degree.level}');

      await ref.push().set({
        'title': degree.title,
        'level': degree.level,
      });

      print('Degree added successfully.');
    } catch (error) {
      print('Failed to add degree: $error');
    }
  }
  
  //add modules to degree
  static Future<void> addModuleToDegree(Degree degree, String code, String title, String period, int credits) async {
     try {
      final database = FirebaseDatabase.instance;
      final ref = database.ref('degrees/${degree.level}');

      final snapshot = await ref.orderByChild('title').equalTo(degree.title).get();

      if (snapshot.exists) {
        final key = (snapshot.value as Map).keys.first;
        final modulesRef = database.ref('degrees/${degree.level}/$key/modules');

        await modulesRef.push().set({
          'code': code,
          'title': title,
          'period': period,
          'credits': credits,
        });

        print('Module added successfully to ${degree.title} ${degree.level} degree.');
      } else {
        print('Degree not found.');
      }
    } catch (error) {
      print('Failed to add module to ${degree.title} ${degree.level} degree: $error');
    }
  }
}