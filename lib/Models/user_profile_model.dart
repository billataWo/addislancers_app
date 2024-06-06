import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String firstName;
  final String lastName;
  final String experience;
  final String description;
  final String profilePic;
  final String resume;

  UserProfileModel({
    required this.firstName,
    required this.lastName,
    this.experience = '',
    this.description = '',
    this.profilePic = '',
    this.resume = '',
  });

  // Factory constructor to create a UserProfileModel from Firestore DocumentSnapshot
  factory UserProfileModel.fromDocument(DocumentSnapshot doc) {
    return UserProfileModel(
      firstName: doc['firstName'] ?? '',
      lastName: doc['lastName'] ?? '',
      experience: doc['experience'] ?? '',
      description: doc['description'] ?? '',
      profilePic: doc['profilePic'] ?? '',
      resume: doc['resume'] ?? '',
    );
  }

  // Method to convert UserProfileModel to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'experience': experience,
      'description': description,
      'profilePic': profilePic,
      'resume': resume,
    };
  }

  // Method to create a copy of the current instance with optional new values
  UserProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? experience,
    String? description,
    String? profilePic,
    String? resume,
  }) {
    return UserProfileModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      experience: experience ?? this.experience,
      description: description ?? this.description,
      profilePic: profilePic ?? this.profilePic,
      resume: resume ?? this.resume,
    );
  }
}
