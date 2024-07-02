import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String profilePic;
  final String role;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePic,
    required this.role,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      profilePic: data['profilePic'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
 /*
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String firstName;
  String lastName;
  String email;
  String userRole;
  String? profilePic;
  String? Skills;
  String? description;
  String? rating;
  String? portfolios;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userRole,
    required this.profilePic,
    this.Skills,
    this.description,
    this.portfolios,
    this.rating,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      firstName: data['firstName'] ?? 'First Name',
      lastName: data['lastName'] ?? 'Last Name',
      email: data['email'] ?? '',
      profilePic: data['profilePic'] ?? 'images/tmpProfile.jpg',
      userRole: data['userRole'],
      rating: data['rating'] ?? 'Not yet rated',
      portfolios: data['portfolios'] ?? 'upload portfolios',
      Skills: data.containsKey('Skills') ? data['Skills'] : null,
      description: data.containsKey('description') ? data['description'] : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userRole': userRole,
      'rating': rating,
      'portfolios': portfolios,
      'profilePic': profilePic,
      'Skills': Skills,
      'description': description,
    };
  }
}
*/
