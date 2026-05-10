// หน้าแนะนำเพื่อน
// หน้านี้ใช้สำหรับแสดงรายชื่อผู้ใช้ที่แนะนำให้ติดตาม
// คอมเมนต์ใช้ภาษาไทย ส่วนข้อความที่แสดงในแอปใช้ภาษาอังกฤษทั้งหมด

import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/follow_manager.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  // ข้อมูลเพื่อนจำลองสำหรับแสดงผลบนหน้าแนะนำเพื่อน
  // ในอนาคตสามารถเปลี่ยนส่วนนี้ให้ดึงข้อมูลจาก Firebase หรือ API ได้
  final List<Map<String, dynamic>> _friends = [
    {
      "name": "Somchai Jaidee",
      "username": "@somchai_dev",
      "isFollowing": false,
      "image": "https://i.pravatar.cc/150?img=11",
    },
    {
      "name": "Mana Pakpian",
      "username": "@mana_coder",
      "isFollowing": true,
      "image": "https://i.pravatar.cc/150?img=12",
    },
    {
      "name": "Wipa Shop",
      "username": "@wipa_shop",
      "isFollowing": false,
      "image": "https://i.pravatar.cc/150?img=5",
    },
    {
      "name": "Piti Photo",
      "username": "@piti_photo",
      "isFollowing": false,
      "image": "https://i.pravatar.cc/150?img=14",
    },
    {
      "name": "Choojai Cute",
      "username": "@choojai_cute",
      "isFollowing": true,
      "image": "https://i.pravatar.cc/150?img=9",
    },
  ];

  // ฟังก์ชันสำหรับสลับสถานะ Follow / Following
  void _toggleFollow(int index) {
    setState(() {
      // ดึงสถานะเดิมของผู้ใช้คนนั้นว่าติดตามอยู่หรือไม่
      final bool wasFollowing = _friends[index]["isFollowing"];

      // สลับค่า isFollowing
      // ถ้าเดิมเป็น false จะเปลี่ยนเป็น true
      // ถ้าเดิมเป็น true จะเปลี่ยนเป็น false
      _friends[index]["isFollowing"] = !wasFollowing;

      // อัปเดตจำนวนคนที่กำลังติดตามแบบ real-time ผ่าน FollowManager
      if (!wasFollowing) {
        // ถ้ายังไม่ได้ติดตาม แล้วกด Follow ให้เพิ่มจำนวน following ขึ้น 1
        FollowManager.followingCount.value++;
      } else {
        // ถ้าติดตามอยู่แล้ว แล้วกดยกเลิก ให้ลดจำนวน following ลง 1
        FollowManager.followingCount.value--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // AppBar ด้านบนของหน้าแนะนำเพื่อน
      appBar: AppBar(
        title: const Text('Refer a Friend'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // แสดงรายชื่อเพื่อนแบบ ListView
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          // ดึงข้อมูลเพื่อนแต่ละคนจาก List
          final friend = _friends[index];

          // เช็คว่าผู้ใช้คนนี้ถูกติดตามอยู่หรือไม่
          final bool isFollowing = friend["isFollowing"];

          return Card(
            color: Colors.white,
            elevation: 1,
            margin: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            // รายละเอียดของผู้ใช้แต่ละคน
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              // รูปโปรไฟล์ของผู้ใช้
              // ตอนนี้ใช้รูปจาก URL ตัวอย่าง
              // ถ้าเชื่อม Firebase หรือ API แล้ว สามารถเปลี่ยนเป็น imageUrl จากฐานข้อมูลได้
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  friend["image"],
                ),
              ),

              // ชื่อผู้ใช้
              title: Text(
                friend["name"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // username ของผู้ใช้
              subtitle: Text(
                friend["username"],
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              // ปุ่ม Follow / Following
              trailing: SizedBox(
                width: 100,
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    _toggleFollow(index);
                  },
                  style: ElevatedButton.styleFrom(
                    // ถ้าติดตามแล้วให้ปุ่มเป็นสีเทา
                    // ถ้ายังไม่ได้ติดตามให้ปุ่มเป็นสีฟ้า
                    backgroundColor:
                    isFollowing ? Colors.grey.shade200 : Colors.blue,
                    foregroundColor:
                    isFollowing ? Colors.black87 : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  // ข้อความบนปุ่ม แสดงตามสถานะการติดตาม
                  child: Text(
                    isFollowing ? "Following" : "Follow",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
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