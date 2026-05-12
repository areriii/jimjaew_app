// ไฟล์ main.dart
// ไฟล์นี้เป็นจุดเริ่มต้นของแอป
// ใช้สำหรับ initialize Firebase และเปิดหน้า ShopHomeScreen เป็นหน้าแรก

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'package:jimjaew_app/home_screen/shop_home_screen.dart';
import 'package:jimjaew_app/home_screen/profile_screen.dart';

void main() async {
  // ต้องเรียกบรรทัดนี้ก่อน initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้นการทำงานของ Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // เริ่มรันแอป
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget หลักของแอป
  @override
  Widget build(BuildContext context) {
    return // main.dart
      MaterialApp(
        title: 'Jimjaew App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 1. สีพื้นหลังของทุกหน้า
          scaffoldBackgroundColor: const Color(0xFFF9F9FB),

          // 2. สีหลักของปุ่มและไอคอนที่ถูกเลือก
          primaryColor: const Color(0xFF5B9DDB),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B9DDB),
            primary: const Color(0xFF5B9DDB),
            secondary: const Color(0xFFD8ECFF),
          ),

          // 3. ปรับแต่ง AppBar ให้ดูคลีน (ไม่มีเงา)
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF9F9FB),
            foregroundColor: Color(0xFF2D2D2D),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),

          // 4. ปรับแต่งดีไซน์ของปุ่ม ElevatedButton
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9DDB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: const ShopHomeScreen(),
      );
  }
}

// หน้าหลักแบบมี BottomNavigationBar
// ถ้ายังไม่ได้ใช้ สามารถปล่อยไว้ได้ แต่ต้องห้ามให้ _pages ว่าง
class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.profileId,
  });

  final String profileId;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // index ของเมนูด้านล่างที่เลือกอยู่
  int _selectedIndex = 0;

  // รายการหน้าที่จะแสดงใน BottomNavigationBar
  // ห้ามปล่อยให้ List นี้ว่าง เพราะจะทำให้เกิด RangeError
  late final List<Widget> _pages = [
    const ShopHomeScreen(),

    // หน้า Profile ตัวอย่าง
    // ถ้าภายหลังมีข้อมูลจาก Login จริง ค่อยส่ง username/email จริงเข้ามา
    const ProfileScreen(
      username: 'Guest User',
      email: 'guest@email.com',
    ),
  ];

  // ฟังก์ชันเปลี่ยนหน้าเมื่อกด BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // แสดงหน้าตาม index ที่เลือก
      body: _pages[_selectedIndex],

      // แถบเมนูด้านล่าง
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}