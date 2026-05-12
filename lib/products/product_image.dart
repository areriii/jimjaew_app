import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


class ProductImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;

  const ProductImage({super.key, required this.imagePath, this.width, this.height});

  Future<String?> _getActualPath() async {
    if (imagePath == null || imagePath!.isEmpty) return null;
    if (imagePath!.startsWith('http')) return imagePath;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(imagePath!);
    return p.join(directory.path, fileName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getActualPath(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final path = snapshot.data;
        if (path == null) return const Icon(Icons.image_not_supported, color: Colors.grey);

        if (path.startsWith('http')) {
          return Image.network(path, width: width, height: height, fit: BoxFit.cover);
        }

        final file = File(path);
        if (file.existsSync()) {
          return Image.file(file, width: width, height: height, fit: BoxFit.cover);
        }

        // ถ้าหาไม่เจอจริงๆ ให้โชว์ไอคอนแจ้งเตือน
        return const Icon(Icons.broken_image, color: Colors.orange);
      },
    );
  }
}