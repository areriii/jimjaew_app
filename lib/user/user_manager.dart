import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jimjaew_app/model/login_model.dart';
import 'package:jimjaew_app/model/register_model.dart';

class UserManager {
  static final UserManager _instance = UserManager._();
  factory UserManager() => _instance;
  UserManager._();

  String? profileId;
  String? currentEmail;
  String? currentFirstName;
  String? currentLastName;

  final String _baseUrl = 'https://cs356.azurewebsites.net/api';

  bool get isLoggedIn => (currentEmail != null && currentEmail!.isNotEmpty) || (profileId != null && profileId!.isNotEmpty);

  Future<void> logout() async {
    profileId = null;
    currentEmail = null;
    currentFirstName = null;
    currentLastName = null;
  }

  Future<LoginResponseModel?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/account/v1/login');
    try {
      final resp = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password})
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final result = LoginResponseModel.fromJson(jsonDecode(resp.body));
        if (result.isSuccess) {
          currentEmail = email; // [cite: 40]
          profileId = result.profileId; // [cite: 41]
        }
        return result;
      }
      return null;
    } catch (e) { return null; }
  }

  Future<RegisterModel?> register(String firstName, String lastName, String email, String password, String username) async {
    final url = Uri.parse('$_baseUrl/account/v1/register');

    try {
      final resp = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'password': password,
            'studentId': username,
            'username': username
          })
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final result = RegisterModel.fromJson(jsonDecode(resp.body));

        currentEmail = email;
        currentFirstName = firstName;
        currentLastName = lastName;

        return result;
      } else {
        print("❌ Server Error: ${resp.body}");
        return null;
      }
    } catch (e) {
      print("❌ App Error: $e");
      return null;
    }
  }
}