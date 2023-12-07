import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? uid;
  late String firstName;
  late String lastName;
  late String username;
  late String email;
  late String dateOfBirth;
  late String gender;
  late String travelCompanion;
  late String healthCondition;
  late String needStroller;

  User({
    this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.travelCompanion,
    required this.healthCondition,
    required this.needStroller,
  });

  static String dateOfBirthFormatted(DateTime dateOfBirth) {
    final date = dateOfBirth;
    return '${date.year}-${date.month}-${date.day}';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      email: json['email'],
      dateOfBirth: dateOfBirthFormatted(json['date_of_birth']),
      gender: json['gender'],
      travelCompanion: json['travel_companion'],
      healthCondition: json['health_condition'],
      needStroller: json['need_stroller'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid ?? '',
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'travel_companion': travelCompanion,
      'health_condition': healthCondition,
      'need_stroller': needStroller,
    };
  }

  User.fromDocumentSnapshot({required DocumentSnapshot documentSnapshot}) {
    firstName = documentSnapshot['first_name'];
    lastName = documentSnapshot['last_name'];
    username = documentSnapshot['username'];
    email = documentSnapshot['email'];
    dateOfBirth = documentSnapshot['date_of_birth'];
    gender = documentSnapshot['gender'];
    travelCompanion = documentSnapshot['travel_companion'];
    healthCondition = documentSnapshot['health_condition'];
    needStroller = documentSnapshot['need_stroller'].toString();
  }
}
