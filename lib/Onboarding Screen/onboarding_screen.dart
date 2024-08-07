import 'package:addislancers_app/Screens/Auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _navigateToLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

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
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildPage(
                  image: 'images/community.png',
                  title: 'Welcome to AddisLancers!',
                  description:
                      'Join a dynamic community where clients meet skilled freelancers. Whether you\'re looking to hire talent or offer your expertise, AddisLancers connects you with the right people and projects to achieve your goals.',
                ),
                _buildPage(
                  image: 'images/connect.png',
                  title: 'Collaboration and Management',
                  description:
                      'Leverage our tools to streamline project management. Communicate with clients, track your progress, and deliver results efficiently. AddisLancers ensures you stay organized and productive throughout your freelancing journey.',
                ),
                _buildPage(
                  image: 'images/team-work.png',
                  title: 'Build a Professional Profile',
                  description:
                      'Create a comprehensive profile that highlights your skills, experience, and portfolio. A well-crafted profile increases your visibility and attracts potential clients looking for your specific talents.',
                ),
              ],
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController, // PageController
            count: 3,
            effect: const WormEffect(), // your preferred effect
            onDotClicked: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              );
            },
          ),
          const SizedBox(height: 20),
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
