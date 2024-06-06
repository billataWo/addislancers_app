import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'job_detail_page.dart';

class JobListPage extends StatelessWidget {
  final String searchQuery;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  JobListPage({super.key, this.searchQuery = ""});

  Future<void> _applyForJob(String jobId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('applications').add({
        'jobId': jobId,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Applied for job with ID: $jobId");
    }
  }

  Future<void> _saveJob(String jobId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('savedJobs').add({
        'jobId': jobId,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Saved job with ID: $jobId");
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM kk:mm').format(dateTime);
  }

  Future<int> _getApplicationCount(String jobId) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .get();
    return snapshot.docs.length;
  }

  Future<bool> _hasUserApplied(String jobId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('userId', isEqualTo: user.uid)
          .get();
      return snapshot.docs.isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //title: Text('Welcome to AddisLancers'),
      //backgroundColor: const Color.fromARGB(255, 214, 237, 255),
      //  ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (searchQuery.isEmpty
                ? FirebaseFirestore.instance
                    .collection('jobs')
                    .orderBy('timestamp', descending: true)
                : FirebaseFirestore.instance
                    .collection('jobs')
                    .where('title', isGreaterThanOrEqualTo: searchQuery)
                    .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff')
                    .orderBy('title'))
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: const CircularProgressIndicator());
          }

          var jobs = snapshot.data!.docs;

          if (jobs.isEmpty) {
            return Center(child: Text('No jobs found'));
          }

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              var job = jobs[index];
              var jobData = job.data() as Map<String, dynamic>;
              var jobTitle = jobData['title'];
              var jobPayment = jobData['payment'];
              String timestamp = _formatTimestamp(jobData['timestamp']);

              return FutureBuilder<int>(
                future: _getApplicationCount(job.id),
                builder: (context, countSnapshot) {
                  if (!countSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  int applicationCount = countSnapshot.data!;

                  return FutureBuilder<bool>(
                    future: _hasUserApplied(job.id),
                    builder: (context, appliedSnapshot) {
                      if (!appliedSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      bool hasApplied = appliedSnapshot.data!;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  JobDetailPage(jobId: job.id),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.all(10.0),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      jobTitle,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '$applicationCount applicants',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Payment: $jobPayment',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Posted: $timestamp',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                ButtonBar(
                                  alignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: hasApplied
                                              ? null
                                              : () {
                                                  _applyForJob(job.id);
                                                },
                                          child: Text(hasApplied
                                              ? 'Already Applied'
                                              : 'Quick Apply'),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.bookmark_border),
                                          onPressed: () {
                                            _saveJob(job.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
