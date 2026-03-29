import 'package:flutter/material.dart';
import 'package:jimjaew_app/User/user_manager.dart';
import 'package:jimjaew_app/main.dart';
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

  Future<void> _login(String email, String password) async {
    final result = await _userManager.login(email, password);

    if (!mounted) return;

    if (result!= null && result.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainScreen(profileId: result.profileId ?? ''),
        ),
      );
    } else {
      // Notify the user of the authentication error via a dialog.
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Authentication Failed"),
          content: Text(result?.message ??"ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาลองใหม่"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Dismiss"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(        // หน้าจอ UI
        future: _loginResult,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16,),
                Text("Logging In"),
              ],
            ),);
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          return Form(
            key: _formKey,
            child: Stack(
              children: [
                Container(  // ไล่สี
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigo,
                        Colors.blue.withValues(alpha: 1.0),
                        Colors.indigo.shade800,
                      ],
                      begin: AlignmentGeometry.topLeft,
                      end: AlignmentGeometry.bottomRight,
                      stops: [0.0, 0.3, 0.9],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AppLogo(), // โลโก้
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                "Login",
                                style: TextTheme.of(
                                  context,
                                ).titleLarge?.copyWith(color: Colors.grey.shade800),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(  //นี่คือช่องกรอกอีเมล มันผูกกับ _emailController
                              controller: _emailController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(2),
                                hint: Text("Email Address"),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required.";
                                }

                                if (!value.contains("@")) {
                                  return "Please recheck your email address.";
                                }

                                return null;
                              },
                              autofocus: true,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(2),
                                hint: Text("Password"),
                              ),
                              obscureText: true,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required.";
                                }

                                return null;
                              },
                              autofocus: true,
                            ),
                            SizedBox(height: 20),
                            FilledButton.icon( //validate() สั่งเช็คว่าอีเมลและรหัสผ่านกรอกถูกต้องตามเงื่อนไขไหม
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {

                                  // Execute login logic and update the UI state.
                                  setState(() {
                                    _loginResult = _login(_emailController.text,
                                        _passwordController.text);
                                  });

                                }
                              },
                              label: Text("Login"),
                              icon: Icon(Icons.login),
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => RegisterScreen(),
                                  ),
                                );
                              },
                              child: Center(child: Text("Register an account")),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Developed by ", style: TextStyle(color: Colors.white38, fontSize: 10),),
                    )),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
