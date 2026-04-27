import 'package:flutter/material.dart';
import 'package:jimjaew_app/User/user_manager.dart';
import 'package:jimjaew_app/components/app_logo.dart';
import 'package:jimjaew_app/main.dart';
import 'package:jimjaew_app/register/register_screen.dart';

class LoginScreen extends StatefulWidget {  //ทำไมใช้ StatefulWidget: เพราะหน้าจอนี้ "มีการเปลี่ยนแปลง" (Dynamic) ครับ เช่น ตอนผู้ใช้กดปุ่ม หน้าจอต้องเปลี่ยนจากฟอร์มกรอกข้อมูล กลายเป็นโชว์ไอคอนกำลังโหลดหมุนๆ (CircularProgressIndicator) ถ้าใช้ StatelessWidget มันจะเปลี่ยนหน้าตาแบบนี้ไม่ได้ครับ
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();   // key เอาไว้เช็ค validation ของฟอร์ม
  // controller เอาไว้ดึงค่าที่ user พิมพ์
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userManager = UserManager();  // ตัวเรียก API login

  Future<void>? _loginResult;

  Future<void> _login(String email, String password) async {
    // ยิง API
    final result = await _userManager.login(email, password);
    if (!mounted) return;
    // ถ้าล็อกอินสำเร็จ ไปหน้า main
    if (result != null && result.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(profileId: result.profileId ?? ''),
        ),
      );
    } else {
      // ถ้าล้มเหลว โชว์ dialog แจ้ง error
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Authentication Failed"),
          content: Text(
            result?.message ?? "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาลองใหม่",
          ),
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
  // ปิด controller กัน memory leak
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //  ฟังก์ชันตกแต่งช่อง input
  InputDecoration customInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      // ไอคอนหน้าช่อง
      prefixIcon: Icon(icon, color: Colors.grey),
      // hint  username / password
      hintText: hintText,
      // style hint
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      ),
      // พื้นหลังช่อง
      filled: true,
      fillColor: const Color(0xFFE9E9EE),
      // padding ในช่อง
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      // ขอบโค้ง ไม่มีเส้น
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      // ตอน focus
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.2),
      ),
      // ตอน error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: FutureBuilder(  //ว่าตอนนี้สถานะคือ waiting (รอ) หรือเสร็จแล้ว ทำให้เราโชว์วงกลมโหลดรอ (CircularProgressIndicator)
        future: _loginResult,
        builder: (context, snapshot) {
          // ถ้ากำลัง login แสดง loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Logging In"),
                ],
              ),
            );
          }
          // ถ้ามี error
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          return SafeArea(
            child: SingleChildScrollView( //คือ "Bottom Overflowed" (แถบสีเหลืองดำคาดหน้าจอ) เวลาผู้ใช้กดพิมพ์ข้อความแล้ว "คีย์บอร์ดมือถือเด้งขึ้นมาบังจอ"
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Form( //เป็นการเอาเครื่องข่าย (Form) ไปคลุมกล่องข้อความไว้ เพื่อให้มันทำงานร่วมกับ _formKey ที่เราสร้างไว้ข้างบนได้
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 70),
                        //  โลโก้
                        Center(
                          child: AppLogo(width: 350, height: 300),
                        ),
                        const SizedBox(height: 20),

                        // ช่อง username (email)
                        TextFormField(
                          controller: _emailController,
                          decoration: customInputDecoration(
                            hintText: "username",
                            icon: Icons.group,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          // validation
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "กรุณากรอกอีเมล";
                            }
                            if (!value.contains("@")) {
                              return "กรุณากรอกอีเมลให้ถูกต้อง";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 35),

                        // ช่อง password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true, // ซ่อนรหัส  จุดกลมๆ
                          decoration: customInputDecoration(
                            hintText: "password",
                            icon: Icons.lock,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "กรุณากรอกรหัสผ่าน";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 35),

                        // ปุ่ม Login
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              // เช็คก่อนว่ากรอกครบมั้ย
                              if (_formKey.currentState!.validate()) {
                                // เรียก login
                                setState(() { //setState คือการตะโกนบอกแอปว่า "ข้อมูลเปลี่ยนแล้วนะ วาดหน้าจอใหม่เดี๋ยวนี้!"
                                  _loginResult = _login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                });
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4D93CF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ปุ่มไปหน้า Register
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Create an account",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        const Spacer(),
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