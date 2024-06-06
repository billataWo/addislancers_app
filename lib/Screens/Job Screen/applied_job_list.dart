import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Chat Screen/chat_screen.dart';

class AppliedJobListPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppliedJobListPage({super.key});

  Future<void> _sendMessage(String jobPosterId, Map<String, dynamic> posterData,
      BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Check if a chat already exists
      var chatQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: user.uid)
          .get();

      String chatId = '';

      for (var chat in chatQuery.docs) {
        List<dynamic> users = chat['users'];
        if (users.contains(jobPosterId)) {
          chatId = chat.id;
          break;
        }
      }

      if (chatId.isEmpty) {
        // Create a new chat if it doesn't exist
        var newChatDoc =
            await FirebaseFirestore.instance.collection('chats').add({
          'users': [user.uid, jobPosterId],
        });
        chatId = newChatDoc.id;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: chatId,
            otherUser: posterData,
            receiverId: jobPosterId,
          ),
        ),
      );
    }
  }

  Future<DocumentSnapshot> _fetchPosterProfile(String posterId) {
    return FirebaseFirestore.instance.collection('users').doc(posterId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applied Jobs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var applications = snapshot.data!.docs;

          if (applications.isEmpty) {
            return const Center(child: Text('No applied jobs found'));
          }

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              var application = applications[index];
              var jobId = application['jobId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('jobs')
                    .doc(jobId)
                    .get(),
                builder: (context, jobSnapshot) {
                  if (!jobSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (jobSnapshot.data == null ||
                      jobSnapshot.data!.data() == null) {
                    return const ListTile(
                      title: Text('Job details not found'),
                      subtitle: Text('This job might have been deleted.'),
                    );
                  }

                  var jobData =
                      jobSnapshot.data!.data() as Map<String, dynamic>;
                  var jobTitle = jobData['title'];
                  var jobPayment = jobData['payment'];
                  var jobPosterId = jobData['posterId'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: _fetchPosterProfile(jobPosterId),
                    builder: (context, posterSnapshot) {
                      if (!posterSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (posterSnapshot.data == null ||
                          posterSnapshot.data!.data() == null) {
                        return const ListTile(
                          title: Text('Poster details not found'),
                          subtitle: Text('This user might have been deleted.'),
                        );
                      }

                      var posterData =
                          posterSnapshot.data!.data() as Map<String, dynamic>;
                      var posterName = posterData['firstName'] +
                          ' ' +
                          posterData['lastName'];
                      var posterProfilePic = posterData['profilePic'];

                      return Card(
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
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            posterProfilePic != null
                                                ? NetworkImage(posterProfilePic)
                                                : const AssetImage(
                                                        'images/tmpProfile.jpg')
                                                    as ImageProvider,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(posterName),
                                    ],
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
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _sendMessage(
                                      jobPosterId, posterData, context);
                                },
                                child: const Text('Send Message'),
                              ),
                            ],
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
