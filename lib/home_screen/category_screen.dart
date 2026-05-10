// หมวดหมู่สินค้า

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jimjaew_app/model/product_model.dart'; // เช็คชื่อไฟล์ ProductCard ของคุณ
import 'package:jimjaew_app/products/shop_item_model.dart';
import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/products/product_manager.dart';

class CategoryScreen extends StatefulWidget {
  final List categories;
  final List products;
  final String? selectedCategory;
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
  final TextEditingController _searchController = TextEditingController();
  final ProductManager _productManager = ProductManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // เปลี่ยนพื้นหลังหลักเป็นสีขาวให้ดูสะอาดตา
      appBar: AppBar(
        title: const Text("หมวดหมู่สินค้า", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false, // 🌟 เพิ่มบรรทัดนี้เพื่อป้องกันไม่ให้แอปใส่ปุ่มย้อนกลับมาให้อัตโนมัติ
      ),
      body: Column(
        children: [
          // 🔍 โซนค้นหา (ปรับดีไซน์ให้ดูโค้งมนและมีเงาสะอาดตา)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "ค้นหาสินค้าในหมวดหมู่นี้...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 โซนซ้าย: แถบเมนูหมวดหมู่สไตล์โมเดิร์น
                Container(
                  width: 90, // ลดความกว้างลงจาก 110 เหลือ 90 ให้การ์ดฝั่งขวามีที่หายใจ
                  color: Colors.white,
                  child: ListView.builder(
                    itemCount: widget.categories.length,
                    itemBuilder: (context, index) {
                      final category = widget.categories[index];
                      final isSelected = widget.selectedCategory == category["label"];

                      return GestureDetector(
                        onTap: () {
                          widget.onCategorySelect(isSelected ? "" : category["label"]);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF5F5F5) : Colors.white,
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 4, // เพิ่มแถบสีฟ้าด้านซ้ายเวลาถูกเลือก
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: Text(
                              category["label"],
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.grey.shade600,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

                // 🔴 โซนขวา: ตารางสินค้า
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F5F5), // ให้พื้นหลังฝั่งสินค้าเป็นสีเทาอ่อน การ์ดสีขาวจะเด้งขึ้นมา
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('products').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("ยังไม่มีสินค้าในร้าน", style: TextStyle(color: Colors.grey)));
                        }

                        final allRealProducts = snapshot.data!.docs
                            .map((doc) => ShopItemModel.fromFirestore(doc))
                            .toList();

                        final String query = _searchController.text.trim().toLowerCase();
                        final filteredRealProducts = allRealProducts.where((product) {
                          final matchCategory = (widget.selectedCategory == null || widget.selectedCategory!.isEmpty)
                              ? true
                              : product.category == widget.selectedCategory;

                          final matchSearch = query.isEmpty || product.name.toLowerCase().contains(query);

                          return matchCategory && matchSearch;
                        }).toList();

                        if (filteredRealProducts.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("ไม่พบสินค้า", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: filteredRealProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.52, // ปรับสัดส่วนให้สมดุล
                          ),
                          itemBuilder: (context, index) {
                            final realProduct = filteredRealProducts[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(product: realProduct),
                                  ),
                                );
                              },
                              child: ProductCard(
                                name: realProduct.name,
                                price: "฿${realProduct.price}",
                                rating: realProduct.rating.toInt(),
                                // 🌟 เปลี่ยนให้ดึงสถานะหัวใจ "ของจริง" มาแสดง
                                isFavorite: realProduct.isFavorite,
                                imageUrl: realProduct.imagePath ?? "",
                                // ภายใน GridView.builder ของหน้า Category
                                onFavoriteToggle: () {
                                  // อย่าลืมสร้างตัวแปร final ProductManager _productManager = ProductManager(); ไว้ด้านบนด้วยนะครับ
                                  _productManager.toggleFavorite(realProduct.id, realProduct.isFavorite);
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