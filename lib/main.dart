
import 'package:flutter/material.dart';
import 'login/login_screen.dart';


void main() {
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
        home: LoginScreen()
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
