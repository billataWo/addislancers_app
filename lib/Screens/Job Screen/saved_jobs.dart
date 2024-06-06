import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'job_detail_page.dart';

class SavedJobsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SavedJobsPage({super.key});

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM kk:mm').format(dateTime);
  }

  Future<void> _removeSavedJob(String savedJobId) async {
    await FirebaseFirestore.instance
        .collection('savedJobs')
        .doc(savedJobId)
        .delete();
    print("Removed saved job with ID: $savedJobId");
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see saved jobs.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('savedJobs')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var savedJobs = snapshot.data!.docs;

                if (savedJobs.isEmpty) {
                  return const Center(child: Text('No saved jobs found.'));
                }

                return ListView.builder(
                  itemCount: savedJobs.length,
                  itemBuilder: (context, index) {
                    var savedJob = savedJobs[index];
                    var savedJobData = savedJob.data() as Map<String, dynamic>;
                    var jobId = savedJobData['jobId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('jobs')
                          .doc(jobId)
                          .get(),
                      builder: (context, jobSnapshot) {
                        if (!jobSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var jobData =
                            jobSnapshot.data!.data() as Map<String, dynamic>;
                        var jobTitle = jobData['title'];
                        var jobPayment = jobData['payment'];
                        String timestamp =
                            _formatTimestamp(jobData['timestamp']);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JobDetailPage(jobId: jobId),
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
                                    'Saved on: ${_formatTimestamp(savedJobData['timestamp'])}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  ButtonBar(
                                    alignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _removeSavedJob(savedJob.id);
                                        },
                                        child: const Text('Remove'),
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
            ),
    );
  }
}
