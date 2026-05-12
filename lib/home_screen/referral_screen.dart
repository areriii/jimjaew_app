import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/follow_manager.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  // ข้อมูลเพื่อนจำลอง (เอาค่า isFollowing ออก เพราะเราจะไปเช็กจาก Manager แทน)
  final List<Map<String, dynamic>> _friends = [
    {"name": "Somchai Jaidee", "username": "@somchai_dev", "image": "https://i.pravatar.cc/150?img=11"},
    {"name": "Mana Pakpian", "username": "@mana_coder", "image": "https://i.pravatar.cc/150?img=12"},
    {"name": "Wipa Shop", "username": "@wipa_shop", "image": "https://i.pravatar.cc/150?img=5"},
    {"name": "Piti Photo", "username": "@piti_photo", "image": "https://i.pravatar.cc/150?img=14"},
    {"name": "Choojai Cute", "username": "@choojai_cute", "image": "https://i.pravatar.cc/150?img=9"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌟 เปลี่ยนพื้นหลังเป็นเทาจางคุมโทนแอป
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Refer a Friend', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🌟 เพิ่มส่วนโค้งสีฟ้าด้านบนให้เหมือนหน้าอื่น
          Container(
            height: 15,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                // 🌟 เช็กสถานะจริงจาก FollowManager
                final bool isFollowing = FollowManager.isFollowing(friend["username"]);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(friend["image"]),
                    ),
                    title: Text(friend["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(friend["username"], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    trailing: SizedBox(
                      width: 100,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          // 🌟 สั่งงานผ่าน Manager และรีเฟรชหน้าจอ
                          setState(() {
                            FollowManager.toggleFollow(friend["username"]);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing ? const Color(0xFFEEEEEE) : const Color(0xFF2196F3),
                          foregroundColor: isFollowing ? Colors.black54 : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isFollowing ? "Following" : "Follow",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}