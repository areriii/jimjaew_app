import 'package:flutter/material.dart';
import 'package:jimjaew_app/user/user_manager.dart';
import 'package:jimjaew_app/login/login_screen.dart'; // เช็คที่อยู่โฟลเดอร์ให้ตรงกับของคุณด้วยนะครับ

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController(); // 🌟 เปลี่ยนกลับมาเป็นตัวแปร Username
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final UserManager _userManager = UserManager();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 🌟 ส่งค่า Username ไปให้ UserManager จัดการ
      final result = await _userManager.register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );

      if (!mounted) return;

      if (result != null && result.isSuccess) {
        // 🌟 แก้ข้อความให้รู้ว่าต้องล็อคอินต่อ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Register successful. Please login."), backgroundColor: Colors.green),
        );

        // 🌟 แก้ตรงนี้! เตะไปหน้า Login ทันทีที่สมัครเสร็จ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result?.message ?? "Register failed"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration customInputDecoration({required String hintText, required IconData icon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF8D8D93)),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF7C7C82), fontWeight: FontWeight.w600),
      filled: true,
      fillColor: const Color(0xFFE9E9EE),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

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
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    enabled: !_isLoading,
                    decoration: customInputDecoration(hintText: "First name", icon: Icons.group),
                    validator: (value) => value == null || value.trim().isEmpty ? "Please enter your first name" : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _lastNameController,
                    enabled: !_isLoading,
                    decoration: customInputDecoration(hintText: "Last name", icon: Icons.group),
                    validator: (value) => value == null || value.trim().isEmpty ? "Please enter your last name" : null,
                  ),
                  const SizedBox(height: 14),
                  // 🌟 เปลี่ยน UI กลับมาโชว์คำว่า Username ให้ผู้ใช้เห็น
                  TextFormField(
                    controller: _usernameController,
                    enabled: !_isLoading,
                    decoration: customInputDecoration(hintText: "Username", icon: Icons.person),
                    validator: (value) => value == null || value.trim().isEmpty ? "Please enter your username" : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: customInputDecoration(hintText: "Email", icon: Icons.email),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Please enter your email";
                      if (!value.contains("@")) return "Please enter a valid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isLoading,
                    obscureText: true,
                    decoration: customInputDecoration(hintText: "Password", icon: Icons.lock),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter your password";
                      if (value.length < 6) return "Password must be at least 6 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Confirm your password", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6F6F75))),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    enabled: !_isLoading,
                    obscureText: true,
                    decoration: customInputDecoration(hintText: "Password", icon: Icons.lock),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please confirm your password";
                      if (value != _passwordController.text) return "Passwords do not match";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D93CF),
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}