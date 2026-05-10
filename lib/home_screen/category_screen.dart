// หมวดหมู่สินค้า
// หน้านี้ใช้สำหรับแสดงรายการสินค้าแยกตามหมวดหมู่
// มีช่องค้นหาสินค้า และสามารถกดสินค้าเพื่อไปหน้ารายละเอียดได้
// คอมเมนต์เป็นภาษาไทย ส่วนข้อความที่แสดงในแอปเป็นภาษาอังกฤษทั้งหมด

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jimjaew_app/model/product_model.dart'; // เช็คชื่อไฟล์ ProductCard ของคุณ
import 'package:jimjaew_app/products/shop_item_model.dart';
import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/products/product_manager.dart';

class CategoryScreen extends StatefulWidget {
  // รายการหมวดหมู่ที่รับมาจากหน้า ShopHomeScreen
  final List categories;

  // รายการสินค้าเดิมที่รับเข้ามา แต่ตอนนี้สินค้าจริงดึงจาก Firebase
  final List products;

  // หมวดหมู่ที่ถูกเลือกอยู่ในปัจจุบัน
  final String? selectedCategory;

  // ฟังก์ชันส่งค่าหมวดหมู่กลับไปยังหน้าหลัก
  final Function(String) onCategorySelect;

  const CategoryScreen({
    super.key,
    required this.categories,
    required this.products,
    required this.selectedCategory,
    required this.onCategorySelect,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Controller สำหรับควบคุมช่องค้นหา
  final TextEditingController _searchController = TextEditingController();

  // ใช้เรียกฟังก์ชันจัดการสินค้า เช่น toggleFavorite
  final ProductManager _productManager = ProductManager();

  @override
  void dispose() {
    // ปิด Controller เมื่อไม่ใช้หน้านี้แล้ว เพื่อป้องกัน memory leak
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // พื้นหลังหลักของหน้า Category
      backgroundColor: Colors.white,

      // AppBar ด้านบนของหน้าหมวดหมู่สินค้า
      appBar: AppBar(
        title: const Text(
          "Product Categories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        // ป้องกันไม่ให้แอปเพิ่มปุ่มย้อนกลับให้อัตโนมัติ
        automaticallyImplyLeading: false,
      ),

      body: Column(
        children: [
          // โซนค้นหาสินค้าในหมวดหมู่
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,

                // เมื่อพิมพ์ค้นหา ให้รีเฟรชหน้าจอเพื่อกรองสินค้า
                onChanged: (_) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  hintText: "Search products in this category...",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          const Divider(
            height: 1,
            color: Color(0xFFEEEEEE),
          ),

          // เนื้อหาหลัก แบ่งเป็นแถบหมวดหมู่ด้านซ้าย และสินค้าอยู่ด้านขวา
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // โซนซ้าย: รายการหมวดหมู่สินค้า
                Container(
                  width: 90,
                  color: Colors.white,
                  child: ListView.builder(
                    itemCount: widget.categories.length,
                    itemBuilder: (context, index) {
                      // ดึงข้อมูลหมวดหมู่แต่ละรายการ
                      final category = widget.categories[index];

                      // เช็คว่าหมวดหมู่นี้ถูกเลือกอยู่หรือไม่
                      final isSelected =
                          widget.selectedCategory == category["label"];

                      return GestureDetector(
                        onTap: () {
                          // ถ้ากดหมวดหมู่ที่เลือกอยู่แล้ว จะส่งค่าว่างเพื่อยกเลิกการเลือก
                          // ถ้ากดหมวดหมู่ใหม่ จะส่งชื่อหมวดหมู่กลับไป
                          widget.onCategorySelect(
                            isSelected ? "" : category["label"],
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF5F5F5)
                                : Colors.white,
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                          child: Center(
                            child: Text(
                              category["label"],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade600,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // โซนขวา: ตารางสินค้า
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F5F5),

                    // ดึงข้อมูลสินค้าจาก Firebase แบบ real-time
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .snapshots(),
                      builder: (context, snapshot) {
                        // กรณีกำลังโหลดข้อมูลจาก Firebase
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // กรณียังไม่มีสินค้าในร้าน
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No products in store",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        // แปลงข้อมูลจาก Firebase document ให้เป็น ShopItemModel
                        final allRealProducts = snapshot.data!.docs
                            .map((doc) => ShopItemModel.fromFirestore(doc))
                            .toList();

                        // ดึงค่าคำค้นหาจากช่อง Search
                        final String query =
                        _searchController.text.trim().toLowerCase();

                        // กรองสินค้าตามหมวดหมู่ที่เลือก และคำค้นหา
                        final filteredRealProducts =
                        allRealProducts.where((product) {
                          // ถ้าไม่ได้เลือกหมวดหมู่ ให้แสดงสินค้าทั้งหมด
                          // ถ้าเลือกหมวดหมู่ ให้แสดงเฉพาะสินค้าที่ category ตรงกัน
                          final matchCategory =
                          (widget.selectedCategory == null ||
                              widget.selectedCategory!.isEmpty)
                              ? true
                              : product.category ==
                              widget.selectedCategory;

                          // ถ้าไม่ได้ค้นหา ให้แสดงสินค้าทั้งหมด
                          // ถ้าค้นหา ให้เช็คจากชื่อสินค้า
                          final matchSearch = query.isEmpty ||
                              product.name.toLowerCase().contains(query);

                          return matchCategory && matchSearch;
                        }).toList();

                        // กรณีค้นหาแล้วไม่เจอสินค้า
                        if (filteredRealProducts.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "No products found",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // แสดงสินค้าเป็นตาราง GridView
                        return GridView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: filteredRealProducts.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.52,
                          ),
                          itemBuilder: (context, index) {
                            final realProduct = filteredRealProducts[index];

                            return GestureDetector(
                              onTap: () {
                                // เมื่อกดสินค้า จะไปหน้ารายละเอียดสินค้า
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailScreen(
                                          product: realProduct,
                                        ),
                                  ),
                                );
                              },
                              child: ProductCard(
                                name: realProduct.name,
                                price: "฿${realProduct.price}",
                                rating: realProduct.rating.toInt(),

                                // ดึงสถานะหัวใจจาก Firebase มาแสดง
                                isFavorite: realProduct.isFavorite,

                                // ดึงรูปสินค้าจาก Firebase
                                imageUrl: realProduct.imagePath ?? "",

                                // เมื่อกดหัวใจ ให้อัปเดตสถานะ favorite ลง Firebase
                                onFavoriteToggle: () {
                                  _productManager.toggleFavorite(
                                    realProduct.id,
                                    realProduct.isFavorite,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}