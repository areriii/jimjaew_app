//หน้า ร้านของคุณ
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
// 🔴 เช็ค Import ให้ตรงกับโฟลเดอร์ของคุณด้วยนะครับ (home_screen หรือ products)
import 'package:jimjaew_app/home_screen/product_screen.dart';

// 🌟 1. อัปเกรดเป็น StatefulWidget เพื่อให้หน้าจอกดปุ่มแล้วเปลี่ยนข้อมูลได้
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ProductManager _productManager = ProductManager();

  // 🌟 2. ตัวแปรสำหรับจำว่าตอนนี้เรา "กดเลือกหมวดหมู่ไหนอยู่" (ค่าเริ่มต้นคือ Shirt)
  String _selectedCategoryFilter = 'Shirt';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            _buildHeader(context),
            const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.black,
              tabs: [Tab(text: "สินค้า"), Tab(text: "หมวดหมู่")],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProductGrid(), // หน้า "สินค้า" (โชว์ทั้งหมด)
                  _buildCategoryPage(), // หน้า "หมวดหมู่" (โชว์แยก)
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomManageButton(context),
      ),
    );
  }

  // --- ส่วนโชว์สินค้าทั้งหมด (หน้าแรก) ---
  Widget _buildProductGrid() {
    return StreamBuilder<List<ShopItemModel>>(
      stream: _productManager.getProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.blue));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('ยังไม่มีสินค้าในร้านของคุณ'));

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

  // --- ส่วนวาดการ์ดสินค้า ---
  Widget _buildProductCard(ShopItemModel product) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text(
                    product.name,
                    maxLines: 1, // ปรับให้เหลือ 1 บรรทัดเพื่อเพิ่มพื้นที่ให้แถวดาว
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),

                // 🌟 แถวโชว์คะแนนดาวรีวิวแบบสวยงามสไตล์ Shopee
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14), // ดาวสีทอง
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1), // โชว์คะแนน เช่น 4.8
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "(${product.reviewCount})", // โชว์จำนวนคนรีวิว เช่น (120)
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
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

  // --- ส่วนปุ่มจัดการสินค้าด้านล่าง ---
  Widget _buildBottomManageButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: const Text("จัดการสินค้า (เพิ่ม/แก้ไข/ลบ)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // --- ส่วน Header ด้านบน ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4D93CF), Color(0xFF90CCEE)],
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

  // --- 🌟 ส่วนวาดหน้า "หมวดหมู่" ที่แก้ไขใหม่ ---
  Widget _buildCategoryPage() {
    final categories = [
      {"icon": Icons.checkroom, "label": "Shirt"},
      {"icon": Icons.airline_seat_legroom_extra, "label": "Pants"},
      {"icon": Icons.visibility, "label": "Glasses"},
      {"icon": Icons.snowshoeing, "label": "Shoes"},
      {"icon": Icons.watch, "label": "Watch"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("เลือกหมวดหมู่", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoryLabel = categories[index]["label"] as String;
              // เช็คว่าปุ่มไหนกำลังถูกกดอยู่
              bool isSelected = _selectedCategoryFilter == categoryLabel;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: InkWell(
                  onTap: () {
                    // 🌟 3. พอกดปุ่มปุ๊บ ให้เปลี่ยนค่าตัวแปร และสั่งให้หน้าจออัปเดต (กระพริบ 1 ที)
                    setState(() {
                      _selectedCategoryFilter = categoryLabel;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          categories[index]["icon"] as IconData,
                          color: isSelected ? Colors.white : Colors.black87,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categoryLabel,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 🌟 4. ดึงข้อมูลจาก Firebase ตามหมวดหมู่ที่ถูกเลือก (มาแทนที่ข้อความหลอกๆ)
        Expanded(
          child: StreamBuilder<List<ShopItemModel>>(
            // สั่งให้ไปดึงข้อมูลเฉพาะหมวดหมู่ที่คลิกอยู่เท่านั้น
            stream: _productManager.getProductsByCategoryStream(_selectedCategoryFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.blue));
              if (snapshot.hasError) return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));

              // ถ้าหมวดหมู่นั้นยังไม่มีสินค้า ให้โชว์ข้อความนี้
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text(
                        'ยังไม่มีสินค้าในหมวดหมู่ $_selectedCategoryFilter',
                        style: const TextStyle(color: Colors.grey)
                    )
                );
              }

              // ถ้ามีสินค้า ให้วาดกล่องสินค้าออกมาเลย!
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
          ),
        ),
      ],
    );
  }
}