// หน้าสมัครสมาชิก
// หน้านี้ใช้สำหรับกรอกข้อมูลสมัครสมาชิก และเรียก API ผ่าน UserManager
// คอมเมนต์เป็นภาษาไทย ส่วนข้อความที่แสดงในแอปเป็นภาษาอังกฤษทั้งหมด

import 'package:flutter/material.dart';
import 'package:jimjaew_app/user/user_manager.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ใช้ตรวจสอบ validation ของฟอร์ม
  final _formKey = GlobalKey<FormState>();

  // Controller สำหรับดึงค่าที่ผู้ใช้กรอกในแต่ละช่อง
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ใช้เรียก API สมัครสมาชิก
  final UserManager _userManager = UserManager();

  // ใช้ควบคุมสถานะ loading ตอนกดปุ่ม Register
  bool _isLoading = false;

  // ฟังก์ชันสมัครสมาชิก
  Future<void> _register() async {
    // ถ้ากรอกข้อมูลไม่ครบ หรือ validation ไม่ผ่าน จะไม่ให้สมัคร
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // เรียก API สมัครสมาชิกผ่าน UserManager
      final result = await _userManager.register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      // กรณีสมัครสำเร็จ
      if (result != null && result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Register successful"),
            backgroundColor: Colors.green,
          ),
        );

        // ส่งค่า true กลับไปหน้า shop_home_screen.dart
        // เพื่อให้ระบบรู้ว่าสมัครสำเร็จแล้ว และเปิดหน้า Profile ต่อได้
        Navigator.pop(context, true);
      } else {
        // กรณีสมัครไม่สำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?.message ?? "Register failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // กรณีเกิด error จาก API หรือ internet
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // ไม่ว่าจะสำเร็จหรือ error ต้องหยุด loading เสมอ
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ฟังก์ชันตกแต่งช่องกรอกข้อมูล
  InputDecoration customInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      // ไอคอนด้านหน้าช่องกรอกข้อมูล
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF8D8D93),
      ),

      // ข้อความ hint ในช่องกรอกข้อมูล
      hintText: hintText,

      // รูปแบบข้อความ hint
      hintStyle: const TextStyle(
        color: Color(0xFF7C7C82),
        fontWeight: FontWeight.w600,
      ),

      // สีพื้นหลังช่องกรอกข้อมูล
      filled: true,
      fillColor: const Color(0xFFE9E9EE),

      // ระยะห่างด้านในช่องกรอกข้อมูล
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
      ),

      // ขอบช่องกรอกข้อมูลแบบโค้ง และไม่มีเส้นขอบ
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    // ปิด Controller เมื่อออกจากหน้านี้ เพื่อป้องกัน memory leak
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

      // AppBar ด้านบน มีปุ่มย้อนกลับ
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading
              ? null
              : () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      // เนื้อหาหลักของหน้าสมัครสมาชิก
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ช่องกรอกชื่อจริง
                    TextFormField(
                      controller: _firstNameController,
                      enabled: !_isLoading,
                      decoration: customInputDecoration(
                        hintText: "First name",
                        icon: Icons.group,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your first name";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ช่องกรอกนามสกุล
                    TextFormField(
                      controller: _lastNameController,
                      enabled: !_isLoading,
                      decoration: customInputDecoration(
                        hintText: "Last name",
                        icon: Icons.group,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your last name";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ช่องกรอก username
                    // ตอนนี้ API register ยังไม่ได้ส่ง username ไปด้วย
                    // แต่คงช่องนี้ไว้ตาม UI เดิม
                    TextFormField(
                      controller: _usernameController,
                      enabled: !_isLoading,
                      decoration: customInputDecoration(
                        hintText: "Username",
                        icon: Icons.person,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your username";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ช่องกรอก email
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      decoration: customInputDecoration(
                        hintText: "Email",
                        icon: Icons.email,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your email";
                        }

                        if (!value.contains("@")) {
                          return "Please enter a valid email";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ช่องกรอกรหัสผ่าน
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: true,
                      decoration: customInputDecoration(
                        hintText: "Password",
                        icon: Icons.lock,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }

                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ข้อความหัวข้อยืนยันรหัสผ่าน
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

                    // ช่องยืนยันรหัสผ่าน
                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !_isLoading,
                      obscureText: true,
                      decoration: customInputDecoration(
                        hintText: "Password",
                        icon: Icons.lock,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm your password";
                        }

                        if (value != _passwordController.text) {
                          return "Passwords do not match";
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
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D93CF),
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // ถ้ากำลังสมัคร ให้แสดง loading ในปุ่ม
                        // ถ้ายังไม่สมัคร ให้แสดงคำว่า Register
                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
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
      ),
    );
  }
}