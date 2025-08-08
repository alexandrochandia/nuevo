import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store/vmf_product_model.dart';
import '../../models/store/vmf_cart_model.dart';
import '../../providers/aura_provider.dart';
import '../../providers/vmf_store_provider.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_blur_button.dart';
import '../../widgets/store/vmf_product_card.dart';
import '../../widgets/zoom_overlay_image.dart';

class VMFProductDetailScreen extends StatefulWidget {
  final VMFProduct product;

  const VMFProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<VMFProductDetailScreen> createState() => _VMFProductDetailScreenState();
}

class _VMFProductDetailScreenState extends State<VMFProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  int _quantity = 1;
  VMFProductVariation? _selectedVariation;

  @override
  void initState() {
    super.initState();
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _imagePageController.dispose();
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
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(auraColor),
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductInfo(auraColor),
                          _buildProductDetails(auraColor),
                          _buildVariationsSection(auraColor),
                          _buildRelatedProducts(),
                          const SizedBox(height: 100), // Espacio para el bottom bar
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(auraColor),
    );
  }

  Widget _buildSliverAppBar(Color auraColor) {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black.withOpacity(0.8),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.favorite_border, color: Colors.white),
          ),
          onPressed: () {
            // TODO: Implementar wishlist
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: () {
            // TODO: Implementar compartir
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImageGallery(),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = widget.product.images.isNotEmpty 
        ? widget.product.images 
        : [widget.product.featuredImage ?? ''];

    return Stack(
      children: [
        PageView.builder(
          controller: _imagePageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return ZoomOverlayImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              errorWidget: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.product.categoryColor.withOpacity(0.3),
                      widget.product.categoryColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.product.categoryIcon,
                    size: 120,
                    color: widget.product.categoryColor,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
        ),
        
        // Status badges
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.product.isFeatured)
                _buildStatusBadge('Destacado', Provider.of<AuraProvider>(context).currentAuraColor),
              if (widget.product.onSale)
                _buildStatusBadge('Oferta', Colors.red),
              if (widget.product.isDigital)
                _buildStatusBadge('Digital', Colors.blue),
              if (!widget.product.isAvailable)
                _buildStatusBadge('Agotado', Colors.grey),
            ],
          ),
        ),
        
        // Image indicators
        if (images.length > 1)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProductInfo(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categoría
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.product.categoryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.product.categoryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.product.categoryIcon,
                  size: 16,
                  color: widget.product.categoryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.product.category.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: widget.product.categoryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Título
          GradientText(
            text: widget.product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.8),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Autor/Artista
          if (widget.product.author != null || widget.product.artist != null)
            Text(
              'por ${widget.product.author ?? widget.product.artist}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Rating y reseñas
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.product.rating.floor()
                        ? Icons.star
                        : index < widget.product.rating
                            ? Icons.star_half
                            : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} reseñas)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.product.salesCount} vendidos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Precio
          Row(
            children: [
              if (widget.product.onSale && widget.product.regularPrice != null)
                Text(
                  widget.product.formattedRegularPrice,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              const SizedBox(width: 8),
              GradientText(
                text: widget.product.formattedPrice,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                colors: [
                  auraColor,
                  auraColor.withOpacity(0.7),
                ],
              ),
              if (widget.product.onSale && widget.product.regularPrice != null)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '-${(((widget.product.regularPrice! - widget.product.finalPrice) / widget.product.regularPrice!) * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(Color auraColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientText(
            text: 'Descripción',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.8),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            widget.product.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Detalles adicionales
          if (widget.product.publisher != null ||
              widget.product.releaseDate != null ||
              widget.product.tags.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                  text: 'Detalles',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.8),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                if (widget.product.publisher != null)
                  _buildDetailRow('Editorial', widget.product.publisher!),
                
                if (widget.product.releaseDate != null)
                  _buildDetailRow(
                    'Fecha de lanzamiento',
                    '${widget.product.releaseDate!.day}/${widget.product.releaseDate!.month}/${widget.product.releaseDate!.year}',
                  ),
                
                if (widget.product.isDigital)
                  _buildDetailRow('Formato', 'Descarga digital'),
                
                if (widget.product.stockQuantity > 0 && !widget.product.isDigital)
                  _buildDetailRow('Stock disponible', '${widget.product.stockQuantity} unidades'),
                
                if (widget.product.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.product.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: auraColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: auraColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationsSection(Color auraColor) {
    if (widget.product.variations == null || widget.product.variations!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientText(
            text: 'Opciones disponibles',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.8),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.product.variations!.map((variation) {
              final isSelected = _selectedVariation?.id == variation.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVariation = isSelected ? null : variation;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? auraColor.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? auraColor : Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        variation.name,
                        style: TextStyle(
                          color: isSelected ? auraColor : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (variation.price != widget.product.price)
                        Text(
                          '${variation.price.toStringAsFixed(0)} SEK',
                          style: TextStyle(
                            color: isSelected ? auraColor : Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Consumer<VMFStoreProvider>(
      builder: (context, storeProvider, child) {
        final relatedProducts = storeProvider.getRelatedProducts(widget.product);
        
        if (relatedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientText(
                text: 'Productos relacionados',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                ],
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedProducts.length,
                  itemBuilder: (context, index) {
                    return VMFProductCard(
                      product: relatedProducts[index],
                      width: 260,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VMFProductDetailScreen(
                              product: relatedProducts[index],
                            ),
                          ),
                        );
                      },
                      onAddToCart: () => _addToCart(relatedProducts[index]),
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

  Widget _buildBottomActionBar(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Selector de cantidad
            if (!widget.product.isDigital)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: auraColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () {
                        setState(() {
                          _quantity--;
                        });
                      } : null,
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.product.isAvailable ? () {
                        setState(() {
                          _quantity++;
                        });
                      } : null,
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
            
            if (!widget.product.isDigital)
              const SizedBox(width: 16),
            
            // Botón añadir al carrito
            Expanded(
              child: CustomBlurButton(
                text: widget.product.isAvailable 
                    ? 'Añadir al carrito'
                    : 'No disponible',
                icon: widget.product.isAvailable
                    ? Icons.add_shopping_cart
                    : Icons.block,
                onPressed: widget.product.isAvailable 
                    ? () => _addToCart(widget.product)
                    : () {},
                backgroundColor: widget.product.isAvailable 
                    ? auraColor 
                    : Colors.grey,
                textColor: Colors.white,
                borderRadius: 25,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(VMFProduct product) {
    final cartModel = Provider.of<VMFCartModel>(context, listen: false);
    cartModel.addToCart(
      product,
      variation: _selectedVariation,
      quantity: _quantity,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
            // TODO: Navegar al carrito
          },
        ),
      ),
    );
  }
}