import 'dart:io';
import 'package:flutter/material.dart';
// 🔴 Import ไฟล์ตัวจัดการและโมเดลข้อมูล
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
import 'package:jimjaew_app/home_screen/product_screen.dart';

class ShopScreen extends StatelessWidget {
  ShopScreen({super.key});

  // เรียกใช้ตัวจัดการเพื่อดึงข้อมูลจาก Firebase
  final ProductManager _productManager = ProductManager();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            _buildHeader(context),
            // ส่วน TabBar สำหรับสลับ สินค้า/หมวดหมู่
            const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.black,
              tabs: [Tab(text: "สินค้า"), Tab(text: "หมวดหมู่")],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProductGrid(), // ส่วนแสดงรายการสินค้าจริง
                  const Center(child: Text("หน้าหมวดหมู่")),
                ],
              ),
            ),
          ],
        ),
        // 🔴 ปุ่มสำหรับไปหน้าจัดการ (CRUD) ตามสไลด์
        bottomNavigationBar: _buildBottomManageButton(context),
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<List<ShopItemModel>>(
      stream: _productManager.getProductsStream(), // ดึงข้อมูล Stream จาก Manager
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('ยังไม่มีสินค้าในร้านของคุณ'));
        }

        final products = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(products[index]),
        );
      },
    );
  }

  Widget _buildProductCard(ShopItemModel product) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดงรูปภาพสินค้าจาก Local Path ตามที่บันทึกไว้
          Expanded(
            child: product.imagePath != null
                ? Image.file(File(product.imagePath!), fit: BoxFit.cover, width: double.infinity)
                : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("฿${product.price}", style: const TextStyle(color: Color(0xFFEE4D2D), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("คงเหลือ: ${product.stock} ชิ้น", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomManageButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // 🔴 เชื่อมไปยังหน้า Product List สำหรับจัดการข้อมูลตามสไลด์หน้า 29
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:  Colors.blue,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: const Text("จัดการสินค้า (เพิ่ม/แก้ไข/ลบ)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ส่วน Header สีส้มไล่ระดับ (Gradient)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ Color(0xFF4D93CF), Color(0xFF90CCEE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
              const Icon(Icons.settings, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const CircleAvatar(radius: 30, backgroundImage: NetworkImage('https://i.pravatar.cc/150')),
              const SizedBox(width: 15),
              const Text("pineare.shopeeeee", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}