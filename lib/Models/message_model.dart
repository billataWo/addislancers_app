import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String sender;
  String receiver;
  String text;
  String fileURL;
  String fileType;
  Timestamp timestamp;

  MessageModel({
    required this.sender,
    required this.receiver,
    this.text = '',
    this.fileURL = '',
    this.fileType = '',
    required this.timestamp,
  });

  // Factory constructor to create a MessageModel from Firestore DocumentSnapshot
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    return MessageModel(
      sender: doc['sender'],
      receiver: doc['receiver'],
      text: doc['text'] ?? '',
      fileURL: doc['file'] ?? '',
      fileType: doc['fileType'] ?? '',
      timestamp: doc['timestamp'],
    );
  }

  // Method to convert MessageModel to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'text': text,
      'file': fileURL,
      'fileType': fileType,
      'timestamp': timestamp,
    };
  }
}
