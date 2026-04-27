import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/shop_home_screen.dart';
import 'firebase_options.dart';
import 'login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

 // 🔴 ต้องนำเข้าไฟล์นี้ด้วย

void main() async {
  // 1. ต้องมีบรรทัดนี้เป็นอันดับแรก เพื่อให้ Flutter เตรียมตัวให้พร้อม
  WidgetsFlutterBinding.ensureInitialized();

  // // 2. บรรทัดนี้คือการสตาร์ทเครื่อง Firebase (ที่ Error หน้าจอแดงมันถามหา)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. สั่งรันแอปพลิเคชัน (แก้ชื่อให้ตรงกับคลาสข้างล่าง)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.blue),
        ),
        debugShowCheckedModeBanner: false,
        home: ShopHomeScreen()
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.profileId});

  final String profileId;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // อัปเดตค่า Index และสั่งรีเฟรชหน้าจอ
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

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
