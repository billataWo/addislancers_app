import 'package:addislancers_app/Screens/Auth/login_page.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogIn()),
    );
  }

  Widget _buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 300),
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          _buildPage(
            image: 'images/connect.png',
            title: 'Connect with another people',
            description:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris laoreet justo odio eget finibus mi porttitor ac.',
          ),
          _buildPage(
            image: 'images/community.png',
            title: 'Create your community',
            description:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris laoreet justo odio eget finibus mi porttitor ac.',
          ),
          _buildPage(
            image: 'images/team-work.png',
            title: 'Find new friends',
            description:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris laoreet justo odio eget finibus mi porttitor ac.',
          ),
        ],
      ),
      bottomSheet: Container(
        height: 80,
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: TextButton(
            onPressed: _navigateToLogin,
            child: const Text(
              'Get Started',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}
