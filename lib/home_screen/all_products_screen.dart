// หน้าสินค้าทั้งหมด
// หน้านี้ใช้สำหรับแสดงสินค้าทั้งหมดในรูปแบบ GridView
// เมื่อกดที่สินค้า จะไปยังหน้ารายละเอียดสินค้า
// คอมเมนต์เป็นภาษาไทย ส่วนข้อความที่แสดงในแอปเป็นภาษาอังกฤษทั้งหมด

import 'package:flutter/material.dart';
import 'package:jimjaew_app/model/product_model.dart';
import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';

class AllProductsScreen extends StatelessWidget {
  // รับรายการสินค้ามาจากหน้าก่อนหน้า
  final List<Map<String, dynamic>> products;

  const AllProductsScreen({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // AppBar ด้านบนของหน้าสินค้าทั้งหมด
      appBar: AppBar(
        title: const Text("All Products"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        // ปุ่มย้อนกลับไปหน้าก่อนหน้า
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // ส่วนแสดงรายการสินค้าทั้งหมด
      body: Padding(
        padding: const EdgeInsets.all(20),

        // แสดงสินค้าเป็นตาราง 2 คอลัมน์
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.58,
          ),
          itemBuilder: (context, index) {
            // ดึงข้อมูลสินค้าแต่ละชิ้นจาก List
            final product = products[index];

            return GestureDetector(
              onTap: () {
                // เมื่อกดสินค้า จะไปยังหน้ารายละเอียดสินค้า
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      // แปลงข้อมูลสินค้าแบบ Map ให้เป็น ShopItemModel ก่อนส่งไปหน้า Detail
                      product: ShopItemModel(
                        id: 'mock_id',
                        name: product["name"] ?? "No Name",
                        price: double.tryParse(
                          product["price"].toString(),
                        ) ??
                            0.0,
                        stock: 10,
                        imagePath: product["image"],
                        category: 'Shirt',
                      ),
                    ),
                  ),
                );
              },

              // การ์ดแสดงข้อมูลสินค้า
              child: ProductCard(
                name: product["name"] ?? "",
                price: product["price"] ?? "",
                rating: product["rating"] ?? 0,
                isFavorite: product["favorite"] ?? false,
                imageUrl: product["image"] ?? "",

                // ฟังก์ชันกดหัวใจสินค้า
                // หมายเหตุ: หน้านี้เป็น StatelessWidget จึงเปลี่ยนค่าได้แต่หน้าจอจะไม่ refresh ทันที
                onFavoriteToggle: () {
                  product["favorite"] = !(product["favorite"] ?? false);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}