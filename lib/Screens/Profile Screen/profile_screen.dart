import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../Models/user_profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _profilePicUrl;
  File? _selectedFile;
  bool _isUploading = false;
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
          _experienceController.text = _userProfile?.experience ?? '';
          _descriptionController.text = _userProfile?.description ?? '';
        });
      }
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null) return null;
    setState(() {
      _isUploading = true;
    });

    final fileName = _selectedFile!.path.split('/').last;
    final storageRef =
        FirebaseStorage.instance.ref().child('profile_pics/$fileName');
    final uploadTask = storageRef.putFile(_selectedFile!);
    await uploadTask.whenComplete(() => null);

    final fileUrl = await storageRef.getDownloadURL();
    setState(() {
      _isUploading = false;
    });
    return fileUrl;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      String? fileUrl;
      if (_selectedFile != null) {
        fileUrl = await _uploadFile();
      }

      UserProfileModel updatedProfile = _userProfile!.copyWith(
        experience: _experienceController.text,
        description: _descriptionController.text,
        profilePic: fileUrl ?? _profilePicUrl,
      );

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update(updatedProfile.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _profilePicUrl == null
                  ? const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_profilePicUrl!),
                    ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Change Profile Picture'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(labelText: 'Experience'),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 3,
                maxLines: null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _updateProfile,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
