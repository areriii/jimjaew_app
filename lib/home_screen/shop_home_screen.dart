//หน้า โฮม
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jimjaew_app/model/product_model.dart';
import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/home_screen/profile_screen.dart';
import 'package:jimjaew_app/home_screen/all_products_screen.dart';
import 'category_screen.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jimjaew_app/products/shop_item_model.dart'; // เช็ค import ให้ตรงนะครับ
import 'package:jimjaew_app/products/product_manager.dart';
class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  int _selectedIndex = 0;
  bool _isSearching = false;
  final ProductManager _productManager = ProductManager();
  final TextEditingController _searchController = TextEditingController();

  // null = ยังไม่ได้เลือก category
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {
      "icon": "assets/icons/shirt-solid-full.svg",
      "label": "Shirt",
    },
    {
      "icon": "assets/icons/pants-svgrepo-com.svg",
      "label": "Pants",
    },
    {
      "icon": "assets/icons/glasses-solid-full.svg",
      "label": "Glasses",
    },
    {
      "icon": "assets/icons/socks-solid-full.svg",
      "label": "Shoes",
    },
    {
      "icon": "assets/icons/watch-solid-full.svg",
      "label": "Watch",
    },
  ];

  final List<Map<String, dynamic>> products = [
    {
      "name": "Gustavo Rosser",
      "price": "Rs. 1000",
      "rating": 3,
      "favorite": false,
      "image":
      "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800",
      "description": "เสื้อเชิ้ตผู้ชาย ใส่สบาย เหมาะกับหลายโอกาส",
      "category": "Shirt",
    },
    {
      "name": "Hanna Dokidis",
      "price": "Rs. 1000",
      "rating": 3,
      "favorite": false,
      "image":
      "https://images.unsplash.com/photo-1603252109303-2751441dd157?w=800",
      "description": "เสื้อเชิ้ตแขนยาว เรียบ ๆ แมตช์ง่าย",
      "category": "Shirt",
    },
    {
      "name": "Original Tee",
      "price": "Rs. 1000",
      "rating": 3,
      "favorite": false,
      "image":
      "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800",
      "description": "เสื้อยืดลำลอง ใส่ได้ทุกวัน",
      "category": "Shirt",
    },
    {
      "name": "Trouser",
      "price": "Rs. 3000",
      "rating": 4,
      "favorite": true,
      "image":
      "https://images.unsplash.com/photo-1506629905607-bb5b4b1fbad5?w=800",
      "description": "กางเกงทรงสวย ใส่สบาย",
      "category": "Pants",
    },
    {
      "name": "Blue Jeans",
      "price": "Rs. 2200",
      "rating": 4,
      "favorite": false,
      "image":
      "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800",
      "description": "กางเกงยีนส์ทรงสวย",
      "category": "Pants",
    },
    {
      "name": "Classic Glasses",
      "price": "Rs. 1800",
      "rating": 4,
      "favorite": false,
      "image":
      "https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=800",
      "description": "แว่นตาทรงคลาสสิก",
      "category": "Glasses",
    },
    {
      "name": "Sport Shoes",
      "price": "Rs. 3500",
      "rating": 5,
      "favorite": true,
      "image":
      "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800",
      "description": "รองเท้าสำหรับใส่เดินสบาย",
      "category": "Shoes",
    },
    {
      "name": "Silver Watch",
      "price": "Rs. 4200",
      "rating": 4,
      "favorite": false,
      "image":
      "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=800",
      "description": "นาฬิกาดีไซน์เรียบหรู",
      "category": "Watch",
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    final query = _searchController.text.trim().toLowerCase();

    return products.where((product) {
      final name = (product["name"] ?? "").toString().toLowerCase();
      final category = (product["category"] ?? "").toString();

      final matchCategory =
      selectedCategory == null ? true : category == selectedCategory;

      final matchSearch = query.isEmpty || name.contains(query);

      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCategoryIcon(String iconPath, bool isSelected) {
    return SvgPicture.asset(
      iconPath,
      width: 28,
      height: 28,
      colorFilter: ColorFilter.mode(
        isSelected ? Colors.white : Colors.black87,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final bool isSelected = selectedCategory == category["label"];
    final String iconPath = category["icon"] as String;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedCategory == category["label"]) {
            selectedCategory = null;
          } else {
            selectedCategory = category["label"];
          }
        });
      },
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5B9DDB)
                  : const Color(0xFFD8ECFF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildCategoryIcon(iconPath, isSelected),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category["label"],
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7FB3E8),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Category",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildHomePage();
    } else if (_selectedIndex == 1) {
      // 🌟 เปลี่ยนจากการ Push หน้าใหม่ เป็นการดึงหน้า CategoryScreen มาแสดงในแท็บเลย
      return CategoryScreen(
        categories: categories,
        products: products,
        selectedCategory: selectedCategory,
        onCategorySelect: (value) {
          setState(() {
            selectedCategory = value.isEmpty ? null : value;
          });
        },
      );
    } else if (_selectedIndex == 2) {
      return _buildFavoritePage();
    } else {
      return _buildCartPage();
    }
  }


  Widget _buildHomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),

            Row(
              children: [
                if (_isSearching)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _isSearching = false;
                      });
                    },
                  ),
                Expanded(
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _isSearching
                              ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (_) {
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              hintText: "Search for products",
                              border: InputBorder.none,
                            ),
                          )
                              : GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSearching = true;
                              });
                            },
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Search for products",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        if (_isSearching)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _isSearching = false;
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const ProfileScreen(username: '', email: ''),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // 🔥 แสดง header เฉพาะ Search และ Category เท่านั้น
            if (_isSearching || _searchController.text.isNotEmpty || selectedCategory != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory != null
                        ? selectedCategory!
                        : "Search Results",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 🔥 แสดง See all เฉพาะ Search เท่านั้น
                  if (selectedCategory == null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllProductsScreen(
                              products: filteredProducts,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "See all",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 16),

            if (!_isSearching && _searchController.text.isEmpty) ...[
              const Text(
                "Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return _buildCategoryItem(categories[index]);
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],

            // 🌟 ลบ Expanded อันเดิมทิ้ง แล้วใช้อันนี้แทนครับ (ดึงจาก Firebase)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  // 1. ระหว่างรอโหลดข้อมูลจากเน็ต
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. ถ้าไม่มีสินค้าในฐานข้อมูลเลย
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("ยังไม่มีสินค้าในร้าน", style: TextStyle(color: Colors.grey)),
                    );
                  }

                  // 3. แปลงข้อมูลทั้งหมดจาก Firebase ให้กลายเป็น ShopItemModel ของจริง
                  final allRealProducts = snapshot.data!.docs
                      .map((doc) => ShopItemModel.fromFirestore(doc))
                      .toList();

                  // 🌟 4. ระบบกรองข้อมูล (ทำงานร่วมกับช่องค้นหา และปุ่มหมวดหมู่)
                  final String query = _searchController.text.trim().toLowerCase();
                  final filteredRealProducts = allRealProducts.where((product) {
                    // เช็คหมวดหมู่ (ถ้าไม่ได้เลือกคือผ่านหมด)
                    final matchCategory = selectedCategory == null || product.category == selectedCategory;
                    // เช็คคำค้นหา
                    final matchSearch = query.isEmpty || product.name.toLowerCase().contains(query);

                    return matchCategory && matchSearch;
                  }).toList();

                  // ถ้าค้นหาแล้วไม่เจออะไรเลย
                  if (filteredRealProducts.isEmpty) {
                    return const Center(
                      child: Text("ไม่พบสินค้าที่คุณค้นหา", style: TextStyle(color: Colors.grey)),
                    );
                  }

                  // 5. วาดตารางสินค้าด้วยข้อมูลจริงที่ผ่านการกรองแล้ว
                  return GridView.builder(
                    itemCount: filteredRealProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      final realProduct = filteredRealProducts[index];

                      return GestureDetector(
                        onTap: () {
                          // 🌟 ตรงนี้สำคัญ: ส่ง "ของจริง" ไปที่หน้ารายละเอียด
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: realProduct),
                            ),
                          );
                        },
                        child: ProductCard(
                          name: realProduct.name,
                          price: "฿${realProduct.price}", // เปลี่ยนเป็นแสดงค่าเงินบาท
                          rating: realProduct.rating.toInt(), // ดึงดาวของจริง
                          isFavorite: false, // ระบบ Favorite ของจริงค่อยทำทีหลัง
                          imageUrl: realProduct.imagePath ?? "", // ดึงรูปภาพจริง
                          onFavoriteToggle: () {
                            _productManager.toggleFavorite(realProduct.id, realProduct.isFavorite);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartPage() {
    return const Center(child: Text("Cart Page"));
  }

  Widget _buildFavoritePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 สร้างแถว (Row) เพื่อใส่ปุ่มย้อนกลับคู่กับหัวข้อ
            const Text(
              "Favorite (รายการโปรด)",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // ... โค้ด Expanded(child: StreamBuilder...) ของเดิมอยู่ต่อจากตรงนี้

            // 🌟 ใช้ StreamBuilder ดึงข้อมูลจริงจาก Firebase
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("ไม่มีสินค้าในร้าน", style: TextStyle(color: Colors.grey)),
                    );
                  }

                  // 🌟 ค้นหาเฉพาะสินค้าที่มีคำสั่ง isFavorite = true ใน Firebase
                  final favoriteDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['isFavorite'] == true; // กรองเอาเฉพาะอันที่กดหัวใจ
                  }).toList();

                  if (favoriteDocs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("คุณยังไม่มีสินค้าที่ถูกใจ", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  // แปลงข้อมูลที่กรองแล้วให้เป็น ShopItemModel
                  final favoriteProducts = favoriteDocs
                      .map((doc) => ShopItemModel.fromFirestore(doc))
                      .toList();

                  // วาดการ์ดสินค้า
                  return GridView.builder(
                    itemCount: favoriteProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.52, // 🌟 ใช้ 0.52 เพื่อกันข้อความล้นกรอบเหลืองดำ
                    ),
                    itemBuilder: (context, index) {
                      final product = favoriteProducts[index];

                      return GestureDetector(
                        onTap: () {
                          // กดแล้วไปหน้ารายละเอียด
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: ProductCard(
                          name: product.name,
                          price: "฿${product.price}",
                          rating: product.rating.toInt(),
                          // 🌟 1. เปลี่ยนให้ดึงค่าหัวใจจริงๆ จาก Firebase มาโชว์
                          isFavorite: product.isFavorite,
                          imageUrl: product.imagePath ?? "",
                          onFavoriteToggle: () {
                            // 🌟 2. ลบ SnackBar ทิ้ง แล้วสั่งอัปเดตค่าลง Firebase ทันทีที่กด
                            _productManager.toggleFavorite(product.id, product.isFavorite);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}