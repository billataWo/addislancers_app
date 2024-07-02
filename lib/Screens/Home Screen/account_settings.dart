import 'package:addislancers_app/Screens/Auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings',
              style: TextStyle(color: Color.fromARGB(255, 2, 36, 149))),
          //backgroundColor: Color.fromARGB(255, 226, 230, 234),
        ),
        //backgroundColor: Color.fromARGB(255, 0, 33, 131),
        body: const AccountSettingsPageBody(),
      ),
    );
  }
}

class AccountSettingsPageBody extends StatelessWidget {
  const AccountSettingsPageBody({super.key});

  void _deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        // Delete user account
        await user.delete();
        // Sign out the user
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(
            context, '/login'); // Replace '/login' with your login route
      }
    } catch (e) {
      print("Error deleting account: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting account. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.brightness_6,
              color: Color.fromARGB(255, 2, 36, 149)),
          title: const Text('Dark Mode',
              style: TextStyle(color: Color.fromARGB(255, 2, 36, 149))),
          trailing: Switch(
            value: themeNotifier.isDarkMode,
            onChanged: (value) {
              themeNotifier.toggleTheme();
            },
            activeColor: const Color.fromARGB(255, 2, 36, 149),
            activeTrackColor: const Color.fromARGB(255, 126, 126, 126),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever,
              color: Color.fromARGB(255, 2, 36, 149)),
          title: const Text('Delete Account',
              style: TextStyle(color: Color.fromARGB(255, 2, 36, 149))),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Account',
                      style: TextStyle(color: Color.fromARGB(255, 255, 0, 0))),
                  content: const Text(
                      'Are you sure you want to delete your account? This action is irreversible.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteAccount(context);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const LogIn()),
                        );
                      },
                      icon: const Icon(Icons.delete,
                          color: Color.fromARGB(255, 255, 0, 0)),
                      label: Text('Delete'),
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
