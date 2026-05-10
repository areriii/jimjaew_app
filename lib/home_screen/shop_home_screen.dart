// หน้าโฮมร้านค้า
// หน้านี้ใช้สำหรับแสดงสินค้า ค้นหาสินค้า เลือกหมวดหมู่ กด Favorite และไปหน้า Account
// แก้ปัญหากด Profile แล้ววนให้ Login ใหม่ โดยเก็บสถานะ Login ไว้ในหน้า Home และเช็กจาก UserManager ด้วย

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/home_screen/profile_screen.dart';
import 'package:jimjaew_app/home_screen/category_screen.dart';

import 'package:jimjaew_app/login/login_screen.dart';
import 'package:jimjaew_app/register/register_screen.dart';

import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
import 'package:jimjaew_app/user/user_manager.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  // เก็บตำแหน่งของ BottomNavigationBar
  // 0 = Home, 1 = Category, 2 = Favorite, 3 = Cart
  int _selectedIndex = 0;

  // ใช้ตรวจสอบว่ากำลังเปิดโหมดค้นหาหรือไม่
  bool _isSearching = false;

  // ใช้เก็บสถานะ Login ภายในหน้า Home
  // แก้ปัญหากด Profile แล้วเด้งให้ Login ซ้ำ ทั้งที่ Login สำเร็จแล้ว
  bool _hasLoggedIn = false;

  // ใช้จัดการสินค้า เช่น กด Favorite
  final ProductManager _productManager = ProductManager();

  // Controller ของช่องค้นหา
  final TextEditingController _searchController = TextEditingController();

  // หมวดหมู่ที่เลือกอยู่ ถ้าเป็น null คือไม่ได้เลือกหมวดหมู่
  String? selectedCategory;

  // รายการหมวดหมู่สินค้า
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

  @override
  void initState() {
    super.initState();

    // เช็กสถานะ Login ตอนเปิดหน้า Home
    // ถ้า UserManager มี email หรือ profileId แปลว่าเคย Login สำเร็จแล้ว
    final userManager = UserManager();

    _hasLoggedIn =
        (userManager.currentEmail != null &&
            userManager.currentEmail!.isNotEmpty) ||
            (userManager.profileId != null &&
                userManager.profileId!.isNotEmpty);

    print("SHOP HOME INIT LOGIN STATUS: $_hasLoggedIn");
    print("SHOP HOME INIT EMAIL: ${userManager.currentEmail}");
    print("SHOP HOME INIT PROFILE ID: ${userManager.profileId}");
  }

  @override
  void dispose() {
    // ปิด Controller เมื่อไม่ใช้งานแล้ว เพื่อป้องกัน memory leak
    _searchController.dispose();
    super.dispose();
  }

  // เช็กสถานะ Login จากทั้งตัวแปรในหน้านี้ และ UserManager
  // ใช้ 2 ทางเพื่อกันกรณี UserManager มีค่าแล้ว แต่หน้า Home ยังไม่รู้สถานะ
  bool get _isLoggedIn {
    final userManager = UserManager();

    return _hasLoggedIn ||
        (userManager.currentEmail != null &&
            userManager.currentEmail!.isNotEmpty) ||
        (userManager.profileId != null && userManager.profileId!.isNotEmpty);
  }

  // ฟังก์ชันสร้าง icon หมวดหมู่จากไฟล์ SVG
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

  // ฟังก์ชันสร้างปุ่มหมวดหมู่แต่ละอัน
  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final bool isSelected = selectedCategory == category["label"];
    final String iconPath = category["icon"] as String;

    return GestureDetector(
      onTap: () {
        setState(() {
          // ถ้ากดหมวดหมู่เดิมซ้ำ จะยกเลิกการเลือก
          if (selectedCategory == category["label"]) {
            selectedCategory = null;
          } else {
            selectedCategory = category["label"];
          }
        });
      },
      child: Column(
        children: [
          // วงกลม icon หมวดหมู่
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

          // ชื่อหมวดหมู่
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

  // ฟังก์ชันตรวจสอบก่อนเข้า Account
  // ถ้า Login แล้ว จะเข้า Profile ทันที
  // ถ้ายังไม่ Login จะเปิดตัวเลือก Login/Register
  void _openAccountPage() {
    print("OPEN ACCOUNT LOGIN STATUS: $_isLoggedIn");
    print("OPEN ACCOUNT EMAIL: ${UserManager().currentEmail}");
    print("OPEN ACCOUNT PROFILE ID: ${UserManager().profileId}");

    if (_isLoggedIn) {
      _goToProfileScreen();
    } else {
      _showLoginOrRegisterSheet();
    }
  }

  // ฟังก์ชันไปหน้า Profile
  void _goToProfileScreen() {
    final userManager = UserManager();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          username: userManager.currentFirstName,
          email: userManager.currentEmail,
        ),
      ),
    );
  }

  // ฟังก์ชันแสดงตัวเลือก Login / Register
  void _showLoginOrRegisterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // เส้นจับด้านบนของ Bottom Sheet
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                // หัวข้อของ Bottom Sheet
                const Text(
                  "Account Required",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // ข้อความอธิบาย
                const Text(
                  "Please login or register before opening your account page.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                // ปุ่ม Login
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      // เปิดหน้า Login และรอผลลัพธ์กลับมา
                      // หน้า login_screen.dart ต้อง Navigator.pop(context, true); ตอน Login สำเร็จ
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );

                      print("LOGIN RESULT FROM LOGIN SCREEN: $result");
                      print("AFTER LOGIN EMAIL: ${UserManager().currentEmail}");
                      print(
                        "AFTER LOGIN PROFILE ID: ${UserManager().profileId}",
                      );

                      // ถ้า Login สำเร็จ ให้จำสถานะไว้ในหน้า Home แล้วเปิดหน้า Profile
                      if (result == true) {
                        if (!mounted) return;

                        setState(() {
                          _hasLoggedIn = true;
                        });

                        _goToProfileScreen();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ปุ่ม Register
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      // เปิดหน้า Register และรอผลลัพธ์กลับมา
                      // หน้า register_screen.dart ต้อง Navigator.pop(context, true); ตอนสมัครสำเร็จ
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );

                      print("REGISTER RESULT FROM REGISTER SCREEN: $result");
                      print(
                        "AFTER REGISTER EMAIL: ${UserManager().currentEmail}",
                      );
                      print(
                        "AFTER REGISTER PROFILE ID: ${UserManager().profileId}",
                      );

                      // ถ้า Register สำเร็จ ให้จำสถานะไว้ในหน้า Home แล้วเปิดหน้า Profile
                      if (result == true) {
                        if (!mounted) return;

                        setState(() {
                          _hasLoggedIn = true;
                        });

                        _goToProfileScreen();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(
                        color: Colors.blue,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ปุ่ม Cancel
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // แสดงหน้าตามแท็บที่เลือก
      body: _buildBody(),

      // แถบนำทางด้านล่าง
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7FB3E8),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,

        // เมื่อกดแท็บด้านล่าง จะเปลี่ยนหน้า
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

  // ฟังก์ชันเลือกหน้าที่จะแสดงตาม BottomNavigationBar
  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildHomePage();
    } else if (_selectedIndex == 1) {
      return CategoryScreen(
        categories: categories,
        products: const [],
        selectedCategory: selectedCategory,
        onCategorySelect: (value) {
          setState(() {
            selectedCategory = value.isEmpty ? null : value;
            _selectedIndex = 0;
          });
        },
      );
    } else if (_selectedIndex == 2) {
      return _buildFavoritePage();
    } else {
      return _buildCartPage();
    }
  }

  // หน้า Home หลัก
  Widget _buildHomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),

            // แถวช่องค้นหาและปุ่ม Account
            Row(
              children: [
                // ปุ่มย้อนกลับจากโหมดค้นหา
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

                // ช่องค้นหาสินค้า
                Expanded(
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),

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
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ปุ่มล้างคำค้นหา
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

                // ปุ่ม Account มุมขวาบน
                // ถ้า Login แล้ว จะเปิดหน้า Profile ทันที
                // ถ้ายังไม่ Login จะเปิด Bottom Sheet ให้เลือก Login/Register
                GestureDetector(
                  onTap: _openAccountPage,
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFD8ECFF),
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF4D93CF),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // แสดงหัวข้อตอนค้นหา หรือเลือกหมวดหมู่
            if (_isSearching ||
                _searchController.text.isNotEmpty ||
                selectedCategory != null)
              Text(
                selectedCategory != null ? selectedCategory! : "Search Results",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 16),

            // แสดงหมวดหมู่ตอนที่ไม่ได้ค้นหา
            if (!_isSearching && _searchController.text.isEmpty) ...[
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // รายการหมวดหมู่แบบเลื่อนแนวนอน
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

            // ดึงสินค้าจาก Firebase แบบ real-time
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  // กำลังโหลดข้อมูลจาก Firebase
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // กรณีไม่มีสินค้าในร้าน
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products in store",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  // แปลงข้อมูลจาก Firestore เป็น ShopItemModel
                  final allRealProducts = snapshot.data!.docs
                      .map((doc) => ShopItemModel.fromFirestore(doc))
                      .toList();

                  // ดึงคำค้นหาจากช่อง Search
                  final String query =
                  _searchController.text.trim().toLowerCase();

                  // กรองสินค้าตามหมวดหมู่และคำค้นหา
                  final filteredRealProducts =
                  allRealProducts.where((product) {
                    final matchCategory =
                        selectedCategory == null ||
                            product.category == selectedCategory;

                    final matchSearch =
                        query.isEmpty ||
                            product.name.toLowerCase().contains(query);

                    return matchCategory && matchSearch;
                  }).toList();

                  // กรณีค้นหาแล้วไม่เจอสินค้า
                  if (filteredRealProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  // แสดงสินค้าเป็น GridView
                  return GridView.builder(
                    itemCount: filteredRealProducts.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      final realProduct = filteredRealProducts[index];

                      return GestureDetector(
                        onTap: () {
                          // ไปหน้ารายละเอียดสินค้า
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: realProduct,
                              ),
                            ),
                          );
                        },
                        child: ProductCard(
                          name: realProduct.name,
                          price: "฿${realProduct.price}",
                          rating: realProduct.rating.toInt(),
                          isFavorite: realProduct.isFavorite,
                          imageUrl: realProduct.imagePath ?? "",
                          onFavoriteToggle: () {
                            // อัปเดต Favorite ลง Firebase
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
          ],
        ),
      ),
    );
  }

  // หน้า Cart ตอนนี้เป็น placeholder
  Widget _buildCartPage() {
    return const Center(
      child: Text(
        "Cart Page",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  // หน้า Favorite
  Widget _buildFavoritePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // หัวข้อหน้า Favorite
            const Text(
              "Favorites",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ดึงข้อมูลสินค้าที่กด Favorite จาก Firebase
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  // กำลังโหลดข้อมูล
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // ไม่มีสินค้าในร้าน
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products in store",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  // กรองเฉพาะสินค้าที่ isFavorite = true
                  final favoriteDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['isFavorite'] == true;
                  }).toList();

                  // ยังไม่มีสินค้า Favorite
                  if (favoriteDocs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "No favorite products yet",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // แปลงข้อมูล Favorite เป็น ShopItemModel
                  final favoriteProducts = favoriteDocs
                      .map((doc) => ShopItemModel.fromFirestore(doc))
                      .toList();

                  // แสดงสินค้า Favorite
                  return GridView.builder(
                    itemCount: favoriteProducts.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.52,
                    ),
                    itemBuilder: (context, index) {
                      final product = favoriteProducts[index];

                      return GestureDetector(
                        onTap: () {
                          // ไปหน้ารายละเอียดสินค้า
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: product,
                              ),
                            ),
                          );
                        },
                        child: ProductCard(
                          name: product.name,
                          price: "฿${product.price}",
                          rating: product.rating.toInt(),
                          isFavorite: product.isFavorite,
                          imageUrl: product.imagePath ?? "",
                          onFavoriteToggle: () {
                            // อัปเดต Favorite ลง Firebase
                            _productManager.toggleFavorite(
                              product.id,
                              product.isFavorite,
                            );
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

// การ์ดสินค้า
// ใช้แสดงรูปสินค้า ชื่อสินค้า ราคา คะแนนดาว และปุ่ม Favorite
class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final int rating;
  final bool isFavorite;
  final String imageUrl;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.rating,
    required this.isFavorite,
    required this.imageUrl,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // กล่องหลักของการ์ดสินค้า
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนรูปสินค้าและปุ่ม Favorite
          Expanded(
            child: Stack(
              children: [
                // รูปสินค้า
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,

                    // ถ้าโหลดรูปไม่ได้ ให้แสดง icon แทน
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFEFEFEF),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  )
                      : Container(
                    color: const Color(0xFFEFEFEF),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // ปุ่มหัวใจ Favorite อยู่มุมขวาบนของรูป
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ส่วนข้อมูลสินค้าใต้รูป
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อสินค้า
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                // ราคาสินค้า
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF4D93CF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                // คะแนนดาวสินค้า
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      Icons.star,
                      size: 14,
                      color: index < rating
                          ? Colors.amber
                          : Colors.grey.shade300,
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