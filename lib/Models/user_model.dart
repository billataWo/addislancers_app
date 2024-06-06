import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String firstName;
  String lastName;
  String email;
  String profilePic;
  String? experience;
  String? description;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePic,
    this.experience,
    this.description,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      profilePic: data['profilePic'] ?? 'images/tmpProfile.jpg',
      experience: data.containsKey('experience') ? data['experience'] : null,
      description: data.containsKey('description') ? data['description'] : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePic': profilePic,
      'experience': experience,
      'description': description,
    };
  }
}
