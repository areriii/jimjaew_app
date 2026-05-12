import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jimjaew_app/home_screen/cart_screen.dart';
import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/home_screen/profile_screen.dart';
import 'package:jimjaew_app/home_screen/category_screen.dart';
import 'package:jimjaew_app/login/login_screen.dart';
import 'package:jimjaew_app/register/register_screen.dart';
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
import 'package:jimjaew_app/user/user_manager.dart';
import 'package:jimjaew_app/products/product_image.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});
  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  int _selectedIndex = 0;
  final ProductManager _productManager = ProductManager();
  final TextEditingController _searchController = TextEditingController();
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {"icon": "assets/icons/shirt-solid-full.svg", "label": "Shirt"},
    {"icon": "assets/icons/pants-svgrepo-com.svg", "label": "Pants"},
    {"icon": "assets/icons/glasses-solid-full.svg", "label": "Glasses"},
    {"icon": "assets/icons/socks-solid-full.svg", "label": "Shoes"},
    {"icon": "assets/icons/watch-solid-full.svg", "label": "Watch"},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAccountPage() async {
    final userManager = UserManager();
    if (userManager.isLoggedIn) {
      _goToProfileScreen();
    } else {
      _showLoginOrRegisterSheet();
    }
  }

  void _goToProfileScreen() {
    final userManager = UserManager();
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(
      username: userManager.currentFirstName,
      email: userManager.currentEmail,
    )));
  }

  void _showLoginOrRegisterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20))),
              const SizedBox(height: 20),
              const Text("Account Required", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                    if (result == true) { setState(() {}); _goToProfileScreen(); }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white),
                  child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen()));
                    if (result == true) { setState(() {}); _goToProfileScreen(); }
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2196F3)),
                  child: const Text("Register", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _selectedIndex == 3 ? const CartScreen() : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey.shade400,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Category"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorite"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) return _buildHomePage();
    if (_selectedIndex == 1) return CategoryScreen(
        categories: categories, products: const [],
        selectedCategory: selectedCategory,
        onCategorySelect: (v) => setState(() { selectedCategory = v.isEmpty ? null : v; _selectedIndex = 0; })
    );
    if (_selectedIndex == 2) return _buildFavoritePage();
    return const CartScreen();
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        // 🌟 1. ส่วนหัวพร้อมช่องค้นหา (Search Bar)
        _buildGradientHeader(),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            children: [
              _buildCategorySection(),
              const SizedBox(height: 20),
              // แสดงหัวข้อตามการเลือกหมวดหมู่
              Text(
                selectedCategory != null ? "Category: $selectedCategory" : "Recent Products",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 15),
              // 🌟 2. แสดงกริตสินค้าพร้อมระบบกรอง (Filtering)
              _buildProductGrid(null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(bool? onlyFavorite) {
    Query queryRef = FirebaseFirestore.instance.collection('products');
    if (onlyFavorite == true) queryRef = queryRef.where('isFavorite', isEqualTo: true);

    return StreamBuilder<QuerySnapshot>(
      stream: queryRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No products found"));

        // 🌟 3. ตรรกะการกรองข้อมูลตามหมวดหมู่และการค้นหา
        final filteredProducts = snapshot.data!.docs.map((doc) => ShopItemModel.fromFirestore(doc)).where((p) {
          final matchSearch = _searchController.text.isEmpty || p.name.toLowerCase().contains(_searchController.text.toLowerCase());
          final matchCat = onlyFavorite == true ? true : (selectedCategory == null || p.category == selectedCategory);
          return matchSearch && matchCat;
        }).toList();

        if (filteredProducts.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No products match your search")));

        return GridView.builder(
          shrinkWrap: true, // ป้องกันเลย์เอาต์หาย
          physics: const NeverScrollableScrollPhysics(), // เลื่อนไปกับหน้าหลัก
          itemCount: filteredProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.65),
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return GestureDetector(
              // 🌟 4. กดที่รูปแล้วไปหน้ารายละเอียดสินค้า
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
              child: ProductCard(
                product: product,
                onFavoriteToggle: () => _productManager.toggleFavorite(product.id, product.isFavorite),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF03A9F4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text("Jimjaew Shop", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: _openAccountPage,
                child: const CircleAvatar(backgroundColor: Colors.white, radius: 22, child: Icon(Icons.person, color: Color(0xFF2196F3))),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // 🔍 ช่องค้นหาที่หายไป (เพิ่มกลับมาให้แล้ว)
          Container(
            height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))]),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF2196F3)),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}), // รีเฟรชกริตเมื่อพิมพ์
                        decoration: const InputDecoration(hintText: "Search for products...", border: InputBorder.none)
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        SizedBox(
          height: 95,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) => _buildCategoryItem(categories[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final bool isSelected = selectedCategory == category["label"];
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = isSelected ? null : category["label"]),
      child: Column(
        children: [
          Container(
              width: 65, height: 65,
              decoration: BoxDecoration(color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
              child: Center(child: SvgPicture.asset(category["icon"], width: 28, colorFilter: ColorFilter.mode(isSelected ? Colors.white : const Color(0xFF2196F3), BlendMode.srcIn)))
          ),
          const SizedBox(height: 8),
          Text(category["label"], style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF2196F3) : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildFavoritePage() {
    return Column(
      children: [
        _buildGradientHeader(),
        Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [_buildProductGrid(true)])),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final ShopItemModel product;
  final VoidCallback onFavoriteToggle;
  const ProductCard({super.key, required this.product, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: ProductImage(imagePath: product.imagePath))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("฿${product.price}", style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 15)),
                Align(alignment: Alignment.centerRight, child: IconButton(icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red), onPressed: onFavoriteToggle)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}