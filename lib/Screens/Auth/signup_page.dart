import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Home Screen/home_screen.dart';
import 'login_page.dart';
import 'package:addislancers_app/Models/user_model.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedRole = 'Client';

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Passwords do not match",
          style: TextStyle(fontSize: 20.0),
        ),
      ));
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'profilePic': 'images/tmpProfile.jpg', // Default profile pic
          'role': _selectedRole, // Store the selected role
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Registered successfully",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = "Password provided is too weak.";
      } else if (e.code == "email-already-in-use") {
        message = "Account already exists.";
      } else {
        message = "An error occurred.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: const Color.fromARGB(183, 22, 22, 21),
        content: Text(
          message,
          style: const TextStyle(fontSize: 18.0),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "images/bestlogo.png",
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _firstNameController,
                      hintText: "First Name",
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter first name' : null,
                    ),
                    const SizedBox(height: 30.0),
                    _buildTextField(
                      controller: _lastNameController,
                      hintText: "Last Name",
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter last name' : null,
                    ),
                    const SizedBox(height: 30.0),
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Email",
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter email' : null,
                    ),
                    const SizedBox(height: 30.0),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: "Password",
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter password' : null,
                    ),
                    const SizedBox(height: 30.0),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true,
                      validator: (value) => value!.isEmpty
                          ? 'Please confirm your password'
                          : null,
                    ),
                    const SizedBox(height: 30.0),
                    _buildRoleDropdown(),
                    const SizedBox(height: 30.0),
                    _buildButton(
                      text: "Sign Up",
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          _register();
                        }
                      },
                    ),
                    const SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Color(0xFF8c8e98),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LogIn()));
                          },
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                              color: Color(0xFF273671),
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
      decoration: BoxDecoration(
        color: const Color(0xFFedf0f8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0),
        ),
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
        decoration: BoxDecoration(
          color: const Color(0xFF273671),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
      decoration: BoxDecoration(
        color: const Color(0xFFedf0f8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        items: <String>['Client', 'Freelancer'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedRole = newValue!;
          });
        },
        validator: (value) => value == null ? 'Please select a role' : null,
      ),
    );
  }
}
