import 'package:flutter/material.dart';
import 'package:jimjaew_app/User/user_manager.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();  // ใช้เช็ค validation ของฟอร์ม
  // controller เอาไว้ดึงค่าที่ user พิมพ์
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userManager = UserManager();   // ตัวเรียก API

  // ใช้กับ FutureBuilder (เวลาโหลด)
  Future<void>? _registerResult;
  // ฟังก์ชันสมัคร
  Future<void> _register(
      String firstName,
      String lastName,
      String email,
      String password,
      ) async {
    // เรียก API
    final result = await _userManager.register(
      firstName,
      lastName,
      email,
      password,
    );
    if (!mounted) return;
    // สมัครสำเร็จ
    if (result != null && result.isSuccess) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Register Successful"),
          content: const Text("สมัครสมาชิกเรียบร้อยแล้ว"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Go to Login"),
            ),
          ],
        ),
      );
      // กลับไปหน้า login
      Navigator.of(context).pop();
    } else {
      // สมัครไม่สำเร็จ แจ้ง error
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Registration Failed"),
          content: Text(result?.message ?? "เกิดข้อผิดพลาด"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Dismiss"),
            ),
          ],
        ),
      );
    }
  }
  // ฟังก์ชันตกแต่งช่อง input
  InputDecoration customInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      // ไอคอนหน้าช่อง
      prefixIcon: Icon(icon, color: const Color(0xFF8D8D93)),
      // hint เช่น First name / email
      hintText: hintText,
      // style ตัวอักษร hint
      hintStyle: const TextStyle(
        color: Color(0xFF7C7C82),
        fontWeight: FontWeight.w600,
      ),
      // พื้นหลังช่อง
      filled: true,
      fillColor: const Color(0xFFE9E9EE),
      // padding ด้านใน
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      // ขอบโค้ง + ไม่มีเส้น
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
  // ปิด controller ตอน widget ถูกทำลาย (กัน memory leak)
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: _registerResult,
        builder: (context, snapshot) {
          // ตอนกำลังสมัคร หมุน loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                // ทำให้จัดกลางแนวตั้งได้
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, //  จัดกลางจอ
                      children: [
                        // First Name
                        TextFormField(
                          controller: _firstNameController,
                          decoration: customInputDecoration(
                            hintText: "First name",
                            icon: Icons.group,
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "กรุณากรอกชื่อ" : null,
                        ),
                        const SizedBox(height: 14),

                        // Last Name
                        TextFormField(
                          controller: _lastNameController,
                          decoration: customInputDecoration(
                            hintText: "Last name",
                            icon: Icons.group,
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "กรุณากรอกนามสกุล" : null,
                        ),
                        const SizedBox(height: 14),

                        // Username
                        TextFormField(
                          controller: _usernameController,
                          decoration: customInputDecoration(
                            hintText: "username",
                            icon: Icons.person,
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "กรุณากรอก username" : null,
                        ),
                        const SizedBox(height: 14),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: customInputDecoration(
                            hintText: "email",
                            icon: Icons.email,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return "กรุณากรอก email";
                            if (!value.contains("@")) return "email ไม่ถูกต้อง";
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true, // ซ่อนรหัส
                          decoration: customInputDecoration(
                            hintText: "password",
                            icon: Icons.lock,
                          ),
                          validator: (value) =>
                          value!.length < 6 ? "อย่างน้อย 6 ตัว" : null,
                        ),
                        const SizedBox(height: 14),

                        // ข้อความ Confirm
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Confirm your password",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6F6F75),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: customInputDecoration(
                            hintText: "password",
                            icon: Icons.lock,
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return "รหัสไม่ตรงกัน";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // ปุ่ม Register
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              // เช็คก่อนว่ากรอกครบมั้ย
                              if (_formKey.currentState!.validate()) {
                                // เรียกสมัคร
                                setState(() {
                                  _registerResult = _register(
                                    _firstNameController.text,
                                    _lastNameController.text,
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                });
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4D93CF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}