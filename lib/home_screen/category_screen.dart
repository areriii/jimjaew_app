import 'package:flutter/material.dart';
import 'package:jimjaew_app/model/product_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final filteredProducts = widget.products.where((product) {
      final matchCategory = widget.selectedCategory == null
          ? true
          : product["category"] == widget.selectedCategory;

      final matchSearch = _searchController.text.isEmpty
          ? true
          : product["name"]
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());

      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // 🔥 AppBar (มี back จริง)
      appBar: AppBar(
        title: const Text("Category"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔍 Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search in category",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Row(
              children: [
                // 🔵 ซ้าย: category list
                Container(
                  width: 110,
                  color: Colors.grey[200],
                  child: ListView.builder(
                    itemCount: widget.categories.length,
                    itemBuilder: (context, index) {
                      final category = widget.categories[index];

                      return ListTile(
                        title: Text(category["label"]),
                        selected:
                        widget.selectedCategory == category["label"],
                        onTap: () {
                          if (widget.selectedCategory ==
                              category["label"]) {
                            widget.onCategorySelect("");
                          } else {
                            widget.onCategorySelect(category["label"]);
                          }
                        },
                      );
                    },
                  ),
                ),

                // 🔴 ขวา: product
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text("No products"))
                      : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredProducts.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return ProductCard(
                        name: product["name"],
                        price: product["price"],
                        rating: product["rating"],
                        isFavorite: product["favorite"],
                        imageUrl: product["image"],
                        onFavoriteToggle: () {},
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