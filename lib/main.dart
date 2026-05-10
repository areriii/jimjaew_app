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
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ตั้งค่า Theme หลักของแอป
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      // หน้าแรกของแอป
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