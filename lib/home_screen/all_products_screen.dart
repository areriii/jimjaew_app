import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
import 'package:jimjaew_app/products/product_image.dart';

class AllProductsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const AllProductsScreen({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("All Products"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: ShopItemModel(
                        id: 'mock_id',
                        name: product["name"] ?? "No Name",
                        price: double.tryParse(product["price"].toString()) ?? 0.0,
                        stock: 10,
                        imagePath: product["image"],
                        category: 'Shirt',
                      ),
                    ),
                  ),
                );
              },
              child: ProductCard(
                name: product["name"] ?? "",
                price: product["price"] ?? "",
                rating: product["rating"] ?? 0,
                isFavorite: product["favorite"] ?? false,
                imagePath: product["image"] ?? "",
                onFavoriteToggle: () {
                  product["favorite"] = !(product["favorite"] ?? false);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final int rating;
  final bool isFavorite;
  final String? imagePath;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.rating,
    required this.isFavorite,
    required this.imagePath,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: ProductImage(imagePath: imagePath),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      radius: 16,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(color: Color(0xFF5B9DDB), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) => Icon(
                    Icons.star,
                    size: 12,
                    color: i < rating ? Colors.orange : Colors.grey.shade300,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}