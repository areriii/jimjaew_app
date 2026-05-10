//หน้ารายได้

import 'package:flutter/material.dart';
// 🔴 เช็ค Import ให้ตรงกับโฟลเดอร์ของคุณนะครับ
import 'package:jimjaew_app/products/order_manager.dart';
import 'package:jimjaew_app/home_screen/income_screen.dart'; // ดึงหน้ารายได้มาใช้

class SellerOrderScreen extends StatelessWidget {
  SellerOrderScreen({super.key});

  final OrderManager _orderManager = OrderManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('คำสั่งซื้อจากลูกค้า'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🌟 ปุ่มใหญ่ด้านบน สำหรับลิงก์ไปหน้า "รายได้"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton.icon(
              onPressed: () {
                // พอกดปุ่มนี้ จะกระโดดไปหน้า IncomeScreen ทันที
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IncomeScreen()),
                );
              },
              icon: const Icon(Icons.monetization_on, color: Colors.white),
              label: const Text("ดูสรุปรายได้ของร้าน", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 🌟 รายการออเดอร์ที่ลูกค้าสั่งมา (เรียลไทม์)
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              // 💡 ใช้ getOrdersStream() เพื่อดึง "ตะกร้าของร้าน" ไม่ใช่ของที่ฉันซื้อ
              stream: _orderManager.getOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("ยังไม่มีคำสั่งซื้อจากลูกค้า", style: TextStyle(color: Colors.grey)),
                  );
                }

                final orders = snapshot.data!;
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final date = order.createdAt.toDate();
                    final dateString = "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      color: Colors.white,
                      elevation: 1,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF3E0), // สีส้มอ่อน
                          child: Icon(Icons.receipt_long, color: Colors.orange),
                        ),
                        title: Text(order.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("สั่งเมื่อ: $dateString", style: const TextStyle(fontSize: 12)),
                        trailing: Text("+ ฿${order.totalPrice}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
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