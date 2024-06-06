import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> otherUser;

  const ChatScreen(
      {super.key,
      required this.chatId,
      required this.otherUser,
      required String receiverId});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _messageController = TextEditingController();
  User? _user;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    var messages = await _firestore
        .collection('chats/${widget.chatId}/messages')
        .where('read', isEqualTo: false)
        .where('receiver', isEqualTo: _auth.currentUser?.uid)
        .get();
    for (var doc in messages.docs) {
      doc.reference.update({'read': true});
    }
  }

  Future<void> _sendMessage() async {
    if (_message.trim().isNotEmpty) {
      await _firestore.collection('chats/${widget.chatId}/messages').add({
        'text': _message,
        'sender': _user!.uid,
        'receiver': widget.otherUser['uid'],
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
      _messageController.clear();
      setState(() {
        _message = '';
      });
    }
  }

  Future<void> _sendFile(File file, String fileType) async {
    try {
      String fileName = file.path.split('/').last;
      Reference ref = _storage.ref().child('chat_files').child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String fileURL = await taskSnapshot.ref.getDownloadURL();

      await _firestore.collection('chats/${widget.chatId}/messages').add({
        'file': fileURL,
        'fileType': fileType,
        'sender': _user!.uid,
        'receiver': widget.otherUser['uid'],
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      await _sendFile(file, 'image');
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      await _sendFile(file, 'document');
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Sending...';
    }
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM kk:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.otherUser['firstName']} ${widget.otherUser['lastName']}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats/${widget.chatId}/messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;
                List<Widget> messageWidgets = messages.map((msg) {
                  Map<String, dynamic> data =
                      msg.data()! as Map<String, dynamic>;
                  bool isMe = _user!.uid == data['sender'];
                  String timestamp =
                      _formatTimestamp(data['timestamp'] as Timestamp?);
                  if (data.containsKey('text')) {
                    return _buildMessageBubble(data['text'], isMe, timestamp);
                  } else if (data.containsKey('file')) {
                    return _buildFileBubble(
                        data['file'], data['fileType'], isMe, timestamp);
                  } else {
                    return const SizedBox.shrink();
                  }
                }).toList();

                return ListView(
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, String timestamp) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                message,
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              ),
            ),
            Text(
              timestamp,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileBubble(
      String fileURL, String fileType, bool isMe, String timestamp) {
    Widget fileWidget;
    if (fileType == 'image') {
      fileWidget = Image.network(fileURL);
    } else {
      fileWidget = const Icon(Icons.insert_drive_file);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: fileWidget,
            ),
            Text(
              timestamp,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickDocument,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (value) {
                setState(() {
                  _message = value;
                });
              },
              decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
