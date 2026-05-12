import 'package:flutter/material.dart';
import 'package:jimjaew_app/user/user_manager.dart';
import 'package:jimjaew_app/components/app_logo.dart';
import 'package:jimjaew_app/register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userManager = UserManager();
  Future<void>? _loginResult;

  // ฟังก์ชันล็อกอิน
  Future<void> _login(String email, String password) async {
    final result = await _userManager.login(email, password);
    if (!mounted) return;

    if (result != null && result.isSuccess) {
      // ส่งค่า true กลับไปบอกหน้า Home ว่าล็อกอินสำเร็จแล้ว
      Navigator.pop(context, true);
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Authentication Failed"),
          content: Text(result?.message ?? "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้"),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ดีไซน์ช่องกรอกข้อมูล
  InputDecoration customInputDecoration({required String hintText, required IconData icon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack( // 🌟 ใช้ Stack เพื่อวางปุ่มย้อนกลับทับบนพื้นหลัง
        children: [
          FutureBuilder(
            future: _loginResult,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
              }

              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          // โลโก้แอป ReWear
                          const Center(child: AppLogo(width: 280, height: 280)),
                          const SizedBox(height: 20),

                          // ช่อง Email
                          TextFormField(
                            controller: _emailController,
                            decoration: customInputDecoration(hintText: "Email", icon: Icons.email_outlined),
                            validator: (v) => (v == null || v.isEmpty) ? "กรุณากรอกอีเมล" : null,
                          ),
                          const SizedBox(height: 20),

                          // ช่อง Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: customInputDecoration(hintText: "Password", icon: Icons.lock_outline),
                            validator: (v) => (v == null || v.isEmpty) ? "กรุณากรอกรหัสผ่าน" : null,
                          ),
                          const SizedBox(height: 35),

                          // ปุ่ม Login สีฟ้าสด
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _loginResult = _login(_emailController.text.trim(), _passwordController.text.trim());
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                              child: const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),

                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen())),
                            child: const Text("Don't have an account? Register", style: TextStyle(color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 🌟 1. ส่วนของปุ่มย้อนกลับ (Back Button)
          Positioned(
            top: 40,
            left: 15,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    // 🌟 2. คำสั่งย้อนกลับไปหน้าโฮม
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}