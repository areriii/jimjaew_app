// หน้า บัญชีผู้ใช้
// หน้านี้ใช้สำหรับแสดงข้อมูลบัญชีผู้ใช้ เมนูร้านค้า เมนูคำสั่งซื้อ ระบบเทรด แนะนำเพื่อน ศูนย์ช่วยเหลือ และออกจากระบบ
// ข้อมูล Email จะดึงจาก UserManager ซึ่งมาจากผู้ใช้ที่ Login หรือ Register จริง
// คอมเมนต์เป็นภาษาไทย ส่วนข้อความที่แสดงในแอปเป็นภาษาอังกฤษทั้งหมด

import 'package:flutter/material.dart';

import 'package:jimjaew_app/home_screen/help_center_screen.dart';
import 'package:jimjaew_app/home_screen/order_screen.dart';
import 'package:jimjaew_app/home_screen/trade_system_screen.dart';
import 'package:jimjaew_app/home_screen/referral_screen.dart';
import 'package:jimjaew_app/home_screen/shop_screen.dart';
import 'package:jimjaew_app/home_screen/income_screen.dart';
import 'package:jimjaew_app/home_screen/follow_manager.dart';
import 'package:jimjaew_app/home_screen/shop_home_screen.dart';
import 'package:jimjaew_app/user/user_manager.dart';

class ProfileScreen extends StatelessWidget {
  // รับค่า username และ email ได้ เผื่อหน้าอื่นส่งข้อมูลเข้ามา
  // ถ้าไม่ได้ส่งมา จะใช้ค่าจาก UserManager แทน
  final String? username;
  final String? email;

  const ProfileScreen({
    super.key,
    this.username,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // ใช้ SingleChildScrollView เพื่อให้เลื่อนได้ ถ้าหน้าจอเล็กหรือข้อมูลยาวเกิน
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),

            // เอาแถบ Please verify ออกแล้ว เพราะระบบนี้ยังไม่จำเป็นและทำยากเกินขอบเขตงานตอนนี้
            _buildMenuItems(context),
          ],
        ),
      ),

      // แถบเมนูด้านล่างของหน้า Account
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // ส่วนหัวของหน้า Profile
  // แสดงปุ่มย้อนกลับ รูปโปรไฟล์ อีเมล และจำนวน Followers / Following
  Widget _buildProfileHeader(BuildContext context) {
    final userManager = UserManager();

    // ใช้ email ที่ส่งเข้ามาก่อน ถ้าไม่มีให้ใช้ email ที่เก็บไว้ใน UserManager
    final String displayEmail =
    (email != null && email!.isNotEmpty)
        ? email!
        : (userManager.currentEmail ?? 'No email');

    // ใช้ชื่อที่ส่งเข้ามาก่อน ถ้าไม่มีให้รวมชื่อจริงกับนามสกุลจาก UserManager
    final String displayName =
    (username != null && username!.isNotEmpty)
        ? username!
        : [
      userManager.currentFirstName,
      userManager.currentLastName,
    ].where((item) => item != null && item!.isNotEmpty).join(' ');

    // ยังไม่มี API สำหรับ Followers จริง จึงให้เป็น 0 แทน ไม่ใช้ค่าปลอม
    const int followerCount = 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Column(
        children: [
          // แถวบนสุด มีปุ่มย้อนกลับ และเว้นพื้นที่ฝั่งขวาแทนปุ่มตั้งค่า
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // สำคัญมาก:
              // ใช้ Navigator.pop(context) เพื่อกลับไปหน้า Home เดิม
              // ห้ามใช้ pushAndRemoveUntil เพราะจะสร้าง Home ใหม่และทำให้สถานะ Login รีเซ็ต
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              // เอาปุ่มตั้งค่าออก เพราะยังไม่มีระบบ Settings
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 8),

          // แถวข้อมูลโปรไฟล์
          Row(
            children: [
              // รูปโปรไฟล์
              // ตอนนี้ยังไม่มี API รูปจริง จึงใช้ icon profile แทน ไม่ใช้รูปปลอม
              const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFD8ECFF),
                child: Icon(
                  Icons.person,
                  color: Color(0xFF4D93CF),
                  size: 48,
                ),
              ),

              const SizedBox(width: 20),

              // ข้อมูลด้านขวาของรูปโปรไฟล์
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // แสดงชื่อผู้ใช้ ถ้ามีข้อมูล
                    if (displayName.isNotEmpty) ...[
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                    ],

                    // แสดง email จาก API/Login/Register จริง
                    Text(
                      "Email: $displayEmail",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 14),

                    // ส่วนแสดง Followers / Following
                    Row(
                      children: [
                        // Followers ใช้ 0 เพราะยังไม่มี API จริง
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$followerCount",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              "Followers",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 32),

                        // Following ใช้ค่าจริงจาก FollowManager
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder<int>(
                              valueListenable: FollowManager.followingCount,
                              builder: (context, value, child) {
                                return Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                );
                              },
                            ),
                            const Text(
                              "Following",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
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

  // รายการเมนูหลักของหน้า Profile
  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),

        // กล่องเมนูหลัก
        Container(
          color: Colors.white,
          child: Column(
            children: [
              // เมนูไปยังหน้าร้านของผู้ใช้
              _buildListTile(
                Icons.storefront,
                'Your Store',
                const Color(0xFF4D93CF),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopScreen(),
                    ),
                  );
                },
              ),

              _buildDivider(),

              // เมนูไปยังหน้าคำสั่งซื้อของฉัน
              _buildListTile(
                Icons.assignment_outlined,
                'My Orders',
                const Color(0xFF4D93CF),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderScreen(),
                    ),
                  );
                },
              ),

              _buildDivider(),

              // เมนูไปยังระบบเทรดสินค้า
              _buildListTile(
                Icons.swap_calls,
                'Trade System',
                const Color(0xFF4D93CF),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TradeSystemScreen(),
                    ),
                  );
                },
              ),

              _buildDivider(),

              // เมนูไปยังหน้าแนะนำเพื่อน
              _buildListTile(
                Icons.people_outline,
                'Refer a Friend',
                const Color(0xFF4D93CF),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReferralScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // เมนูศูนย์ช่วยเหลือ
        Container(
          color: Colors.white,
          child: ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: Colors.blue,
            ),
            title: const Text(
              'Help Center',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 30),

        // ปุ่มออกจากระบบ
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
                side: const BorderSide(
                  color: Colors.redAccent,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Log Out',
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

  // Widget สำหรับสร้างเมนูแต่ละแถว
  Widget _buildListTile(
      IconData icon,
      String title,
      Color iconColor,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // เส้นคั่นระหว่างเมนู
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 50,
      color: Color(0xFFEEEEEE),
    );
  }

  // แถบเมนูด้านล่างของหน้า Profile
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

      // เมื่อกดเมนูด้านล่าง
      onTap: (int index) {
        if (index == 0) {
          // Offers / Home
          // ใช้ pop กลับหน้า Home เดิม ถ้ากลับได้
          // ถ้ากลับไม่ได้ค่อยเปิด ShopHomeScreen ใหม่
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ShopHomeScreen(),
              ),
            );
          }
        } else if (index == 1) {
          // Orders
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderScreen(),
            ),
          );
        } else if (index == 2) {
          // Earnings
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IncomeScreen(),
            ),
          );
        } else if (index == 3) {
          // Account
          // อยู่หน้านี้อยู่แล้ว ไม่ต้องทำอะไร
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Offers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on_outlined),
          label: 'Earnings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }

  // Dialog ยืนยันการออกจากระบบ
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // ปิด Dialog ก่อน
                Navigator.pop(dialogContext);

                // เคลียร์ข้อมูลผู้ใช้ใน UserManager
                await UserManager().logout();

                // กลับไปหน้า Home ใหม่หลัง logout
                // หลังจากนี้กด Account จะขึ้น Login/Register ตามปกติ
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShopHomeScreen(),
                    ),
                        (route) => false,
                  );
                }
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}