import 'package:flutter/material.dart';
import 'package:jimjaew_app/model/product_model.dart';
import 'product_detail_screen.dart';

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
  final TextEditingController _searchController =
  TextEditingController();

  String? localSelectedCategory;

  @override
  void initState() {
    super.initState();
    localSelectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = widget.products.where((product) {
      final matchCategory = localSelectedCategory == null
          ? true
          : product["category"] == localSelectedCategory;

      final matchSearch = _searchController.text.isEmpty
          ? true
          : (product["name"] ?? "")
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()
      );

      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 10),

            // 🔍 Search
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: widget.categories.length,

                      itemBuilder: (context, index) {
                        final category =
                        widget.categories[index];

                        return ListTile(
                          title: Text(category["label"]),

                          selected:
                          localSelectedCategory ==
                              category["label"],

                          onTap: () {
                            setState(() {
                              if (localSelectedCategory ==
                                  category["label"]) {
                                localSelectedCategory = null;
                              } else {
                                localSelectedCategory =
                                category["label"];
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),

                  // 🔴 ขวา: products
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(
                      child: Text("No products"),
                    )
                        : GridView.builder(
                      padding:
                      const EdgeInsets.all(12),

                      itemCount:
                      filteredProducts.length,

                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.58,
                      ),

                      itemBuilder: (context, index) {
                        final product =
                        filteredProducts[index];

                        return GestureDetector(
                          onTap: () async {
                            final result =
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(
                                      name:
                                      product["name"],
                                      price:
                                      product["price"],
                                      rating:
                                      product["rating"],
                                      isFavorite:
                                      product["favorite"],
                                      imageUrl:
                                      product["image"],
                                      description:
                                      product[
                                      "description"],
                                    ),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                product["favorite"] =
                                    result;
                              });
                            }
                          },

                          child: ProductCard(
                            name: product["name"],
                            price: product["price"],
                            rating: product["rating"],
                            isFavorite:
                            product["favorite"],
                            imageUrl:
                            product["image"],

                            onFavoriteToggle: () {
                              setState(() {
                                product["favorite"] =
                                !(product[
                                "favorite"] ??
                                    false);
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

            // 🔙 Back button ด้านล่างซ้าย
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                bottom: 12,
              ),

              alignment: Alignment.centerLeft,

              child: IconButton(
                icon: const Icon(Icons.arrow_back),

                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}