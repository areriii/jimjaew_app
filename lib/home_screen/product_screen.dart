//หน้าจัดการ สินค้า

import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/product_form_screen.dart';
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/product_util.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductManager _productManager = ProductManager();
  ProductView _productView = ProductView.list;
  List<ShopItemModel> _products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการสินค้า'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _productView = _productView == ProductView.list ? ProductView.grid : ProductView.list;
              });
            },
            icon: Icon(_productView == ProductView.list ? Icons.grid_view : Icons.list),
          ),
        ],
      ),
      body: StreamBuilder<List<ShopItemModel>>(
        stream: _productManager.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ยังไม่มีสินค้า กด + เพื่อเพิ่มเลย'));
          }

          _products = snapshot.data ?? [];
          if (_productView == ProductView.grid) {
            return productInGrid(_products);
          } else {
            return productInList(_products);
          }
        },
      ),
      floatingActionButton: _productView == ProductView.grid
          ? null
          : FloatingActionButton(
        backgroundColor:  Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}