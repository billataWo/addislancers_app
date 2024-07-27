import 'package:addislancers_app/Onboarding%20Screen/onboarding_screen.dart';
import 'package:addislancers_app/Screens/Home%20Screen/account_settings.dart';
import 'package:addislancers_app/Screens/Home%20Screen/settings_page.dart';
import 'package:addislancers_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme:
              themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: seenOnboarding ? const LogIn() : const OnboardingScreen(),
          routes: {
            '/settings': (context) => const SettingsPage(),
            '/login': (context) => const LogIn(),
          },
        );
      },
    );
  }
}
