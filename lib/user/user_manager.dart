// จัดการข้อมูลผู้ใช้
// ไฟล์นี้ใช้สำหรับเรียก API Register, Login, Logout และเก็บข้อมูลผู้ใช้ที่กำลังใช้งานอยู่
// สำคัญมาก: ทุกไฟล์ต้อง import เป็น package:jimjaew_app/user/user_manager.dart เท่านั้น
// ห้ามใช้ package:jimjaew_app/User/user_manager.dart เพราะจะทำให้ Singleton กลายเป็นคนละตัว

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jimjaew_app/model/register_model.dart';
import 'package:jimjaew_app/model/login_model.dart';
import 'package:jimjaew_app/model/profile_models.dart';

class UserManager {
  // สร้าง Singleton เพื่อให้ทั้งแอปใช้ UserManager ตัวเดียวกัน
  static final UserManager _instance = UserManager._();

  factory UserManager() {
    return _instance;
  }

  UserManager._();

  // ใช้เก็บ profileId หลัง Login สำเร็จ
  String? profileId;

  // ใช้เก็บ email ของผู้ใช้ที่ Login/Register สำเร็จ
  String? currentEmail;

  // ใช้เก็บชื่อผู้ใช้
  String? currentFirstName;
  String? currentLastName;

  // URL หลักของ API
  final String _baseUrl = 'https://cs356.azurewebsites.net/api';

  // เช็กว่าผู้ใช้ Login อยู่หรือไม่
  bool get isLoggedIn {
    return (currentEmail != null && currentEmail!.isNotEmpty) ||
        (profileId != null && profileId!.isNotEmpty);
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> logout() async {
    profileId = null;
    currentEmail = null;
    currentFirstName = null;
    currentLastName = null;
  }

  // ฟังก์ชันดึงข้อมูล Profile จาก Email
  Future<ProfileResponse?> getProfileByEmail(String email) async {
    try {
      final uri = Uri.parse('$_baseUrl/account/v1/profile').replace(
        queryParameters: {
          'email': email,
        },
      );

      final resp = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (resp.statusCode != 200) {
        return null;
      }

      if (resp.body.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(resp.body);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return ProfileResponse.fromJson(decoded);
    } on Exception catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // ฟังก์ชันสมัครสมาชิกf
  Future<RegisterResponse?> register(
      String firstName,
      String lastName,
      String email,
      String password,
      ) async {
    final url = Uri.parse('$_baseUrl/account/v1/register');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };

    try {
      final resp = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (resp.body.isEmpty) {
        return RegisterResponse(
          isSuccess: false,
          message: 'Empty response from server',
        );
      }

      final decoded = jsonDecode(resp.body);

      if (decoded is! Map<String, dynamic>) {
        return RegisterResponse(
          isSuccess: false,
          message: 'Invalid server response',
        );
      }

      final result = RegisterResponse.fromJson(decoded);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // เก็บข้อมูลผู้ใช้ที่สมัครสำเร็จ
        currentEmail = email;
        currentFirstName = firstName;
        currentLastName = lastName;

        print('REGISTER CURRENT EMAIL: $currentEmail');
        print('REGISTER PROFILE ID: $profileId');

        return RegisterResponse(
          isSuccess: true,
          message: result.message,
        );
      }

      return RegisterResponse(
        isSuccess: false,
        message: result.message,
      );
    } on Exception catch (e) {
      return RegisterResponse(
        isSuccess: false,
        message: 'Connection Error\n${e.toString()}',
      );
    }
  }

  // ฟังก์ชันเข้าสู่ระบบ
  Future<LoginResponseModel?> login(
      String email,
      String password,
      ) async {
    final url = Uri.parse('$_baseUrl/account/v1/login');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = {
      'email': email,
      'password': password,
    };

    try {
      final resp = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (resp.body.isEmpty) {
        return LoginResponseModel(
          isSuccess: false,
          profileId: '',
          message: 'Empty response from server',
        );
      }

      if (resp.statusCode != 200) {
        return LoginResponseModel(
          isSuccess: false,
          profileId: '',
          message: 'Login failed',
        );
      }

      final decoded = jsonDecode(resp.body);

      if (decoded is! Map<String, dynamic>) {
        return LoginResponseModel(
          isSuccess: false,
          profileId: '',
          message: 'Invalid server response',
        );
      }

      final result = LoginResponseModel.fromJson(decoded);

      if (result.isSuccess) {
        // สำคัญมาก: เก็บ email ทันทีหลัง Login สำเร็จ
        currentEmail = email;

        // ถ้า API มี profileId ให้เก็บไว้ด้วย
        profileId = result.profileId;

        // ถ้า API ไม่ส่งชื่อมา ตอนนี้ยังไม่ใส่ค่าปลอม
        currentFirstName ??= '';
        currentLastName ??= '';
      }

      print('LOGIN CURRENT EMAIL: $currentEmail');
      print('LOGIN PROFILE ID: $profileId');

      return result;
    } on Exception catch (e) {
      return LoginResponseModel(
        isSuccess: false,
        profileId: '',
        message: 'Connection Error\n${e.toString()}',
      );
    }
  }
}