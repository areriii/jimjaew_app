// หน้าคำสั่งซื้อจากลูกค้า
// หน้านี้ใช้สำหรับให้ร้านค้าดูรายการออเดอร์จากลูกค้าแบบ real-time
// และมีปุ่มสำหรับไปยังหน้าสรุปรายได้ของร้าน

import 'package:flutter/material.dart';
import 'package:jimjaew_app/products/order_manager.dart';
import 'package:jimjaew_app/home_screen/income_screen.dart';

class SellerOrderScreen extends StatelessWidget {
  SellerOrderScreen({super.key});

  // ใช้สำหรับเรียกข้อมูลคำสั่งซื้อจาก Firebase
  final OrderManager _orderManager = OrderManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // AppBar ด้านบนของหน้าคำสั่งซื้อ
      appBar: AppBar(
        title: const Text('Customer Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // ปุ่มด้านบนสำหรับไปยังหน้าสรุปรายได้ของร้าน
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton.icon(
              onPressed: () {
                // เมื่อกดปุ่มนี้ จะไปยังหน้า IncomeScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncomeScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.monetization_on,
                color: Colors.white,
              ),
              label: const Text(
                "View Store Income",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ส่วนแสดงรายการคำสั่งซื้อจากลูกค้าแบบ real-time
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              // ดึงรายการคำสั่งซื้อจาก Firebase ผ่าน OrderManager
              stream: _orderManager.getOrdersStream(),

              builder: (context, snapshot) {
                // กรณีที่ระบบกำลังโหลดข้อมูลจาก Firebase
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // กรณีไม่มีข้อมูลคำสั่งซื้อ
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No customer orders yet",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                // เก็บข้อมูลออเดอร์ทั้งหมดที่ดึงมาจาก Firebase
                final orders = snapshot.data!;

                // แสดงรายการคำสั่งซื้อเป็น ListView
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    // แปลงวันที่จาก Timestamp ให้เป็นวันที่ที่อ่านง่าย
                    final date = order.createdAt.toDate();

                    final dateString =
                        "${date.day}/${date.month}/${date.year} "
                        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: Colors.white,
                      elevation: 1,
                      child: ListTile(
                        // Icon ด้านซ้ายของรายการคำสั่งซื้อ
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF3E0),
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.orange,
                          ),
                        ),

                        // ชื่อสินค้าที่ลูกค้าสั่งซื้อ
                        title: Text(
                          order.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // วันที่และเวลาที่สั่งซื้อ
                        subtitle: Text(
                          "Ordered on: $dateString",
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),

                        // ราคาหรือยอดรวมของคำสั่งซื้อ
                        trailing: Text(
                          "+ ฿${order.totalPrice}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}