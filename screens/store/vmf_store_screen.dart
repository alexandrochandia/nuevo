import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vmf_store_provider.dart';
import '../../providers/aura_provider.dart';
import '../../models/store/vmf_product_model.dart';
import '../../models/store/vmf_cart_model.dart';
import '../../widgets/store/vmf_product_card.dart';
import '../../widgets/store/simplified_enhanced_product_card.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_blur_button.dart';

import 'vmf_product_detail_screen.dart';
import 'enhanced_vmf_cart_screen.dart';
import 'vmf_store_categories_screen.dart';

class VMFStoreScreen extends StatefulWidget {
  const VMFStoreScreen({Key? key}) : super(key: key);

  @override
  State<VMFStoreScreen> createState() => _VMFStoreScreenState();
}

class _VMFStoreScreenState extends State<VMFStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // screenScrollController = _scrollController;
    
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VMFStoreProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
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
              _buildSearchBar(auraColor),
              _buildTabBar(auraColor),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFeaturedTab(),
                    _buildCategoriesTab(),
                    _buildAllProductsTab(),
                    _buildOffersTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCartFAB(auraColor),
    );
  }

  Widget _buildHeader(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                  text: 'Tienda VMF',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  colors: [
                    auraColor,
                    auraColor.withOpacity(0.7),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Recursos espirituales premium',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          CustomBlurButton(
            text: 'Categorías',
            icon: Icons.category,
            onPressed: () => _navigateToCategories(),
            backgroundColor: auraColor,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color auraColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
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
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (query) {
          Provider.of<VMFStoreProvider>(context, listen: false)
              .searchProducts(query);
        },
        decoration: InputDecoration(
          hintText: 'Buscar productos espirituales...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: auraColor,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<VMFStoreProvider>(context, listen: false)
                        .searchProducts('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(Color auraColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              auraColor,
              auraColor.withOpacity(0.7),
            ],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        tabs: const [
          Tab(text: 'Destacados'),
          Tab(text: 'Categorías'),
          Tab(text: 'Todos'),
          Tab(text: 'Ofertas'),
        ],
      ),
    );
  }

  Widget _buildFeaturedTab() {
    return Consumer<VMFStoreProvider>(
      builder: (context, storeProvider, child) {
        if (storeProvider.isLoadingFeatured) {
          return _buildLoadingGrid();
        }

        if (storeProvider.featuredProducts.isEmpty) {
          return _buildEmptyState('No hay productos destacados disponibles');
        }

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Productos Destacados'),
              const SizedBox(height: 16),
              _buildProductGrid(storeProvider.featuredProducts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<VMFStoreProvider>(
      builder: (context, storeProvider, child) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ProductCategory.values.map((category) {
              final products = storeProvider.getProductsByCategory(category);
              if (products.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryHeader(category),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return VMFProductCard(
                          product: products[index],
                          width: 280,
                          onTap: () => _navigateToProductDetail(products[index]),
                          onAddToCart: () => _addToCart(products[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAllProductsTab() {
    return Consumer<VMFStoreProvider>(
      builder: (context, storeProvider, child) {
        if (storeProvider.isLoading) {
          return _buildLoadingGrid();
        }

        if (storeProvider.products.isEmpty) {
          return _buildEmptyState('No se encontraron productos');
        }

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildFilterChips(storeProvider),
              const SizedBox(height: 16),
              _buildProductGrid(storeProvider.products),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOffersTab() {
    return Consumer<VMFStoreProvider>(
      builder: (context, storeProvider, child) {
        final saleProducts = storeProvider.allProducts
            .where((p) => p.onSale)
            .toList();

        if (saleProducts.isEmpty) {
          return _buildEmptyState('No hay ofertas disponibles actualmente');
        }

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Ofertas Especiales'),
              const SizedBox(height: 16),
              _buildProductGrid(saleProducts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return GradientText(
      text: title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      colors: [
        Colors.white,
        Colors.white.withOpacity(0.8),
      ],
    );
  }

  Widget _buildCategoryHeader(ProductCategory category) {
    final products = Provider.of<VMFStoreProvider>(context, listen: false)
        .getProductsByCategory(category);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: products.first.categoryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            products.first.categoryIcon,
            color: products.first.categoryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GradientText(
            text: category.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.8),
            ],
          ),
        ),
        Text(
          '${products.length} productos',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(VMFStoreProvider storeProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            'En Stock',
            storeProvider.onlyInStock,
            () => storeProvider.toggleInStockFilter(),
          ),
          _buildFilterChip(
            'En Oferta',
            storeProvider.onlyOnSale,
            () => storeProvider.toggleOnSaleFilter(),
          ),
          _buildSortChip(storeProvider),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final auraColor = Provider.of<AuraProvider>(context).currentAuraColor;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? auraColor.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? auraColor : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? auraColor : Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(VMFStoreProvider storeProvider) {
    final auraColor = Provider.of<AuraProvider>(context).currentAuraColor;
    
    return GestureDetector(
      onTap: () => _showSortModal(storeProvider),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              color: auraColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Ordenar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<VMFProduct> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return SimplifiedEnhancedProductCard(
          product: products[index],
          onTap: () => _navigateToProductDetail(products[index]),
          onAddToCart: () => _addToCart(products[index]),
          onAddToWishlist: () => _addToWishlist(products[index]),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartFAB(Color auraColor) {
    return Consumer<VMFCartModel>(
      builder: (context, cartModel, child) {
        return FloatingActionButton.extended(
          onPressed: () => _navigateToCart(),
          backgroundColor: auraColor,
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              if (cartModel.itemCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartModel.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: Text(
            cartModel.isEmpty ? 'Carrito' : cartModel.formattedTotal,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  // Métodos de navegación
  void _navigateToProductDetail(VMFProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VMFProductDetailScreen(product: product),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EnhancedVMFCartScreen(),
      ),
    );
  }

  void _navigateToCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VMFStoreCategoriesScreen(),
      ),
    );
  }

  // Métodos de acción
  void _addToCart(VMFProduct product) {
    final cartModel = Provider.of<VMFCartModel>(context, listen: false);
    cartModel.addToCart(product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToWishlist(VMFProduct product) {
    // TODO: Implementar sistema de wishlist/favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido a favoritos'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSortModal(VMFStoreProvider storeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ordenar por',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...[
                ('name', 'Nombre'),
                ('price', 'Precio'),
                ('rating', 'Valoración'),
                ('sales', 'Ventas'),
                ('date', 'Fecha'),
              ].map((sort) {
                return ListTile(
                  title: Text(
                    sort.$2,
                    style: const TextStyle(color: Colors.white),
                  ),
                  leading: Radio<String>(
                    value: sort.$1,
                    groupValue: storeProvider.sortBy,
                    onChanged: (value) {
                      storeProvider.setSorting(value!);
                      Navigator.pop(context);
                    },
                    activeColor: Provider.of<AuraProvider>(context).currentAuraColor,
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}