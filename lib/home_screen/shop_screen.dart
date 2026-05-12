// หน้า ร้านของคุณ
import 'package:flutter/material.dart';
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
// 🔴 เช็ค Import ให้ตรงกับโฟลเดอร์ของคุณ
import 'package:jimjaew_app/home_screen/product_screen.dart';
import 'package:jimjaew_app/products/product_image.dart'; // 🌟 เรียกใช้ Widget แสดงรูปที่เราสร้างไว้

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ProductManager _productManager = ProductManager();
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
              indicatorColor: Color(0xFF4D93CF),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Products"),
                Tab(text: "Categories"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProductGrid(),
                  _buildCategoryPage(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomManageButton(context),
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<List<ShopItemModel>>(
      stream: _productManager.getProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products in your store'));
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
          itemBuilder: (context, index) {
            return _buildProductCard(products[index]);
          },
        );
      },
    );
  }

  // --- ส่วนวาดการ์ดสินค้า (แก้ไขจุดแสดงรูปภาพ) ---
  Widget _buildProductCard(ShopItemModel product) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade100,
              // 🌟 เปลี่ยนจาก Image.network เป็น ProductImage เพื่อให้รูปติดถาวร
              child: ProductImage(
                imagePath: product.imagePath,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text("(${product.reviewCount})", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "฿${product.price}",
                  style: const TextStyle(color: Color(0xFFEE4D2D), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("Stock: ${product.stock}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: const Text("Manage Products", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4D93CF), Color(0xFF90CCEE)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              CircleAvatar(
                radius: 30, backgroundColor: Colors.white,
                child: Icon(Icons.storefront, color: Color(0xFF4D93CF), size: 32),
              ),
              SizedBox(width: 15),
              Text("My Store", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

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
          child: Text("Select Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoryLabel = categories[index]["label"] as String;
              bool isSelected = _selectedCategoryFilter == categoryLabel;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedCategoryFilter = categoryLabel),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60, height: 60,
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
                        style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ShopItemModel>>(
            stream: _productManager.getProductsByCategoryStream(_selectedCategoryFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blue));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No products in $_selectedCategoryFilter', style: const TextStyle(color: Colors.grey)));
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
          ),
        ),
      ],
    );
  }
}