import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jimjaew_app/model/product_model.dart';
import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/home_screen/profile_screen.dart';
import 'package:jimjaew_app/home_screen/all_products_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  int _selectedIndex = 0;
  bool _isSearching = false;

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
      return _buildCategoryPage();
    } else if (_selectedIndex == 2) {
      return _buildFavoritePage();
    } else {
      return _buildCartPage();
    }
  }

  Widget _buildHomePage() {
    final displayProducts = filteredProducts;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),

            Row(
              children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Latest Products",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllProductsScreen(
                          products: displayProducts,
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

            Expanded(
              child: GridView.builder(
                itemCount: displayProducts.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  final product = displayProducts[index];

                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(
                                name: product["name"],
                                price: product["price"],
                                rating: product["rating"],
                                isFavorite: product["favorite"],
                                imageUrl: product["image"],
                                description: product["description"],
                              ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          product["favorite"] = result;
                        });
                      }
                    },
                    child: ProductCard(
                      name: product["name"],
                      price: product["price"],
                      rating: product["rating"],
                      isFavorite: product["favorite"],
                      imageUrl: product["image"],
                      onFavoriteToggle: () {
                        setState(() {
                          product["favorite"] =
                          !(product["favorite"] ?? false);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPage() {
    return const Center(child: Text("Category Page"));
  }

  Widget _buildCartPage() {
    return const Center(child: Text("Cart Page"));
  }

  Widget _buildFavoritePage() {
    final favoriteProducts =
    products.where((p) => p["favorite"] == true).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Favorite",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            if (favoriteProducts.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("No favorite items"),
                ),
              )
            else

              Expanded(
                child: GridView.builder(
                  itemCount: favoriteProducts.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.58,
                  ),
                  itemBuilder: (context, index) {
                    final product = favoriteProducts[index];

                    return ProductCard(
                      name: product["name"],
                      price: product["price"],
                      rating: product["rating"],
                      isFavorite: product["favorite"],
                      imageUrl: product["image"],
                      onFavoriteToggle: () {
                        setState(() {
                          product["favorite"] = false;
                        });
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