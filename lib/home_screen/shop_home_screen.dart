import 'package:flutter/material.dart';
import 'package:jimjaew_app/model/product_model.dart';
import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/home_screen/profile_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  int _selectedIndex = 0;

  // ข้อมูลหมวดหมู่
  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.checkroom_outlined, "label": "Shirt"},
    {"icon": Icons.dry_cleaning_outlined, "label": "Pants"},
    {"icon": Icons.visibility_outlined, "label": "Glasses"},
    {"icon": Icons.shopping_bag_outlined, "label": "Shoes"},
    {"icon": Icons.watch_outlined, "label": "Watch"},
    {"icon": Icons.watch_later_outlined, "label": "Watch"},
  ];

  // ข้อมูลสินค้า
  final List<Map<String, dynamic>> products = [
    {
      "name": "Mens Shirt",
      "price": "Rs. 1000",
      "rating": 3,
      "favorite": false,
      "image":
      "https://images.unsplash.com/photo-1603252109303-2751441dd157?w=800",
      "description":
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ullamcorper in non at egestas metus auctor ultricies phasellus senectus.",
    },
    {
      "name": "Trouser",
      "price": "Rs. 3000",
      "rating": 4,
      "favorite": true,
      "image":
      "https://images.unsplash.com/photo-1506629905607-bb5b4b1fbad5?w=800",
      "description":
      "Trouser เนื้อผ้านุ่ม ใส่สบาย เหมาะกับการแต่งตัวได้หลายสไตล์ ทั้งลุคสบาย ๆ และลุคออกไปข้างนอก.",
    },
    {
      "name": "Mens T-Shirt",
      "price": "Rs. 1000",
      "rating": 3,
      "favorite": false,
      "image":
      "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800",
      "description":
      "เสื้อยืดผู้ชายทรงสวย ใส่สบาย ระบายอากาศได้ดี เหมาะกับการใส่ทุกวัน.",
    },
    {
      "name": "Full shirt",
      "price": "Rs. 3000",
      "rating": 4,
      "favorite": true,
      "image":
      "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800",
      "description":
      "เสื้อเชิ้ตแขนยาวดีไซน์เรียบ ใส่ได้ทั้งแบบทางการและลำลอง แมตช์ง่ายมาก.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              // search bar + profile
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            "Search for products",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // กดรูปโปรไฟล์แล้วไปหน้า Profile
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
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

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        height: 95,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final category = categories[index];

                            return Column(
                              children: [
                                Container(
                                  width: 62,
                                  height: 62,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD8ECFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    category["icon"],
                                    size: 28,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category["label"],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Latest Products",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "See all",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6A9FD8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      GridView.builder(
                        itemCount: products.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.58,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    name: product["name"] ?? "",
                                    price: product["price"] ?? "",
                                    rating: product["rating"] ?? 0,
                                    isFavorite: product["favorite"] ?? false,
                                    imageUrl: product["image"] ?? "",
                                    description: product["description"] ??
                                        "No description available",
                                  ),
                                ),
                              );
                            },
                            child: ProductCard(
                              name: product["name"] ?? "",
                              price: product["price"] ?? "",
                              rating: product["rating"] ?? 0,
                              isFavorite: product["favorite"] ?? false,
                              imageUrl: product["image"] ?? "",
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}