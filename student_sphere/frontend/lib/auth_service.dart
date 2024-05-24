import 'package:student_sphere/user_role.dart';
import 'package:firebase_database/firebase_database.dart';
import 'announcement.dart';
import 'degree.dart';
import 'module.dart';
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

  static UserRole getRole(String role) {
    if (role == "UserRole.student") {
      return UserRole.student;
    } else if (role == "UserRole.administrator") {
      return UserRole.administrator;
    } else {
      return UserRole.unknown;
    }
  }

  static Future<SphereUser?> registerUser(String fname, String lname,
      String email, String password, String username, UserRole role,
      {String? degree}) async {
    try {
      // Initialize Firebase if not already initialized.
      initializeFirebase();

      // Register the user with Firebase Authentication.
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user's unique ID (UID)
      String userId = userCredential.user!.uid;

      DatabaseReference ref = FirebaseDatabase.instance.ref('users/$userId');

      // Create a map representing the user data
      Map<String, dynamic> userData = {
        'id': userId,
        'firstName': fname,
        'lastName': lname,
        'email': email,
        'username': username,
        'role': role.toString(),
        'degree': degree,
      };

      // Add registeredModules field only if the role is student
      if (role == UserRole.student) {
        userData['registeredModules'] = [];
      }

      await ref.set(userData);

      print('User data saved successfully.');

      SphereUser user = SphereUser(
        id: userId,
        fname: fname,
        lname: lname,
        username: username,
        email: email,
        role: role,
        degree: degree,
      );

      User? authUser = FirebaseAuth.instance.currentUser;

      if (authUser != null && !authUser.emailVerified) {
        await authUser.sendEmailVerification();
        print('Verification email sent.');
      }

      // Return the registered user.
      return user;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'The email address is already in use by another account.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }
      throw errorMessage;
    } catch (error) {
      // Handle other errors
      throw 'Registration failed. Please try again.';
    }
  }

  static Future<SphereUser?> loginUser(String email, String password) async {
    try {
      // Initialize Firebase if not already initialized.
      initializeFirebase();

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      SphereUser? user;

      String userId = userCredential.user!.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('users/$userId').get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;

        final String id = userData['id'] ?? '';
        final String fname = userData['firstName'] ?? '';
        final String lname = userData['lastName'] ?? '';
        final String username = userData['username'] ?? '';
        final String email = userData['email'] ?? '';
        final UserRole role = getRole(userData['role'] ?? 'UserRole.unknown');
        final String? degree = userData['degree'];

        List<Module> registeredModules = [];
        if (role == UserRole.student && userData['registeredModules'] != null) {
          registeredModules = (userData['registeredModules'] as List)
              .map((moduleData) => Module.fromMap(moduleData))
              .toList();
        }

        user = SphereUser(
          id: id,
          fname: fname,
          lname: lname,
          email: email,
          username: username,
          role: role,
          degree: degree,
          registeredModules: registeredModules,
        );
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

  //fetches all modules
  static Future<Map<String, List<Module>>> fetchModules() async {
    try {
      final database = FirebaseDatabase.instance;
      final ref = database.ref().child('modules');

      final snapshot = await ref.get();

      final List<Module> undergraduateModules = [];
      final List<Module> postgraduateModules = [];

      if (snapshot.exists) {
        final Map<dynamic, dynamic> modulesDataMap =
            snapshot.value as Map<dynamic, dynamic>;

        modulesDataMap.forEach((key, value) {
          Module module = Module(
              id: value['id'],
              code: value['code'],
              title: value['title'],
              level: value['level'],
              credits: value['credits'],
              period: value['period'],
              published: value['published']);

          // Compare the level with correct casing
          if (module.level.toLowerCase() == 'undergraduate') {
            undergraduateModules.add(module);
          } else if (module.level.toLowerCase() == 'postgraduate') {
            postgraduateModules.add(module);
          }
        });
      }

      return {
        'undergraduate': undergraduateModules,
        'postgraduate': postgraduateModules,
      };
    } catch (error) {
      print("Failed to fetch modules: $error");
      return {
        'undergraduate': [],
        'postgraduate': [],
      };
    }
  }

  static Future<List<Announcement>?> fetchAnnouncements(Module module) async {
    try {
      final database = FirebaseDatabase.instance;
      final ref = database.ref().child('modules/${module.id}/announcements');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? announcementsData =
            snapshot.value as Map<dynamic, dynamic>?;
        print('Announcements Data: $announcementsData');

        if (announcementsData != null) {
          final List<Announcement> announcements = [];
          announcementsData.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              announcements
                  .add(Announcement.fromMap(Map<String, dynamic>.from(value)));
            }
          });

          print('Parsed Announcements: $announcements');
          return announcements;
        } else {
          print('Announcements data is null');
          return [];
        }
      } else {
        print('Announcements snapshot does not exist');
        return [];
      }
    } catch (error) {
      print('Failed to fetch announcements: $error');
      throw error;
    }
  }

  //STUDENT FUNCTIONS

  //fetches student's registered modules
  static Future<List<Module>?> fetchUserModules(String userId) async {
    try {
      final database = FirebaseDatabase.instance;
      final ref = database
          .ref()
          .child('users')
          .child(userId)
          .child('registeredModules');

      final snapshot = await ref.get();

      if (snapshot.exists) {
        final List<dynamic>? moduleDataList = snapshot.value as List<dynamic>?;
        final List<Module>? modules = moduleDataList
            ?.map((moduleData) => Module.fromMap(moduleData))
            .toList();
        return modules;
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching user modules: $error');
      throw error;
    }
  }

  //remove a module from student's registered modules
  static Future<void> deleteUserModule(String userId, String moduleId) async {
    try {
      final DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users/$userId');

      // Fetch the user's data from the database
      DataSnapshot userSnapshot = (await userRef.once()).snapshot;

      if (userSnapshot.value != null) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>?;

        if (userData != null && userData.containsKey('registeredModules')) {
          final registeredModulesData =
              userData['registeredModules'] as List<dynamic>?;

          if (registeredModulesData != null) {
            List<Module> registeredModules =
                registeredModulesData.map((moduleData) {
              return Module.fromMap(Map<String, dynamic>.from(moduleData));
            }).toList();

            int indexToDelete =
                registeredModules.indexWhere((module) => module.id == moduleId);

            if (indexToDelete != -1) {
              registeredModules.removeAt(indexToDelete);

              List<Map<String, dynamic>> updatedModulesData =
                  registeredModules.map((module) => module.toMap()).toList();

              await userRef.update({'registeredModules': updatedModulesData});
              print('Database updated successfully');
            } else {
              print('Module not found in registeredModules');
            }
          } else {
            print('registeredModules is null');
          }
        } else {
          print('No registeredModules found for user');
        }
      } else {
        print('User data is null');
      }
    } catch (error) {
      print('Error deleting user module: $error');
      throw error;
    }
  }

  static Future<void> updateUserModules(
      String userId, List<Map<String, dynamic>> updatedModulesData) async {
    try {
      final DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users/$userId');
      await userRef.update({'registeredModules': updatedModulesData});
      print('User modules updated successfully.');
    } catch (error) {
      print('Error updating user modules: $error');
      throw error;
    }
  }

  //ADMIN FUNTIONS
  static Future<String> addModule(String code, String title, String period,
      int credits, String level, bool published) async {
    try {
      final database = FirebaseDatabase.instance;
      final ref = database.ref('modules');

      // Push the module data to the database and get the reference
      final newModuleRef = ref.push();

      // Save the autogenerated key to a variable
      final String moduleId = newModuleRef.key ?? '';

      // Set the module data under the autogenerated key
      await newModuleRef.set({
        'code': code,
        'title': title,
        'period': period,
        'credits': credits,
        'level': level,
        'id': moduleId, // Save the autogenerated key to the 'id' field
        'published': published
      });

      return 'Module added successfully.';
    } catch (error) {
      print('Failed to add module: $error');
      return 'Failed to add module: $error';
    }
  }

  static Future<String> updateModule(Module module) async {
    try {
      final database = FirebaseDatabase.instance;
      final ref = database
          .ref()
          .child('modules')
          .child(module.id); // Assuming each module has a unique ID

      await ref.update({
        'code': module.code,
        'title': module.title,
        'period': module.period,
        'credits': module.credits,
        'level': module.level,
        'published': module.published
      });

      return "Module updated successfully";
    } catch (error) {
      print("Failed to update module: $error");
      return "Failed to update module";
    }
  }

  static Future<String> deleteModule(String moduleId) async {
    try {
      final database = FirebaseDatabase.instance;
      final ref = database.ref('modules/$moduleId');

      // Remove the module data from the database
      await ref.remove();

      return "Module deleted successfully";
    } catch (error) {
      print("Failed to delete module: $error");
      return "Failed to delete module";
    }
  }

  static Future<String> setModulePublishStatus(
      String moduleId, bool isPublished) async {
    try {
      await FirebaseDatabase.instance
          .ref()
          .child('modules')
          .child(moduleId)
          .update({
        'published': isPublished,
      });

      return 'Module ${isPublished ? "published" : "unpublished"} successfully';
    } catch (e) {
      return 'Error updating module status: $e';
    }
  }

  static Future<void> addAnnouncement(
      Module module, String title, String description) async {
    try {
      DatabaseReference announcementsRef =
          FirebaseDatabase.instance.ref('modules/${module.id}/announcements');

      Announcement newAnnouncement = Announcement(
        title: title,
        description: description,
        date: DateTime.now(),
      );

      await announcementsRef.push().set(newAnnouncement.toMap());
    } catch (error) {
      print('Failed to add announcement: $error');
      throw error;
    }
  }
}
