import 'dart:core';

class KUser {
  final int userId;
  final String email;
  final String name;

  KUser(
      {required this.userId,
        required this.email,
        required this.name,
      });

  KUser.fromJson(Map<String, Object?> json)
      : this(
    userId: json['userId']! as int,
    email: json['email']! as String,
    name: json['name']! as String,
  );

  Map<String, Object?> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
    };
  }
}
