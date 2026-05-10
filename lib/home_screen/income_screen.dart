// รายได้ของร้าน

import 'package:flutter/material.dart';
// 🔴 อย่าลืมเช็ค Import ให้ตรงกับโฟลเดอร์ของคุณนะครับ
import 'package:jimjaew_app/products/order_manager.dart';

class IncomeScreen extends StatelessWidget {
  IncomeScreen({super.key});

  final OrderManager _orderManager = OrderManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('รายได้ของร้าน'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        // 🌟 เพิ่มปุ่มสำหรับทดสอบจำลองรายได้เข้า
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            tooltip: 'จำลองลูกค้าซื้อของ',
            onPressed: () async {
              // พอกดปุ่มนี้ จะสั่งให้ orderManager โยนเงินเข้าตะกร้า orders (รายได้ร้าน) ทันที
              await _orderManager.addOrder("ลูกค้าจำลองซื้อเสื้อ", 500.0);
            },
          )
        ],
      ),
      // 🌟 ดึงข้อมูลจากคำสั่งซื้อทั้งหมดมาคำนวณ
      body: StreamBuilder<List<OrderModel>>(
        stream: _orderManager.getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          }

          final orders = snapshot.data ?? [];

          // 🌟 โค้ดคำนวณ "รายได้รวมทั้งหมด" (เอาคำสั่งซื้อทุกอันมาบวกกัน)
          double totalIncome = 0;
          for (var order in orders) {
            totalIncome += order.totalPrice;
          }

          return Column(
            children: [
              // ---------------------------------------------
              // 1. ส่วนหัว: แดชบอร์ดโชว์รายได้รวม (สีฟ้าสวยๆ)
              // ---------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Color(0xFF56CCF2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "ยอดรายได้รวมทั้งหมด",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "฿${totalIncome.toStringAsFixed(2)}", // โชว์ยอดเงินรวมทศนิยม 2 ตำแหน่ง
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "ขายไปแล้วทั้งหมด ${orders.length} รายการ",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------------------------------------------
              // 2. ส่วนล่าง: รายการรายได้แบบ "ละเอียด" ทีละชิ้น
              // ---------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "ประวัติรายได้ (รายละเอียด)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: orders.isEmpty
                    ? const Center(child: Text("ยังไม่มีรายได้เข้าในขณะนี้", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    // แปลงวันที่ให้อ่านง่าย
                    final date = order.createdAt.toDate();
                    final dateString = "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5E9), // สีเขียวอ่อน
                          child: Icon(Icons.monetization_on, color: Colors.green),
                        ),
                        title: Text(order.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(dateString, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: Text(
                          "+ ฿${order.totalPrice}",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}