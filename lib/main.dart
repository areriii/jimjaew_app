
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:jimjaew_app/home_screen/shop_home_screen.dart';
import 'package:jimjaew_app/home_screen/profile_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
        title: 'Jimjaew App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(

          scaffoldBackgroundColor: const Color(0xFFF9F9FB),

          primaryColor: const Color(0xFF5B9DDB),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B9DDB),
            primary: const Color(0xFF5B9DDB),
            secondary: const Color(0xFFD8ECFF),
          ),

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

  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const ShopHomeScreen(),

    const ProfileScreen(
      username: 'Guest User',
      email: 'guest@email.com',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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