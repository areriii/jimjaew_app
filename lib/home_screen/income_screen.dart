// รายได้ของร้าน
// หน้านี้ใช้สำหรับแสดงรายได้รวมของร้าน และแสดงประวัติรายได้จากคำสั่งซื้อทั้งหมด

import 'package:flutter/material.dart';
// เช็ค Import ให้ตรงกับโฟลเดอร์ของโปรเจกต์
import 'package:jimjaew_app/products/order_manager.dart';

class IncomeScreen extends StatelessWidget {
  IncomeScreen({super.key});

  // ใช้สำหรับดึงข้อมูลคำสั่งซื้อจาก Firebase และคำนวณรายได้ของร้าน
  final OrderManager _orderManager = OrderManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // AppBar ด้านบนของหน้ารายได้
      appBar: AppBar(
        title: const Text('Store Income'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,

        // ปุ่มสำหรับทดสอบเพิ่มรายได้จำลอง
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_shopping_cart,
              color: Colors.white,
            ),
            tooltip: 'Add Demo Income',
            onPressed: () async {
              // เมื่อกดปุ่มนี้ จะเพิ่มคำสั่งซื้อจำลองเข้าไปใน orders เพื่อทดสอบรายได้ร้าน
              await _orderManager.addOrder(
                "Demo Customer Bought a Shirt",
                500.0,
              );
            },
          ),
        ],
      ),

      // ดึงข้อมูลจากคำสั่งซื้อทั้งหมดมาคำนวณรายได้
      body: StreamBuilder<List<OrderModel>>(
        stream: _orderManager.getOrdersStream(),
        builder: (context, snapshot) {
          // กรณีกำลังโหลดข้อมูลจาก Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // กรณีโหลดข้อมูลผิดพลาด
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load income data'),
            );
          }

          final orders = snapshot.data ?? [];

          // คำนวณรายได้รวมทั้งหมดจากคำสั่งซื้อทุกอัน
          double totalIncome = 0;
          for (var order in orders) {
            totalIncome += order.totalPrice;
          }

          return Column(
            children: [
              // ส่วนหัว Dashboard แสดงรายได้รวม
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 20.0,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Color(0xFF56CCF2),
                    ],
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
                    // ข้อความหัวข้อรายได้รวม
                    const Text(
                      "Total Income",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // แสดงยอดเงินรวมทั้งหมด
                    Text(
                      "฿${totalIncome.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // แสดงจำนวนคำสั่งซื้อทั้งหมด
                    Text(
                      "Total sales: ${orders.length} orders",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // หัวข้อส่วนประวัติรายได้
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Income History",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // รายการประวัติรายได้แบบละเอียด
              Expanded(
                child: orders.isEmpty
                    ? const Center(
                  child: Text(
                    "No income yet",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    // แปลงวันที่จาก Timestamp ให้อ่านง่าย
                    final date = order.createdAt.toDate();
                    final dateString =
                        "${date.day}/${date.month}/${date.year} "
                        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        // Icon รายได้ด้านซ้าย
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5E9),
                          child: Icon(
                            Icons.monetization_on,
                            color: Colors.green,
                          ),
                        ),

                        // ชื่อสินค้าหรือรายการที่สร้างรายได้
                        title: Text(
                          order.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // วันที่เกิดรายได้
                        subtitle: Text(
                          dateString,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        // จำนวนเงินที่ได้รับ
                        trailing: Text(
                          "+ ฿${order.totalPrice}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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