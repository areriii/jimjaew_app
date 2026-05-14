import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
import 'package:path/path.dart' as p;

class ProductFormScreen extends StatefulWidget {
  final ShopItemModel? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductManager _productManager = ProductManager();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  bool get isEditMode => widget.product != null;
  bool _isLoading = false;
  String? _imageFileName;
  String _selectedCategory = 'Shirt';
  final List<String> _categories = ['Shirt', 'Pants', 'Glasses', 'Shoes', 'Watch'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: isEditMode ? widget.product!.name : '');
    _priceController = TextEditingController(text: isEditMode ? widget.product!.price.toString() : '');
    _stockController = TextEditingController(text: isEditMode ? widget.product!.stock.toString() : '');

    if (isEditMode && widget.product!.imagePath != null) {

      _imageFileName = p.basename(widget.product!.imagePath!);
      _selectedCategory = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<String?> _getFullPath(String? fileName) async {
    if (fileName == null || fileName.isEmpty) return null;
    if (fileName.startsWith('http')) return fileName;
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, p.basename(fileName));
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final String name = _nameController.text.trim();
      final double price = double.parse(_priceController.text.trim());
      final int stock = int.parse(_stockController.text.trim());

      final data = {
        'name': name,
        'price': price,
        'stock': stock,
        'imagePath': _imageFileName,
        'category': _selectedCategory,
      };

      if (isEditMode) {
        await _productManager.updateProduct(widget.product!.id, data);
      } else {
        await _productManager.addProduct(name, price, stock, _imageFileName, _selectedCategory);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = p.join(directory.path, fileName);

    await File(pickedFile.path).copy(newPath);
    setState(() => _imageFileName = fileName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Product' : 'Add New Product'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (isEditMode)
            IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await _productManager.deleteProduct(widget.product!.id);
                  if (mounted) Navigator.pop(context);
                }
            )
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _stockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: ElevatedButton.icon(onPressed: _pickAndSaveImage, icon: const Icon(Icons.photo), label: const Text("Choose Image"))),
                  if (_imageFileName != null)
                    IconButton(onPressed: () => setState(() => _imageFileName = null), icon: const Icon(Icons.close, color: Colors.red))
                ],
              ),
              const SizedBox(height: 10),

              Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                child: FutureBuilder<String?>(
                  future: _getFullPath(_imageFileName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    final fullPath = snapshot.data;
                    if (fullPath == null) return const Center(child: Icon(Icons.image, size: 50, color: Colors.grey));

                    if (fullPath.startsWith('http')) return Image.network(fullPath, fit: BoxFit.cover);
                    final file = File(fullPath);
                    if (file.existsSync()) return Image.file(file, fit: BoxFit.cover);
                    return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.red));
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: _saveData,
                  child: Text(isEditMode ? 'Update Product' : 'Save Product', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              )),
            ],
          ),
        ),
      ),
    );
  }
}