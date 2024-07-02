import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:addislancers_app/Screens/Profile Screen/editprofile.dart';
import '../../Models/user_profile_model.dart';
import 'package:addislancers_app/Models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profilePicUrl;
  String? _backgroundPicUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  UserProfileModel? _userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (userDoc.exists) {
        _userProfile = UserProfileModel.fromDocument(userDoc);
        setState(() {
          _profilePicUrl = _userProfile?.profilePic;
          _backgroundPicUrl = _userProfile?.backgroundPic;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0,
        //title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Color.fromARGB(255, 1, 27, 82),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              ).then((_) => _fetchUserProfile()); // Refresh on return
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                _backgroundPicUrl == null
                    ? Container(
                        height: 200,
                        color: const Color.fromARGB(255, 0, 92, 251),
                      )
                    : Image.network(
                        _backgroundPicUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  top: 1,
                  //bottom: 0,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _profilePicUrl == null
                            ? const AssetImage(
                                'assets/images/default_profile_pic.jpg')
                            : NetworkImage(_profilePicUrl!) as ImageProvider,
                      ),
                      const SizedBox(height: 0),
                      Text(
                        '${_userProfile?.firstName ?? 'User'} ${_userProfile?.lastName ?? 'Name'}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 79, 249),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userProfile?.specialization ?? 'specialization',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              /* Text(
                                '${_userProfile?.winningJobs ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),*/
                              const Text(
                                'Total jobs',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 40),
                          Column(
                            children: [
                              /*Text(
                                '${_userProfile?.rating ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),*/
                              const Text(
                                'Rating',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Color.fromARGB(255, 0, 92, 251),
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: Color.fromARGB(255, 0, 92, 251),
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Portfolios'),
                    ],
                  ),
                  Container(
                    height: 400,
                    padding: const EdgeInsets.all(16.0),
                    child: TabBarView(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              _userProfile?.description ?? 'Description',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'skills',
                              style: TextStyle(fontSize: 16),
                            ),
                            Wrap(
                              spacing: 10,
                              children: _userProfile?.skills
                                      ?.toList()
                                      .map((e) => Chip(
                                            label: Text(e),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 175, 209, 241),
                                          ))
                                      .toList() ??
                                  [],
                            ),
                            /*Wrap(
                              spacing: 10,
                              children: _userProfile?.Skills
                                      ?.split(',')
                                      .map((e) => Chip(
                                            label: Text(e),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 175, 209, 241),
                                          ))
                                      .toList() ??
                                  [],
                            ),*/
                            const SizedBox(height: 10),
                            const Text(
                              'Language',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _userProfile?.languages
                                      ?.map((e) => Text('• $e'))
                                      .toList() ??
                                  [],
                            ),
                          ],
                        ),
                        GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _userProfile?.portfolios?.length ?? 0,
                          itemBuilder: (context, index) {
                            return Image.network(
                              _userProfile?.portfolios?[index] ?? '',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
