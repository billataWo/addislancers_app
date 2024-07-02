import 'package:addislancers_app/Screens/Auth/login_page.dart';
import 'package:addislancers_app/Screens/Home%20Screen/account_settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:addislancers_app/Screens/Profile Screen/editprofile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(color: Color.fromARGB(255, 2, 36, 149))),
        //backgroundColor: Color.fromARGB(255, 226, 230, 234),
      ),
      //backgroundColor: Color.fromARGB(255, 0, 33, 131),
      body: const SettingsPageBody(),
    );
  }
}

class SettingsPageBody extends StatelessWidget {
  const SettingsPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading:
              Icon(Icons.payment, color: const Color.fromARGB(255, 2, 36, 149)),
          title: const Text(
            'Edit Your Profile',
            style: TextStyle(color: Color.fromARGB(255, 2, 36, 149)),
          ),
          onTap: () {
            // yImplement Payment page navigation

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfileScreen()));
          },
        ),
        ListTile(
          leading:
              Icon(Icons.payment, color: const Color.fromARGB(255, 2, 36, 149)),
          title: const Text(
            'Account Settings',
            style: TextStyle(color: Color.fromARGB(255, 2, 36, 149)),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AccountSettingsPage()));
          },
        ),
        ListTile(
          leading:
              Icon(Icons.payment, color: const Color.fromARGB(255, 2, 36, 149)),
          title: const Text(
            'Payment',
            style: TextStyle(color: Color.fromARGB(255, 2, 36, 149)),
          ),
          onTap: () {
            // yImplement Payment page navigation
          },
        ),
        ListTile(
          leading:
              const Icon(Icons.info, color: Color.fromARGB(255, 2, 36, 149)),
          title: const Text('About',
              style: TextStyle(color: Color.fromARGB(255, 2, 36, 149))),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('About'),
                  content: const Text(
                      'Developers: \n     Bilata Wodisha\n     Frezer Bizuwerk\n\nApp Version: 1.0.0'),
                  shadowColor: Color.fromARGB(197, 0, 0, 0),
                  backgroundColor: Color.fromARGB(170, 203, 211, 238),
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
        ListTile(
          leading:
              const Icon(Icons.logout, color: Color.fromARGB(255, 2, 36, 149)),
          title: const Text(
            'Log Out',
            style: TextStyle(color: Color.fromARGB(255, 2, 36, 149)),
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LogIn()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ],
    );
  }
}
