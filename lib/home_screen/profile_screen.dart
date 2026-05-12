// หน้าบัญชีผู้ใช้ (ProfileScreen) - ฉบับรวม Logic ระบบ Login และดีไซน์ Bright Blue
import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/help_center_screen.dart';
import 'package:jimjaew_app/home_screen/order_screen.dart';
import 'package:jimjaew_app/home_screen/seller_order_screen.dart';
import 'package:jimjaew_app/home_screen/trade_system_screen.dart';
import 'package:jimjaew_app/home_screen/referral_screen.dart';
import 'package:jimjaew_app/home_screen/shop_screen.dart';
import 'package:jimjaew_app/home_screen/income_screen.dart';
import 'package:jimjaew_app/home_screen/follow_manager.dart';
import 'package:jimjaew_app/home_screen/shop_home_screen.dart';
import 'package:jimjaew_app/user/user_manager.dart';

class ProfileScreen extends StatelessWidget {
  final String? username;
  final String? email;

  const ProfileScreen({
    super.key,
    this.username,
    this.email,
  });

  // 🌟 กำหนดสีหลักเพื่อให้คุมโทน Bright Blue ทั้งแอป
  final Color primaryBlue = const Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // พื้นหลังเทาจางๆ เพื่อให้ Card เมนูสีขาวดูเด่นขึ้น
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 10),
            _buildMenuItems(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // ส่วนหัวของหน้า Profile แบบ Gradient พร้อมดึงข้อมูลจาก UserManager [cite: 5, 292]
  Widget _buildProfileHeader(BuildContext context) {
    final userManager = UserManager();

    // ดึง Email: ใช้ค่าที่ส่งเข้ามาก่อน ถ้าไม่มีให้ใช้จาก UserManager [cite: 5, 288, 289]
    final String displayEmail = (email != null && email!.isNotEmpty)
        ? email!
        : (userManager.currentEmail ?? 'No email');

    // ดึงชื่อ: ใช้ค่าที่ส่งเข้ามาก่อน ถ้าไม่มีให้รวมชื่อจาก UserManager [cite: 5, 290]
    final String displayName = (username != null && username!.isNotEmpty)
        ? username!
        : [userManager.currentFirstName, userManager.currentLastName]
        .where((item) => item != null && item!.isNotEmpty)
        .join(' ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 35),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, const Color(0xFF03A9F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // กลับหน้า Home โดยตรวจสอบ back stack [cite: 293, 294, 295]
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ShopHomeScreen()),
                    );
                  }
                },
              ),
              const Text("My Profile", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // รูปโปรไฟล์แบบ CircleAvatar [cite: 297, 298]
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF2196F3), size: 45),
                ),
              ),
              const SizedBox(width: 20),
              // ข้อมูลชื่อและอีเมล [cite: 303, 304]
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isNotEmpty ? displayName : "User Name",
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // ส่วนแสดงสถิติ Followers / Following [cite: 305, 306, 312, 313]
                    Row(
                      children: [
                        _buildStatColumn("0", "Followers"),
                        const SizedBox(width: 25),
                        ValueListenableBuilder<int>(
                          valueListenable: FollowManager.followingCount,
                          builder: (context, value, child) => _buildStatColumn(value.toString(), "Following"),
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

  Widget _buildStatColumn(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // กล่องเมนูหลักแบบการ์ดโค้งมน [cite: 322]
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                _buildListTile(Icons.storefront, 'Your Store', primaryBlue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShopScreen()))),
                _buildDivider(),
                _buildListTile(Icons.assignment_outlined, 'My Orders', primaryBlue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderScreen()))),
                _buildDivider(),
                _buildListTile(Icons.swap_calls, 'Trade System', primaryBlue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TradeSystemScreen()))),
                _buildDivider(),
                _buildListTile(Icons.people_outline, 'Refer a Friend', primaryBlue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralScreen()))),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // เมนู Help Center [cite: 334]
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: _buildListTile(Icons.help_outline, 'Help Center', primaryBlue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()))),
          ),
          const SizedBox(height: 30),
          // ปุ่ม Log Out [cite: 339, 341]
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              onPressed: () => _showLogoutDialog(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => const Divider(height: 1, thickness: 0.5, indent: 55, endIndent: 20, color: Color(0xFFEEEEEE));

  // แถบเมนูด้านล่างพร้อม Logic การนำทาง [cite: 346, 347, 348, 349, 350]
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      currentIndex: 3,
      onTap: (index) {
        if (index == 0) {
          // ปลอดภัยกว่าด้วยการเช็ก back stack
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ShopHomeScreen()));
          }
        }
        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => SellerOrderScreen()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => IncomeScreen()));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Offers'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Customer Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on_outlined), label: 'Earnings'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }

  // Dialog ยืนยันการออกจากระบบพร้อมสั่งงาน UserManager [cite: 354, 356, 357, 358]
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // ปิด Dialog
              await UserManager().logout(); // เคลียร์ข้อมูล Singleton [cite: 8, 9, 356]
              if (context.mounted) {
                // กลับไปหน้า Home และล้าง stack ทั้งหมด [cite: 358]
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const ShopHomeScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}