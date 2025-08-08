import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store/vmf_product_model.dart';
import '../../providers/vmf_store_provider.dart';
import '../../providers/aura_provider.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/store/vmf_product_card.dart';
import 'vmf_product_detail_screen.dart';

class VMFStoreCategoriesScreen extends StatefulWidget {
  const VMFStoreCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<VMFStoreCategoriesScreen> createState() => _VMFStoreCategoriesScreenState();
}

class _VMFStoreCategoriesScreenState extends State<VMFStoreCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  ProductCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auraProvider = Provider.of<AuraProvider>(context);
    final auraColor = auraProvider.currentAuraColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(auraColor),
              Expanded(
                child: _selectedCategory == null
                    ? _buildCategoryGrid(auraColor)
                    : _buildCategoryProducts(auraColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_selectedCategory != null) {
                setState(() {
                  _selectedCategory = null;
                });
              } else {
                Navigator.pop(context);
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: auraColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                  text: _selectedCategory == null
                      ? 'Categorías'
                      : _selectedCategory.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  colors: [
                    auraColor,
                    auraColor.withOpacity(0.7),
                  ],
                ),
                Text(
                  _selectedCategory == null
                      ? 'Explora nuestras categorías espirituales'
                      : 'Productos disponibles',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(Color auraColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<VMFStoreProvider>(
        builder: (context, storeProvider, child) {
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: ProductCategory.values.length,
            itemBuilder: (context, index) {
              final category = ProductCategory.values[index];
              final products = storeProvider.getProductsByCategory(category);
              
              if (products.isEmpty) {
                return const SizedBox.shrink();
              }

              return _buildCategoryCard(category, products, auraColor);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(ProductCategory category, List<VMFProduct> products, Color auraColor) {
    final firstProduct = products.first;
    final categoryColor = firstProduct.categoryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              categoryColor.withOpacity(0.2),
              categoryColor.withOpacity(0.1),
              Colors.black.withOpacity(0.3),
            ],
          ),
          border: Border.all(
            color: categoryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: categoryColor.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  firstProduct.categoryIcon,
                  size: 32,
                  color: categoryColor,
                ),
              ),
              
              const SizedBox(height: 12),
              
              GradientText(
                text: category.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Text(
                '${products.length} producto${products.length != 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryProducts(Color auraColor) {
    return Consumer<VMFStoreProvider>(
      builder: (context, storeProvider, child) {
        final products = storeProvider.getProductsByCategory(_selectedCategory!);
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Stats de la categoría
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: auraColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      products.first.categoryIcon,
                      color: products.first.categoryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${products.length} productos disponibles',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Desde ${products.map((p) => p.finalPrice).reduce((a, b) => a < b ? a : b).toStringAsFixed(0)} SEK',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Filtros rápidos
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuickFilter(
                          'En Stock',
                          products.where((p) => p.isAvailable).length,
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickFilter(
                          'Ofertas',
                          products.where((p) => p.onSale).length,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Grid de productos
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return VMFProductCard(
                      product: products[index],
                      onTap: () => _navigateToProductDetail(products[index]),
                      onAddToCart: () => _addToCart(products[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickFilter(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProductDetail(VMFProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VMFProductDetailScreen(product: product),
      ),
    );
  }

  void _addToCart(VMFProduct product) {
    // TODO: Implementar añadir al carrito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}