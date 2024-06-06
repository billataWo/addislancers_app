import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badge_pkg;
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  int _unreadChatCount = 0;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _listenForUnreadMessages();
  }

  void _listenForUnreadMessages() {
    _firestore
        .collection('chats')
        .where('users', arrayContains: user!.uid)
        .snapshots()
        .listen((chatSnapshot) {
      int newChatCount = 0;
      chatSnapshot.docs.forEach((chatDoc) {
        _firestore
            .collection('chats/${chatDoc.id}/messages')
            .where('read', isEqualTo: false)
            .where('receiver', isEqualTo: user!.uid)
            .get()
            .then((messageSnapshot) {
          if (messageSnapshot.docs.isNotEmpty) {
            newChatCount++;
          }
          setState(() {
            _unreadChatCount = newChatCount;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: badge_pkg.Badge(
              badgeContent: _unreadChatCount > 0
                  ? Text(
                      '$_unreadChatCount',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
              child: const Icon(Icons.message),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('users', arrayContains: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var chats = snapshot.data!.docs;
          List<Widget> chatWidgets = chats.map((chat) {
            Map<String, dynamic> data = chat.data()! as Map<String, dynamic>;
            String chatId = chat.id;
            List<dynamic> users = data['users'];
            String otherUserId =
                users.firstWhere((uid) => uid != user!.uid, orElse: () => null);

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(otherUserId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                var otherUserData =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                return StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chats/$chatId/messages')
                      .where('read', isEqualTo: false)
                      .where('receiver', isEqualTo: user!.uid)
                      .snapshots(),
                  builder: (context, msgSnapshot) {
                    int unreadCount =
                        msgSnapshot.hasData ? msgSnapshot.data!.docs.length : 0;

                    return Card(
                      child: ListTile(
                        title: Text(
                            '${otherUserData['firstName']} ${otherUserData['lastName']}'),
                        trailing: unreadCount > 0
                            ? badge_pkg.Badge(
                                badgeContent: Text(
                                  '$unreadCount',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chatId,
                                otherUser: otherUserData,
                                receiverId: '',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          }).toList();

          return ListView(
            children: chatWidgets,
          );
        },
      ),
    );
  }
}
