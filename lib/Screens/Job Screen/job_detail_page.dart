import 'package:addislancers_app/Models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class JobDetailPage extends StatefulWidget {
  final String jobId;

  const JobDetailPage({required this.jobId});

  @override
  // ignore: library_private_types_in_public_api
  _JobDetailPageState createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> _jobFuture;
  late Future<bool> _appliedFuture;
  late Future<int> _applicationCountFuture;
  String? _profilePicUrl;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _jobFuture = _fetchJobDetails();
    _appliedFuture = _checkIfApplied();
    _applicationCountFuture = _getApplicationCount();
  }

  Future<DocumentSnapshot> _fetchJobDetails() {
    return FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .get();
  }

  Future<void> _getUserDetails() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userModel = UserModel.fromDocument(userDoc);
            _profilePicUrl = _userModel!.profilePic;
          });
        } else {
          print("User document does not exist.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User document does not exist.'),
            ),
          );
        }
      } catch (e) {
        print("Error fetching user details: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error fetching user details. Please try again later.'),
          ),
        );
      }
    }
  }

  Future<bool> _checkIfApplied() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: widget.jobId)
          .where('userId', isEqualTo: user.uid)
          .get();
      return snapshot.docs.isNotEmpty;
    }
    return false;
  }

  Future<int> _getApplicationCount() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('applications')
        .where('jobId', isEqualTo: widget.jobId)
        .get();
    return snapshot.docs.length;
  }

  Future<void> _applyForJob() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var existingApplication = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: widget.jobId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingApplication.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('applications').add({
          'jobId': widget.jobId,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully applied for the job.')),
        );
        setState(() {
          _appliedFuture = Future.value(true);
          _applicationCountFuture = _getApplicationCount();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You have already applied for this job.')),
        );
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM kk:mm').format(dateTime);
  }

  Future<DocumentSnapshot> _fetchPosterProfile(String posterId) {
    return FirebaseFirestore.instance.collection('users').doc(posterId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _jobFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var job = snapshot.data!;
          var jobData = job.data() as Map<String, dynamic>;
          var jobTitle = jobData['title'];
          var jobDescription = jobData['description'];
          var jobPayment = jobData['payment'];
          var jobPosterId = jobData['posterId'];
          String timestamp = _formatTimestamp(jobData['timestamp']);
          var jobAttachment =
              jobData.containsKey('attachment') ? jobData['attachment'] : null;

          return FutureBuilder<DocumentSnapshot>(
            future: _fetchPosterProfile(jobPosterId),
            builder: (context, posterSnapshot) {
              if (!posterSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var posterData =
                  posterSnapshot.data!.data() as Map<String, dynamic>;
              var posterName =
                  posterData['firstName'] + ' ' + posterData['lastName'];
              var posterProfilePic = posterData[CircleAvatar(
                backgroundImage: _profilePicUrl == null
                    ? const AssetImage('assets/images/default_profile_pic.jpg')
                    : NetworkImage(_profilePicUrl!) as ImageProvider,
                radius: 30.0,
              )];

              return FutureBuilder<int>(
                future: _applicationCountFuture,
                builder: (context, countSnapshot) {
                  if (!countSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  int applicationCount = countSnapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                jobTitle,
                                style: const TextStyle(fontSize: 24),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$applicationCount applicants',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: posterProfilePic != null
                                      ? NetworkImage(posterProfilePic)
                                      : const AssetImage(
                                              'images/tmpProfile.jpg')
                                          as ImageProvider,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  posterName,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(jobDescription),
                        const SizedBox(height: 20),
                        Text(
                          'Payment: $jobPayment',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text('Posted: $timestamp'),
                        const SizedBox(height: 10),
                        if (jobAttachment != null) ...[
                          const Text('Attachment:'),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              // Open the attachment
                            },
                            child: Text(
                              jobAttachment,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        FutureBuilder<bool>(
                          future: _appliedFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            bool hasApplied = snapshot.data!;

                            return ElevatedButton(
                              onPressed: hasApplied
                                  ? null
                                  : () {
                                      _applyForJob();
                                    },
                              child: Text(
                                  hasApplied ? 'Already Applied' : 'Apply Now'),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
