//หน้า บัญชี ผู้ใช้

import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/help_center_screen.dart';
import 'package:jimjaew_app/home_screen/order_screen.dart';
import 'package:jimjaew_app/home_screen/trade_system_screen.dart';
import 'package:jimjaew_app/home_screen/referral_screen.dart';
import 'package:jimjaew_app/home_screen/shop_screen.dart';
import 'package:jimjaew_app/home_screen/income_screen.dart';
import 'package:jimjaew_app/home_screen/follow_manager.dart';
import 'package:jimjaew_app/home_screen/seller_order_screen.dart';
import 'package:jimjaew_app/home_screen/shop_home_screen.dart'; // เช็ค path ให้ตรงกับโฟลเดอร์ของคุณนะครับ

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Ari',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      // 🔴 จุดที่แก้ 1: ส่งค่าจำลองเข้าไป (เมื่อทำระบบ Login จริง ค่อยส่งค่าจากหน้า Login มาแทนครับ)
      home: const ProfileScreen(
        username: 'Ari Natthanan',
        email: 'ari@email.com',
      ),
    );
  }
}

// หน้า Profile (โปรไฟล์ผู้ใช้)
class ProfileScreen extends StatelessWidget {
  // 🔴 จุดที่แก้ 2: ประกาศตัวแปรรับค่าจาก Constructor
  final String username;
  final String email;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildAlertBanner(),
            _buildMenuItems(context), // 🔴 ส่ง context เข้าไปเพื่อให้ปุ่ม Logout เรียก Pop-up ได้
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // 1. ส่วน Header แบบกำหนดเอง
  // 🌟 ฟังก์ชันสำหรับวาดส่วนหัวโปรไฟล์ (รูปภาพ + อีเมล + ยอดผู้ติดตาม)
  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.blue, // สีพื้นหลัง หรือถ้าใช้ Gradient ก็เปลี่ยนตรงนี้ได้ครับ
      ),
      child: Column(
        children: [
          // แถวบนสุด (ปุ่ม Back + รูปเฟืองตั้งค่า)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ShopHomeScreen()), // ตรงนี้ใส่ชื่อคลาสหน้าแรกของคุณ
                        (route) => false,
                  );
                }, // ใส่ Navigator.pop(context) ถ้าต้องการให้กดย้อนกลับได้
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // แถวที่สอง (รูปโปรไฟล์ + ข้อมูล)
          Row(
            children: [
              // รูปโปรไฟล์
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'), // รูปจำลอง
              ),
              const SizedBox(width: 20), // ระยะห่าง

              // ข้อมูลด้านขวา
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // อีเมล หรือ ชื่อ
                    const Text(
                      "อีเมล: user@example.com",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12), // ระยะห่างระหว่างชื่อกับสถิติ

                    // 🌟 ส่วนที่เพิ่มใหม่: สถิติผู้ติดตาม
                    Row(
                      children: [
                        // กล่องที่ 1: ผู้ติดตาม
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "1,250", // ตัวเลขจำลอง
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              "ผู้ติดตาม",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24), // ระยะห่างระหว่าง 2 กล่อง

                        // กล่องที่ 2: กำลังติดตาม
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🌟 ใช้ ValueListenableBuilder มาครอบตัวเลขไว้
                            // เพื่อให้มันคอยจ้องมองว่า FollowManager.followingCount เปลี่ยนหรือยัง
                            ValueListenableBuilder<int>(
                              valueListenable: FollowManager.followingCount,
                              builder: (context, value, child) {
                                return Text(
                                  value.toString(), // โชว์ตัวเลขล่าสุด
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                );
                              },
                            ),
                            const Text(
                              "กำลังติดตาม",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // 2. แถบแจ้งเตือน
  Widget _buildAlertBanner() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.edit_document, color: Color(0xFF4D93CF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                children: [
                  TextSpan(text: 'กรุณายืนยันบัญชีโซเชียลมีเดียของคุณเพื่อแบ่งปันสินค้าของคุณกับผู้ที่เข้ามาชม '),
                  TextSpan(
                    text: 'ยืนยันเลย',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.close, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  // 3. รายการเมนูภายในกล่องสีขาว (Card)
  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              // 🔴 เพิ่มฟังก์ชันเปลี่ยนหน้าเข้าไปตรงนี้
              _buildListTile(Icons.storefront, 'หน้าร้านของคุณ', const Color(0xFF4D93CF), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ShopScreen()),
                );
              }),
              _buildDivider(),
              // หน้าคำสั่งซื้อ (สมมติว่าสร้างไฟล์ OrderScreen ไว้แล้ว)
              _buildListTile(Icons.assignment_outlined, 'คำสั่งซื้อของฉัน', const Color(0xFF4D93CF),(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>   OrderScreen()),
                );
              }),
              _buildDivider(),
              _buildListTile(Icons.swap_calls, 'ระบบการเทรดสินค้า', const Color(0xFF4D93CF), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TradeSystemScreen()),
                );
              }),
              _buildDivider(),
              _buildListTile(Icons.people_outline, 'แนะนำเพื่อน', const Color(0xFF4D93CF), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReferralScreen()));
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.help_outline, color: Colors.blue),
          title: const Text('ศูนย์ช่วยเหลือ'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 🌟 สั่งให้กระโดดไปหน้าศูนย์ช่วยเหลือ
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
            );
          },
        ),
        const SizedBox(height: 30),

        // 🔴 จุดที่แก้ 5: เพิ่มปุ่ม Logout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Widget ช่วยสร้างแต่ละแถวของเมนู  // 🔴 อัปเกรดให้รับฟังก์ชัน onTap เข้ามาด้วย
  Widget _buildListTile(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap, //🔴 เอาค่าที่รับมา ไปใส่ใน onTap ของ ListTile
    );
  }

  // เส้นคั่นระหว่างเมนู
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 50, color: Color(0xFFEEEEEE));
  }

  // 4. แถบเมนูด้านล่าง
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4D93CF),
      unselectedItemColor: Colors.grey,
      currentIndex: 3,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (int index) {
        // 🌟 ถ้ากดปุ่มที่ 2 (Index 1 คือ "คำสั่งซื้อ")
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SellerOrderScreen()), // วิ่งไปหน้าคำสั่งซื้อจากลูกค้า
          );
        }
        // 🌟 ถ้ากดปุ่มที่ 3 (Index 2 คือ "รายได้" - อันนี้ของเดิมที่เราทำไว้)
        else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IncomeScreen()),
          );
        }
      },
      // 🌟 ...ถึงตรงนี้ครับ
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'ข้อเสนอ'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'คำสั่งซื้อ'),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on_outlined), label: 'รายได้'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'บัญชีผู้ใช้'),
      ],
    );
  }

  // 🔴 จุดที่แก้ 6: เพิ่มฟังก์ชัน Pop-up ยืนยันการออกจากระบบ
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('ออกจากระบบ'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด Pop-up
              },
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // ใส่ Logic เคลียร์ข้อมูลการล็อกอินตรงนี้
                // Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}