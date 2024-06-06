import 'package:addislancers_app/firebase_options.dart';
//import 'package:addislancers_app/home_screen.dart';
import 'package:addislancers_app/Screens/Home%20Screen/settings_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/Auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme:
              themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: const LogIn(),
          routes: {
            '/settings': (context) => const SettingsPage(),
            '/login': (context) => const LogIn(),
          },
        );
      },
    );
  }
}
