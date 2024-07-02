import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:addislancers_app/Screens/Job%20Screen/job_detail_page.dart';

class JobList extends StatelessWidget {
  final List<DocumentSnapshot> allJobs;
  final Future<void> Function() refreshJobs;

  JobList({
    required this.allJobs,
    required this.refreshJobs,
  });

  String _truncateDescription(String description, int wordLimit) {
    List<String> words = description.split(' ');
    if (words.length > wordLimit) {
      return words.sublist(0, wordLimit).join(' ') + '...';
    }
    return description;
  }

  @override
  Widget build(BuildContext context) {
    if (allJobs.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: refreshJobs,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: allJobs.length,
        itemBuilder: (context, index) {
          var job = allJobs[index];
          var jobData = job.data() as Map<String, dynamic>;
          var jobTitle = jobData['title'];
          var jobDescription = _truncateDescription(jobData['description'], 10);
          var jobPayment = jobData['payment'];
          var jobTimestamp = jobData['timestamp'] as Timestamp;
          var jobDate =
              DateFormat('dd MMM kk:mm').format(jobTimestamp.toDate());

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            color: Color.fromARGB(255, 223, 234, 248),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                jobTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 36, 149),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(jobDescription),
                  SizedBox(height: 8),
                  Text(
                    'Payment: $jobPayment',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  SizedBox(height: 4),
                  Text('Posted: $jobDate',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailPage(jobId: job.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
