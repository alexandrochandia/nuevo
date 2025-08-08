import 'package:flutter/material.dart';

/// Dynamic layout widget that renders different layout types
class DynamicLayout extends StatelessWidget {
  final Map<String, dynamic> configLayout;
  final EdgeInsets padding;

  const DynamicLayout({
    super.key,
    required this.configLayout,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final layout = configLayout['layout'] as String? ?? '';
    final data = configLayout['data'];

    // Handle different layout types
    switch (layout) {
      case 'custom_header':
      case 'custom_featured':
      case 'custom_stats':
      case 'custom_actions':
        if (data is Widget) {
          return Padding(
            padding: padding,
            child: data,
          );
        }
        return const SizedBox.shrink();

      case 'spacer':
        final height = configLayout['height'] as double? ?? 20;
        return SizedBox(height: height);

      case 'bannerImage':
        return _buildBannerLayout(data);

      case 'product':
        return _buildProductLayout(data);

      case 'category':
        return _buildCategoryLayout(data);

      case 'text':
        return _buildTextLayout(data);

      default:
      // En lugar de mostrar "Layout no soportado", devuelve un widget vacío
        return const SizedBox.shrink();
    }
  }

  Widget _buildBannerLayout(dynamic data) {
    if (data == null) return const SizedBox.shrink();

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 50,
        ),
      ),
    );
  }

  Widget _buildProductLayout(dynamic data) {
    if (data == null) return const SizedBox.shrink();

    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag,
                color: Colors.grey,
                size: 30,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryLayout(dynamic data) {
    if (data == null) return const SizedBox.shrink();

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.category,
                color: Colors.grey,
                size: 25,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextLayout(dynamic data) {
    if (data == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        data.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}