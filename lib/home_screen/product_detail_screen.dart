import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jimjaew_app/products/shop_item_model.dart'; // 🔴 นำเข้าโมเดลสินค้าที่เราทำไว้

class ProductDetailScreen extends StatefulWidget {
  // 🔴 เปลี่ยนมารับข้อมูลสินค้าแบบ "ทั้งก้อน" ผ่าน ShopItemModel
  final ShopItemModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลสินค้าที่ส่งมาเก็บไว้ในตัวแปร item
    final item = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name), // แสดงชื่อสินค้าบนแถบด้านบน
        backgroundColor:  Color(0xFFEE4D2D), // ใช้สีส้มธีมแอป
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.trolley))
        ],
      ),
      body: ListView(
        children: [
          // 1. ส่วนแสดงรูปภาพ (ดึงจากเครื่องเหมือนหน้าอื่นๆ)
          SizedBox(
            height: 300,
            width: double.infinity,
            child: item.imagePath != null
                ? Image.file(File(item.imagePath!), fit: BoxFit.cover)
                : Container(
              color: Colors.white54,
              child: Icon(Icons.photo, size: 100, color: Colors.blueGrey.shade200),
            ),
          ),

          // 2. ส่วนชื่อสินค้า
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          // 3. ส่วนราคาและสต็อก
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "฿${item.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Color(0xFFEE4D2D),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.stock > 0 ? "มีสินค้า : ${item.stock} ชิ้น" : "สินค้าหมด",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item.stock > 10
                        ? Colors.green
                        : item.stock > 0
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // 4. ส่วนรายละเอียด
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "รายละเอียดสินค้า:\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s...",
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),

      // แถบปุ่มกดด้านล่าง
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { },
                    icon: const Icon(Icons.add_shopping_cart, color: Color(0xFFEE4D2D)),
                    label: const Text("เพิ่มลงรถเข็น", style: TextStyle(color: Color(0xFFEE4D2D))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEE4D2D)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: ()  { },
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text("ซื้อสินค้า", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE4D2D),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}