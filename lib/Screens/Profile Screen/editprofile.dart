import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../Models/user_profile_model.dart';
import '../../Screens/Job Screen/job_data.dart'; // Adjust the import path as per your project structure

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _skillsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specializationController = TextEditingController();
  final _languagesController = TextEditingController();
  String? _profilePicUrl;
  String? _backgroundPicUrl;
  File? _selectedProfileFile;
  File? _selectedBackgroundFile;
  List<File> _portfolioFiles = [];
  List<Map<String, String>> _languages = [];
  bool _isUploading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  UserProfileModel? _userProfile;

  List<String> _suggestedSpecializations = [];
  List<String> _selectedSkills = [];
  List<String> _suggestedSkills = [];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      try {
        UserProfileModel? userProfile =
            await UserProfileModel.getUserProfile(_currentUser!.uid);
        setState(() {
          if (userProfile != null) {
            _userProfile = userProfile;
            _profilePicUrl = _userProfile?.profilePic;
            _backgroundPicUrl = _userProfile?.backgroundPic;
            _firstNameController.text = _userProfile?.firstName ?? '';
            _lastNameController.text = _userProfile?.lastName ?? '';
            _skillsController.text = _userProfile?.skills.join(', ') ?? '';
            _descriptionController.text = _userProfile?.description ?? '';
            _specializationController.text = _userProfile?.specialization ?? '';
            _languages = _userProfile?.languages
                    .map((lang) => {
                          'language': lang.split(' (')[0],
                          'proficiency':
                              lang.split(' (')[1].replaceAll(')', ''),
                        })
                    .toList() ??
                [];
            _selectedSkills = _userProfile?.skills.toList() ?? [];
          } else {
            // Set default values if no user profile data is found
            _setDefaultValues();
          }
        });
      } catch (e) {
        print('Error fetching user profile: $e');
        _setDefaultValues();
      }
    } else {
      _setDefaultValues();
    }
  }

  void _setDefaultValues() {
    setState(() {
      _userProfile = UserProfileModel(
        uid: _currentUser?.uid ?? '',
        firstName: '',
        lastName: '',
        profilePic: null,
        backgroundPic: null,
        description: '',
        specialization: '',
        skills: [],
        portfolios: [],
        languages: [],
      );
    });
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedProfileFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBackgroundPicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedBackgroundFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickPortfolioFiles() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _portfolioFiles.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _uploadPortfolios() async {
    List<String> portfolioUrls = [];
    try {
      for (File file in _portfolioFiles) {
        String? url = await _uploadFile(file, 'portfolios');
        if (url != null) {
          portfolioUrls.add(url);
        }
      }
      setState(() {
        _userProfile!.portfolios.addAll(portfolioUrls);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Portfolios uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading portfolios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      final fileName = file.path.split('/').last;
      final storageRef =
          FirebaseStorage.instance.ref().child('$path/$fileName');
      final uploadTask = storageRef.putFile(file);
      await uploadTask;
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Failed to upload file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      String? profilePicUrl = _profilePicUrl;
      String? backgroundPicUrl = _backgroundPicUrl;

      // Upload new profile picture if selected
      if (_selectedProfileFile != null) {
        // Delete the old profile picture if it exists
        if (_profilePicUrl != null) {
          try {
            await FirebaseStorage.instance.refFromURL(_profilePicUrl!).delete();
          } catch (e) {
            print('Failed to delete old profile picture: $e');
          }
        }
        profilePicUrl =
            await _uploadFile(_selectedProfileFile!, 'profile_pics');
      }

      // Upload new background picture if selected
      if (_selectedBackgroundFile != null) {
        // Delete the old background picture if it exists
        if (_backgroundPicUrl != null) {
          try {
            await FirebaseStorage.instance
                .refFromURL(_backgroundPicUrl!)
                .delete();
          } catch (e) {
            print('Failed to delete old background picture: $e');
          }
        }
        backgroundPicUrl =
            await _uploadFile(_selectedBackgroundFile!, 'background_pics');
      }

      List<String> portfolioUrls = [];
      for (File file in _portfolioFiles) {
        String? url = await _uploadFile(file, 'portfolios');
        if (url != null) {
          portfolioUrls.add(url);
        }
      }

      UserProfileModel updatedProfile = _userProfile!.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        skills: _selectedSkills,
        description: _descriptionController.text,
        specialization: _specializationController.text,
        profilePic: profilePicUrl,
        backgroundPic: backgroundPicUrl,
        portfolios: portfolioUrls,
        languages: _languages
            .map((lang) => '${lang['language']} (${lang['proficiency']})')
            .toList(),
      );

      try {
        await updatedProfile.updateUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _onSpecializationChanged(String value) {
    setState(() {
      _suggestedSpecializations = jobs
          .expand((job) =>
              job.specializations.map((spec) => '${job.title} - ${spec.name}'))
          .where((suggestion) =>
              suggestion.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _onSpecializationSelected(String value) {
    setState(() {
      _specializationController.text = value;
      _suggestedSpecializations = [];
      _selectedSkills = [];
      _suggestedSkills = [];
    });
  }

  void _onSkillChanged(String value) {
    setState(() {
      _suggestedSkills = jobs
          .expand((job) => job.specializations
              .expand((spec) => spec.skills)
              .where((skill) =>
                  skill.toLowerCase().contains(value.toLowerCase()) &&
                  !_selectedSkills.contains(skill)))
          .toList();
    });
  }

  void _onSkillSelected(String value) {
    setState(() {
      if (_selectedSkills.length < 6) {
        _selectedSkills.add(value);
        _skillsController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only select up to 6 skills.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _suggestedSkills = [];
    });
  }

  void _removeSkill(String skill) {
    setState(() {
      _selectedSkills.remove(skill);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _skillsController.dispose();
    _descriptionController.dispose();
    _specializationController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    if (_profilePicUrl != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(_profilePicUrl!),
                        radius: 50,
                      ),
                    if (_profilePicUrl == null)
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 50,
                      ),
                    TextButton(
                      onPressed: _pickProfilePicture,
                      child: const Text('Change Profile Picture'),
                    ),
                    const SizedBox(height: 16),
                    if (_backgroundPicUrl != null)
                      Image.network(_backgroundPicUrl!),
                    if (_backgroundPicUrl == null)
                      Container(
                        height: 150,
                        color: Colors.grey,
                      ),
                    TextButton(
                      onPressed: _pickBackgroundPicture,
                      child: const Text('Change Background Picture'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 4,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _specializationController,
                      decoration:
                          const InputDecoration(labelText: 'Specialization'),
                      onChanged: _onSpecializationChanged,
                      onTap: () {
                        _onSpecializationChanged('');
                      },
                    ),
                    if (_suggestedSpecializations.isNotEmpty)
                      ..._suggestedSpecializations.map((spec) {
                        return ListTile(
                          title: Text(spec),
                          onTap: () {
                            _onSpecializationSelected(spec);
                          },
                        );
                      }).toList(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skillsController,
                      decoration: InputDecoration(
                        labelText: 'Skills',
                        suffixText: 'Selected: ${_selectedSkills.length}/6',
                      ),
                      onChanged: _onSkillChanged,
                    ),
                    if (_suggestedSkills.isNotEmpty)
                      ..._suggestedSkills.map((skill) {
                        return ListTile(
                          title: Text(skill),
                          onTap: () {
                            _onSkillSelected(skill);
                          },
                        );
                      }).toList(),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _selectedSkills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          onDeleted: () {
                            _removeSkill(skill);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _portfolioFiles.length,
                      itemBuilder: (context, index) {
                        final file = _portfolioFiles[index];
                        return ListTile(
                          title: Text(file.path.split('/').last),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _portfolioFiles.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickPortfolioFiles,
                      child: const Text('Upload Portfolios'),
                    ),
                    const SizedBox(height: 16),
                    ..._languages.map((lang) {
                      return ListTile(
                        title: Text(
                            '${lang['language']} (${lang['proficiency']})'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _languages.remove(lang);
                            });
                          },
                        ),
                      );
                    }).toList(),
                    TextFormField(
                      controller: _languagesController,
                      decoration: const InputDecoration(
                          labelText: 'Languages (e.g., English (Fluent))'),
                      onFieldSubmitted: (value) {
                        if (value.isNotEmpty) {
                          final language = value.split(' (')[0];
                          final proficiency =
                              value.split(' (')[1].replaceAll(')', '');
                          setState(() {
                            _languages.add({
                              'language': language,
                              'proficiency': proficiency
                            });
                            _languagesController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _updateProfile,
                            child: const Text('Update Profile'),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
