import 'package:flutter/foundation.dart';
import 'dart:convert';

class Users {
  final int? id;
  final String username;
  final String email;
  final String password;


  Users({this.id, required this.username, required this.email, required this.password});

  
  Map<String, dynamic> toMap () {
    return {
      'id' : id,
      'username' : username,
      'email' : email,
      'password' : password
    };
  }
   
  String toJson() => jsonEncode(toMap());

  factory Users.fromJson(String source) => Users.fromMap(jsonDecode(source));

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(id: map['id'], username: map['username'], email: map['email'], password: map['password']);
  }

}