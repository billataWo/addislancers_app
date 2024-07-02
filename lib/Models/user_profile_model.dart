import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String? profilePic;
  final String? backgroundPic;
  final String description;
  //final String winningJobs;
  final String specialization;

  final List<String> skills;
  final List<String> portfolios;
  final List<String> languages;

  UserProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.profilePic,
    this.backgroundPic,
    required this.description,
    required this.specialization,
    required this.skills,
    required this.portfolios,
    required this.languages,
  });

  factory UserProfileModel.fromDocument(DocumentSnapshot doc) {
    return UserProfileModel(
      uid: doc['uid'],
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      profilePic: doc['profilePic'],
      backgroundPic: doc['backgroundPic'],
      description: doc['description'],
      specialization: doc['specialization'],
      skills: List<String>.from(doc['skills']),
      portfolios: List<String>.from(doc['portfolios']),
      languages: List<String>.from(doc['languages']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'profilePic': profilePic,
      'backgroundPic': backgroundPic,
      'description': description,
      'specialization': specialization,
      'skills': skills,
      'portfolios': portfolios,
      'languages': languages,
    };
  }

  Future<void> createUserProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set(toMap());
  }

  Future<void> updateUserProfile() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(toMap());
  }

  Future<void> deleteUserProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  static Future<UserProfileModel?> getUserProfile(String uid) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfileModel.fromDocument(doc);
    }
    return null;
  }

  UserProfileModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? profilePic,
    String? backgroundPic,
    String? description,
    String? specialization,
    List<String>? skills,
    List<String>? portfolios,
    List<String>? languages,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePic: profilePic ?? this.profilePic,
      backgroundPic: backgroundPic ?? this.backgroundPic,
      description: description ?? this.description,
      specialization: specialization ?? this.specialization,
      skills: skills ?? this.skills,
      portfolios: portfolios ?? this.portfolios,
      languages: languages ?? this.languages,
    );
  }
}
