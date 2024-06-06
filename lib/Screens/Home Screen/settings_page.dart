import 'package:addislancers_app/Screens/Auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 20, 34, 90),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 34, 90),
        body: const SettingsPageBody(),
      ),
    );
  }
}

class SettingsPageBody extends StatelessWidget {
  const SettingsPageBody({super.key});

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
          leading: const Icon(Icons.brightness_6, color: Colors.white),
          title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
          trailing: Switch(
            value: themeNotifier.isDarkMode,
            onChanged: (value) {
              themeNotifier.toggleTheme();
            },
            activeColor: const Color.fromARGB(255, 56, 21, 255),
            activeTrackColor: const Color.fromARGB(255, 126, 126, 126),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.white),
          title: const Text('Delete Account',
              style: TextStyle(color: Colors.white)),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Account',
                      style: TextStyle(color: Colors.white)),
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
                          color: Color.fromARGB(255, 255, 0,
                              0)), // Customize the icon and its color
                      label: Text('Delete'),
                    )
                  ],
                );
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info, color: Colors.white),
          title: const Text('About', style: TextStyle(color: Colors.white)),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('About'),
                  content: const Text(
                      'Developers: \n     Bilata Wodisha\n     Frezer Bizuwerk\n\nApp Version: 1.0.0'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
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
