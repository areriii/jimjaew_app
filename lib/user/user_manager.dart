import 'dart:async';
import "package:http/http.dart" as http;
import 'package:jimjaew_app/model/register_model.dart';
import 'dart:convert';
import '../model/login_model.dart';
import '../model/profile_models.dart';

class UserManager {
  static final UserManager _instance = UserManager._();
  factory  UserManager() {
    return _instance;
  }
  UserManager._();

  String? profileId ;

  final String _baseUrl = 'https://cs356.azurewebsites.net/api';

  Future<void> logout() async{
    profileId = null;
  }

  Future<ProfileResponse?> getProfileByEmail(String email) async {
    try{
       final url = "$_baseUrl/account/v1/profile?email=$email";

       final resp = await http.get(Uri.parse(url)).timeout(
         const Duration(seconds: 10),
         onTimeout: () => throw TimeoutException('Connection timed out')
       );

       if(resp.statusCode != 200) return null;
       return ProfileResponse.fromJson(jsonDecode(resp.body));

       final json = jsonDecode(resp.body);
       return ProfileResponse.fromJson(json);
    }on Exception catch (e) {
      print("Error fetching profile : $e");
      return null;
    }
  }
  Future<RegisterResponse?> register(
      String firstName,
      String lastName,
      String email,
      String password
    ) async {
    final url = '$_baseUrl/account/v1/register';
    final headers = {'Content-Type': 'application/json'};
    final body = {
      // "studentId": studentId,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
    };

    try {
      final resp = await http.post(Uri.parse(url),
          headers: headers,
          body: jsonEncode(body))
          .timeout(const Duration(seconds: 10)
      );
      final result = RegisterResponse.fromJson(jsonDecode(resp.body));

      if (resp.statusCode != 201) {
        return RegisterResponse(
          isSuccess: false,
          message: 'Error : ${result.message}'
        );
      }
      return result;

    } on Exception catch (ex) {
      return RegisterResponse(
        isSuccess: false,
        message: 'Connection Error\n${ex.toString()}'
      );
    }
  }

  Future<LoginResponseModel?> login(String email, String password) async {

    final url = '$_baseUrl/account/v1/login';
    final headers = {
      'Content-Type': 'application/json', // [cite: 221, 222]
    };

    final body = {
      "email": email,
      "password": password,
    };

    try {
      final resp = await http.post(Uri.parse(url),
        headers: headers,
        body: jsonEncode(body))
          .timeout(const Duration(seconds: 10)
      );

      if (resp.statusCode != 200) {
        return LoginResponseModel(
          isSuccess: false, profileId: '',
          message: 'login failed '
        );
      }

      final result = LoginResponseModel.fromJson(jsonDecode(resp.body));
      profileId = result.profileId;

      return result;

    } on Exception catch (e) {
      return LoginResponseModel(
          isSuccess: false,
          profileId: '',
          message: "Connection Error\n${e.toString()}"
      );
    }
  }

}

