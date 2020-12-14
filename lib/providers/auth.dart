import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shop/utils/constants.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=${Constants.API_KEY}";

    final response = await http.post(
      url,
      body: json.encode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );

    print(json.decode(response.body));

    return Future.value();
  }

  Future<void> signup(String email, String password) async {
    _authenticate(email, password, "signUp");
  }

  Future<void> signin(String email, String password) async {
    _authenticate(email, password, "signInWithPassword");
  }
}
