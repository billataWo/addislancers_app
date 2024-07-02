import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentController = TextEditingController();
  final _deadlineController = TextEditingController();
  String _paymentType = 'Hourly';
  File? _selectedFile;
  bool _isUploading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _posterName;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _posterName = '${userDoc['firstName']} ${userDoc['lastName']}';
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
        FirebaseStorage.instance.ref().child('job_files/$fileName');
    final uploadTask = storageRef.putFile(_selectedFile!);
    await uploadTask.whenComplete(() => null);

    final fileUrl = await storageRef.getDownloadURL();
    setState(() {
      _isUploading = false;
    });
    return fileUrl;
  }

  Future<void> _postJob() async {
    if (_formKey.currentState!.validate()) {
      String? fileUrl;
      if (_selectedFile != null) {
        fileUrl = await _uploadFile();
      }

      User? user = _auth.currentUser;
      if (user == null) return;

      try {
        await FirebaseFirestore.instance.collection('jobs').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'payment': _paymentController.text,
          'paymentType': _paymentType,
          'deadline': _deadlineController.text,
          'fileUrl': fileUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'poster': _posterName ?? 'Anonymous',
          'posterId': user.uid,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState?.reset();
        setState(() {
          _selectedFile = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post job: $e'),
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
        title: const Text('Post a Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Job Description'),
                minLines: 3,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentController,
                decoration: const InputDecoration(labelText: 'Payment Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the payment amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentType,
                decoration: const InputDecoration(labelText: 'Payment Type'),
                items: ['Hourly', 'Fixed'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _paymentType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Application Deadline',
                  hintText: 'YYYY-MM-DD',
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the application deadline';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _selectedFile == null
                  ? const Text('No file selected.')
                  : Text(
                      'File selected: ${_selectedFile!.path.split('/').last}'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Select File'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _postJob,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Post Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
