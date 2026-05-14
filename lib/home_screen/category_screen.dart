import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jimjaew_app/products/product_image.dart';
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

  final Color primaryBlue = const Color(0xFF2196F3);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Categories", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "Search in categories...",
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  color: Colors.white,
                  child: ListView.builder(
                    itemCount: widget.categories.length,
                    itemBuilder: (context, index) {
                      final category = widget.categories[index];
                      final isSelected = widget.selectedCategory == category["label"];
                      return GestureDetector(
                        onTap: () => widget.onCategorySelect(isSelected ? "" : category["label"]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                            border: Border(
                                left: BorderSide(
                                    color: isSelected ? primaryBlue : Colors.transparent,
                                    width: 4
                                )
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Text(
                            category["label"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? primaryBlue : Colors.black54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('products').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No products"));

                      final allRealProducts = snapshot.data!.docs.map((doc) => ShopItemModel.fromFirestore(doc)).toList();
                      final String query = _searchController.text.trim().toLowerCase();

                      final filteredRealProducts = allRealProducts.where((product) {
                        final matchCategory = (widget.selectedCategory == null || widget.selectedCategory!.isEmpty)
                            ? true : product.category == widget.selectedCategory;
                        final matchSearch = query.isEmpty || product.name.toLowerCase().contains(query);
                        return matchCategory && matchSearch;
                      }).toList();

                      if (filteredRealProducts.isEmpty) return const Center(child: Icon(Icons.search_off, size: 48, color: Colors.grey));

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredRealProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.62,
                        ),
                        itemBuilder: (context, index) {
                          final realProduct = filteredRealProducts[index];
                          return CategoryProductCard(
                            product: realProduct,
                            onFavoriteToggle: () => _productManager.toggleFavorite(realProduct.id, realProduct.isFavorite),
                          );
                        },
                      );
                    },
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

class CategoryProductCard extends StatelessWidget {
  final ShopItemModel product;
  final VoidCallback onFavoriteToggle;

  const CategoryProductCard({
    super.key,
    required this.product,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: SizedBox(
                      width: double.infinity,
                      child: ProductImage(imagePath: product.imagePath),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: Icon(
                            product.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 18
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("฿${product.price}", style: const TextStyle(fontSize: 14, color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text("${product.rating}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}