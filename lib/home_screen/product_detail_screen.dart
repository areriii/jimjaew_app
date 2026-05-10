// หน้ากดซื้อสินค้า

import 'dart:io';
import 'package:flutter/material.dart';
// 🔴 เช็คให้แน่ใจว่า import ถูกโฟลเดอร์นะครับ
import 'package:jimjaew_app/products/shop_item_model.dart';

import '../products/order_manager.dart';

class ProductDetailScreen extends StatefulWidget {
  // ✅ เปลี่ยนมารับข้อมูลเป็นก้อน ShopItemModel
  final ShopItemModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลสินค้ามาเก็บไว้ในตัวแปร item
    final item = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart))
        ],
      ),
      body: ListView(
        children: [
          // 1. ส่วนรูปภาพ
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey[100],
            child: item.imagePath != null
                ? Image.file(File(item.imagePath!), fit: BoxFit.cover)
                : const Icon(Icons.image, size: 100, color: Colors.grey),
          ),

          // 2. ส่วนรายละเอียด
          // 2. ส่วนรายละเอียด
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "฿${item.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.stock > 0 ? "มีสินค้า : ${item.stock} ชิ้น" : "สินค้าหมด",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: item.stock > 10 ? Colors.green : (item.stock > 0 ? Colors.orange : Colors.red),
                      ),
                    ),
                  ],
                ),

                // 🌟 แถวโชว์สถิติดาวและรีวิวในหน้ารายละเอียด (เพิ่มใหม่ตรงนี้)
                const SizedBox(height: 12),
                Row(
                  children: [
                    // วาดดาว 5 ดวงตามคะแนน (สุ่มวาดดาวเต็มดวง)
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < item.rating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.rating.toStringAsFixed(1), // เช่น 4.5
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 15,
                      width: 1,
                      color: Colors.grey.shade400, // เส้นคั่นตรงกลางแบบเท่ๆ
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "ขายแล้ว ${item.reviewCount * 3} ชิ้น", // สุ่มยอดขายอิงจากจำนวนคนรีวิว
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

                const Divider(height: 40, thickness: 1),
                const Text(
                  "รายละเอียดสินค้า",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "นี่คือรายละเอียดสินค้าจำลอง คุณสามารถเพิ่มคำอธิบายสินค้ายาวๆ ลงในฐานข้อมูล Firebase แล้วดึงมาแสดงตรงนี้ได้ในอนาคตครับ...",
                  style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),

      // 3. ปุ่มด้านล่าง
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12.0),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () { },
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                  label: const Text("เพิ่มลงรถเข็น", style: TextStyle(color: Colors.blue)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  // 🌟 เพิ่ม async ตรงนี้
                  onPressed: () async {
                    // 🌟 โค้ดสร้างคำสั่งซื้อเมื่อกดปุ่ม
                    final orderManager = OrderManager();
                    // โยนชื่อสินค้า และ ราคา ส่งไปที่ Firebase
                    await orderManager.addMyPurchase(item.name, item.price); // ส่งข้อมูลเข้าตะกร้าฉันเอง

                    // โชว์แจ้งเตือนเด้งด้านล่างว่าซื้อสำเร็จแล้ว
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 สั่งซื้อสำเร็จ! ไปเช็คที่หน้าคำสั่งซื้อของฉันได้เลย'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text("ซื้อสินค้า", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}